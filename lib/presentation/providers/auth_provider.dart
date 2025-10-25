import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/entities/user_role.dart';
import '../../domain/entities/subscription_tier.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../data/services/firebase_subscription_service.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthProvider extends ChangeNotifier {
  final AuthRepository _authRepository;
  final FirebaseSubscriptionService _subscriptionService =
      FirebaseSubscriptionService();

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

  /// Check if current user is admin
  bool get isAdmin => _user?.isAdmin ?? false;

  /// Check if current user is regular user
  bool get isUser => _user?.isUser ?? false;

  /// Get current user role display name
  String get userRoleDisplayName => _user?.role.displayName ?? 'Chưa xác định';

  // Subscription-related getters
  /// Check if current user is Pro
  bool get isPro => _user?.isPro ?? false;

  /// Check if current user is Free
  bool get isFree => _user?.isFree ?? false;

  /// Get current user subscription tier
  SubscriptionTier get subscriptionTier =>
      _user?.subscriptionTier ?? SubscriptionTier.free;

  /// Check if user can create quiz
  bool get canCreateQuiz => _user?.canCreateQuiz ?? false;

  /// Check if user can use AI generation
  bool get canUseAIGeneration => _user?.canUseAIGeneration ?? false;

  /// Get remaining quizzes user can create
  int get remainingQuizzes => _user?.remainingQuizzes ?? 0;

  /// Get remaining AI generations for today
  int get remainingAIGenerations => _user?.remainingAIGenerations ?? 0;

  /// Initialize auth state listener
  void _initializeAuthListener() {
    _authRepository.authStateChanges.listen(
      (user) {
        _user = user;
        if (user != null) {
          _status = AuthStatus.authenticated;
          debugPrint('✅ User authenticated: ${user.name}');
        } else {
          _status = AuthStatus.unauthenticated;
          debugPrint('🚪 User signed out');
        }
        notifyListeners();
      },
      onError: (error) {
        _status = AuthStatus.error;
        _errorMessage = error.toString();
        debugPrint('❌ Auth state error: $error');
        notifyListeners();
      },
    );
  }

  /// Sign in with Google
  Future<void> signInWithGoogle() async {
    try {
      _setLoading(true);
      _clearError();

      debugPrint('🔑 Attempting Google Sign-In...');

      final user = await _authRepository.signInWithGoogle();

      if (user != null) {
        _user = user;
        _status = AuthStatus.authenticated;
        debugPrint('🎉 Google Sign-In successful: ${user.name}');
      } else {
        _status = AuthStatus.unauthenticated;
      }
    } catch (e) {
      // Check if it's a type cast error (internal plugin issue)
      final errorString = e.toString();
      if (errorString.contains('type') && errorString.contains('subtype') ||
          errorString.contains('PigeonUserDetails')) {
        // This is likely a harmless internal plugin error
        debugPrint('⚠️ Internal plugin error (ignored): $e');
        // Don't set error status, wait for auth state listener
        return;
      }

      // For real errors, set error status with delay
      _setErrorWithDelay(errorString);
      debugPrint('❌ Google Sign-In error: $e');
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
      debugPrint('✅ Sign out successful');
    } catch (e) {
      _status = AuthStatus.error;
      _errorMessage = _getErrorMessage(e.toString());
      debugPrint('❌ Sign out error: $e');
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
      debugPrint('✅ Account deleted successfully');
    } catch (e) {
      _status = AuthStatus.error;
      _errorMessage = _getErrorMessage(e.toString());
      debugPrint('❌ Delete account error: $e');
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

  /// Update user profile
  Future<void> updateProfile({String? displayName, String? photoUrl}) async {
    if (_user == null) {
      throw Exception('User not authenticated');
    }

    _isLoading = true;
    notifyListeners();

    try {
      await _authRepository.updateProfile(
        displayName: displayName,
        photoUrl: photoUrl,
      );

      // Update local user data directly to avoid PigeonUserInfo error
      if (displayName != null) {
        _user = UserEntity(
          uid: _user!.uid,
          name: displayName,
          email: _user!.email,
          photoUrl: _user!.photoUrl,
          stats: _user!.stats,
          createdAt: _user!.createdAt,
          role: _user!.role,
          subscriptionTier: _user!.subscriptionTier,
          usageLimits: _user!.usageLimits,
        );
      }
      if (photoUrl != null) {
        _user = UserEntity(
          uid: _user!.uid,
          name: _user!.name,
          email: _user!.email,
          photoUrl: photoUrl,
          stats: _user!.stats,
          createdAt: _user!.createdAt,
          role: _user!.role,
          subscriptionTier: _user!.subscriptionTier,
          usageLimits: _user!.usageLimits,
        );
      }

      notifyListeners();
      debugPrint('✅ Profile updated successfully');
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint('❌ Profile update error: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Refresh current user data from Firestore
  Future<void> refreshUser() async {
    try {
      _setLoading(true);
      _clearError();

      debugPrint('🔄 Refreshing user data...');

      final refreshedUser = await _authRepository.getCurrentUser();

      if (refreshedUser != null) {
        _user = refreshedUser;
        _status = AuthStatus.authenticated;

        // Check and reset daily counters if needed
        await _subscriptionService.checkAndResetDailyCounters(
          refreshedUser.uid,
        );

        debugPrint(
          '✅ User data refreshed: ${refreshedUser.name} (${refreshedUser.role.displayName})',
        );
      } else {
        _status = AuthStatus.unauthenticated;
        debugPrint('❌ Failed to refresh user data');
      }
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint('❌ Refresh user error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Check admin status for current user
  Future<bool> checkAdminStatus() async {
    try {
      if (_user == null) return false;

      debugPrint('🔍 Checking admin status for user: ${_user!.uid}');

      final isAdmin = await _authRepository.isUserAdmin(_user!.uid);

      // Update local user data if role changed
      if (isAdmin != _user!.isAdmin) {
        await refreshUser();
      }

      debugPrint('${isAdmin ? '✅' : '❌'} Admin status: $isAdmin');
      return isAdmin;
    } catch (e) {
      debugPrint('❌ Check admin status error: $e');
      return false;
    }
  }

  // Subscription-related methods
  /// Upgrade current user to Pro
  Future<bool> upgradeToPro() async {
    try {
      if (_user == null) return false;

      _setLoading(true);
      _clearError();

      debugPrint('🚀 Upgrading user to Pro: ${_user!.uid}');

      await _subscriptionService.upgradeUserToPro(_user!.uid);
      await refreshUser(); // Refresh user data

      debugPrint('✅ User upgraded to Pro successfully');
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint('❌ Upgrade to Pro failed: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Downgrade current user to Free
  Future<bool> downgradeToFree() async {
    try {
      if (_user == null) return false;

      _setLoading(true);
      _clearError();

      debugPrint('⬇️ Downgrading user to Free: ${_user!.uid}');

      await _subscriptionService.downgradeUserToFree(_user!.uid);
      await refreshUser(); // Refresh user data

      debugPrint('✅ User downgraded to Free successfully');
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint('❌ Downgrade to Free failed: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Increment AI generation counter
  Future<bool> incrementAIGeneration() async {
    try {
      if (_user == null) return false;

      debugPrint('🤖 Incrementing AI generation for user: ${_user!.uid}');

      await _subscriptionService.incrementAIGeneration(_user!.uid);
      await refreshUser(); // Refresh user data

      debugPrint('✅ AI generation incremented successfully');
      return true;
    } catch (e) {
      debugPrint('❌ Increment AI generation failed: $e');
      return false;
    }
  }

  /// Check if user can create quiz (with refresh)
  Future<bool> checkCanCreateQuiz() async {
    try {
      if (_user == null) return false;

      final canCreate = await _subscriptionService.canCreateQuiz(_user!.uid);

      // Refresh user data to get latest stats
      await refreshUser();

      return canCreate;
    } catch (e) {
      debugPrint('❌ Check can create quiz failed: $e');
      return false;
    }
  }

  /// Check if user can use AI generation (with refresh)
  Future<bool> checkCanUseAIGeneration() async {
    try {
      if (_user == null) return false;

      final canUse = await _subscriptionService.canUseAIGeneration(_user!.uid);

      // Refresh user data to get latest usage
      await refreshUser();

      return canUse;
    } catch (e) {
      debugPrint('❌ Check can use AI generation failed: $e');
      return false;
    }
  }

  /// Get detailed subscription info
  Future<Map<String, dynamic>?> getSubscriptionInfo() async {
    try {
      if (_user == null) return null;

      return await _subscriptionService.getUserSubscriptionInfo(_user!.uid);
    } catch (e) {
      debugPrint('❌ Get subscription info failed: $e');
      return null;
    }
  }

  /// Reset daily AI counter (for testing)
  Future<bool> resetDailyAICounter() async {
    try {
      if (_user == null) return false;

      await _subscriptionService.resetDailyAICounter(_user!.uid);
      await refreshUser(); // Refresh user data

      debugPrint('✅ Daily AI counter reset successfully');
      return true;
    } catch (e) {
      debugPrint('❌ Reset AI counter failed: $e');
      return false;
    }
  }

  @override
  void dispose() {
    _errorTimer?.cancel();
    super.dispose();
  }
}
