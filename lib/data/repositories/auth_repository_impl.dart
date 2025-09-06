import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../services/firebase_auth_service.dart';

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuthService _authService;

  AuthRepositoryImpl(this._authService);

  @override
  Future<UserEntity?> getCurrentUser() async {
    return await _authService.getCurrentUser();
  }

  @override
  Future<UserEntity?> signInWithGoogle() async {
    return await _authService.signInWithGoogle();
  }

  @override
  Future<void> signOut() async {
    return await _authService.signOut();
  }

  @override
  Stream<UserEntity?> get authStateChanges {
    return _authService.authStateChanges.asyncMap((firebaseUser) async {
      if (firebaseUser == null) return null;
      return await _authService.getCurrentUser();
    });
  }

  @override
  bool get isAuthenticated => _authService.isAuthenticated;

  @override
  Future<void> deleteAccount() async {
    return await _authService.deleteAccount();
  }
}
