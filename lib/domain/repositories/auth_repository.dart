import '../entities/user_entity.dart';

abstract class AuthRepository {
  /// Get current authenticated user
  Future<UserEntity?> getCurrentUser();

  /// Sign in with Google
  Future<UserEntity?> signInWithGoogle();

  /// Sign out
  Future<void> signOut();

  /// Listen to authentication state changes
  Stream<UserEntity?> get authStateChanges;

  /// Check if user is authenticated
  bool get isAuthenticated;

  /// Delete user account
  Future<void> deleteAccount();

  /// Update user profile
  Future<void> updateProfile({String? displayName, String? photoUrl});
}
