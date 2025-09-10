import 'dart:async';
import 'package:flutter/material.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthProvider extends ChangeNotifier {
  final AuthRepository _authRepository;

  AuthProvider(this._authRepository) {
    _initializeAuthListener();
  }

  // State
  AuthStatus _status = AuthStatus.initial;
  UserEntity? _user;
  String? _errorMessage;
  bool _isLoading = false;
  Timer? _errorTimer;

  // Getters
  AuthStatus get status => _status;
  UserEntity? get user => _user;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;
  bool get isAuthenticated =>
      _status == AuthStatus.authenticated && _user != null;

  /// Initialize auth state listener
  void _initializeAuthListener() {
    _authRepository.authStateChanges.listen(
      (user) {
        _user = user;
        if (user != null) {
          _status = AuthStatus.authenticated;
          print('✅ User authenticated: ${user.name}');
        } else {
          _status = AuthStatus.unauthenticated;
          print('🚪 User signed out');
        }
        notifyListeners();
      },
      onError: (error) {
        _status = AuthStatus.error;
        _errorMessage = error.toString();
        print('❌ Auth state error: $error');
        notifyListeners();
      },
    );
  }

  /// Sign in with Google
  Future<void> signInWithGoogle() async {
    try {
      _setLoading(true);
      _clearError();

      print('🔑 Attempting Google Sign-In...');

      final user = await _authRepository.signInWithGoogle();

      if (user != null) {
        _user = user;
        _status = AuthStatus.authenticated;
        print('🎉 Google Sign-In successful: ${user.name}');
      } else {
        _status = AuthStatus.unauthenticated;
      }
    } catch (e) {
      // Check if it's a type cast error (internal plugin issue)
      final errorString = e.toString();
      if (errorString.contains('type') && errorString.contains('subtype')) {
        // This is likely a harmless internal plugin error
        print('⚠️ Internal plugin error (ignored): $e');
        // Don't set error status, wait for auth state listener
        return;
      }

      // For real errors, set error status with delay
      _setErrorWithDelay(errorString);
      print('❌ Google Sign-In error: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      _setLoading(true);
      _clearError();

      await _authRepository.signOut();

      _user = null;
      _status = AuthStatus.unauthenticated;
      print('✅ Sign out successful');
    } catch (e) {
      _status = AuthStatus.error;
      _errorMessage = _getErrorMessage(e.toString());
      print('❌ Sign out error: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Delete account
  Future<void> deleteAccount() async {
    try {
      _setLoading(true);
      _clearError();

      await _authRepository.deleteAccount();

      _user = null;
      _status = AuthStatus.unauthenticated;
      print('✅ Account deleted successfully');
    } catch (e) {
      _status = AuthStatus.error;
      _errorMessage = _getErrorMessage(e.toString());
      print('❌ Delete account error: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Clear error message
  void clearError() {
    _clearError();
  }

  /// Set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  /// Clear error
  void _clearError() {
    _errorTimer?.cancel();
    _errorMessage = null;
    notifyListeners();
  }

  /// Set error with delay to avoid flash
  void _setErrorWithDelay(String error) {
    _errorTimer?.cancel();
    _errorTimer = Timer(const Duration(milliseconds: 500), () {
      // Only show error if we're still not authenticated after delay
      if (_status != AuthStatus.authenticated) {
        _status = AuthStatus.error;
        _errorMessage = _getErrorMessage(error);
        notifyListeners();
      }
    });
  }

  /// Get user-friendly error message
  String _getErrorMessage(String error) {
    if (error.contains('network-request-failed')) {
      return 'Kiểm tra kết nối internet và thử lại';
    } else if (error.contains('user-disabled')) {
      return 'Tài khoản đã bị vô hiệu hóa';
    } else if (error.contains('operation-not-allowed')) {
      return 'Phương thức đăng nhập không được hỗ trợ';
    } else if (error.contains('account-exists-with-different-credential')) {
      return 'Tài khoản đã tồn tại với phương thức khác';
    } else {
      return 'Có lỗi xảy ra, vui lòng thử lại';
    }
  }

  @override
  void dispose() {
    _errorTimer?.cancel();
    super.dispose();
  }
}
