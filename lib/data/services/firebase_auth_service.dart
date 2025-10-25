import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../../domain/entities/user_role.dart';
import '../../domain/entities/subscription_tier.dart';
import '../../domain/entities/user_entity.dart';

class FirebaseAuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Get current Firebase user
  User? get currentFirebaseUser => _firebaseAuth.currentUser;

  /// Check if user is authenticated
  bool get isAuthenticated => currentFirebaseUser != null;

  /// Listen to authentication state changes
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  /// Sign in with Google
  Future<UserModel?> signInWithGoogle() async {
    try {
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        return null; // User cancelled
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      final UserCredential userCredential = await _firebaseAuth
          .signInWithCredential(credential);
      final User? firebaseUser = userCredential.user;

      if (firebaseUser == null) {
        throw Exception('Failed to sign in with Google');
      }

      // Create UserModel from Firebase user
      final userModel = UserModel.fromFirebaseUser(firebaseUser);

      // Save or update user data in Firestore
      await _saveUserToFirestore(userModel);

      return userModel;
    } on FirebaseAuthException catch (e) {
      debugPrint('❌ Firebase Auth error: ${e.code} - ${e.message}');
      rethrow;
    } on Exception catch (e) {
      debugPrint('❌ Google Sign-In error: $e');
      rethrow;
    } catch (e) {
      // Handle type cast and other errors
      debugPrint('❌ Google Sign-In error: $e');
      // Return null instead of rethrowing to prevent app crash
      return null;
    }
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      // Sign out from Google
      await _googleSignIn.signOut();

      // Sign out from Firebase
      await _firebaseAuth.signOut();
    } catch (e) {
      debugPrint('❌ Sign out error: $e');
      rethrow;
    }
  }

  /// Get current user from Firestore
  Future<UserModel?> getCurrentUser() async {
    try {
      final User? firebaseUser = currentFirebaseUser;
      if (firebaseUser == null) return null;

      final doc = await _firestore
          .collection('users')
          .doc(firebaseUser.uid)
          .get();

      if (doc.exists) {
        return UserModel.fromFirestore(doc);
      } else {
        // If user doesn't exist in Firestore, create from Firebase user
        final userModel = UserModel.fromFirebaseUser(firebaseUser);
        await _saveUserToFirestore(userModel);
        return userModel;
      }
    } catch (e) {
      return null;
    }
  }

  /// Check if user is admin
  Future<bool> isUserAdmin(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (!doc.exists) return false;

      final data = doc.data() as Map<String, dynamic>;
      final role = data['role'] as String? ?? 'user';
      return role == 'admin';
    } catch (e) {
      debugPrint('❌ Check admin status error: $e');
      return false;
    }
  }

  /// Update user role (Admin only function)
  Future<void> updateUserRole(String uid, UserRole newRole) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'role': newRole.value,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      debugPrint('✅ User role updated: $uid -> ${newRole.displayName}');
    } catch (e) {
      debugPrint('❌ Update user role error: $e');
      rethrow;
    }
  }

  /// Delete user account
  Future<void> deleteAccount() async {
    try {
      final User? user = currentFirebaseUser;
      if (user == null) throw Exception('No user to delete');

      // Delete user data from Firestore
      await _firestore.collection('users').doc(user.uid).delete();

      // Delete Firebase account
      await user.delete();

      // Sign out from Google
      await _googleSignIn.signOut();
    } catch (e) {
      debugPrint('❌ Delete account error: $e');
      rethrow;
    }
  }

  /// Save user data to Firestore
  Future<void> _saveUserToFirestore(UserModel user) async {
    try {
      // Check if user already exists to preserve role
      final doc = await _firestore.collection('users').doc(user.uid).get();

      if (doc.exists) {
        // User exists, only update non-role fields
        final existingData = doc.data() as Map<String, dynamic>;
        final existingRole = existingData['role'] as String? ?? 'user';

        final updateData = user.toFirestore();
        updateData['role'] = existingRole; // Preserve existing role

        // Ensure usageLimits exists (for users who don't have it)
        if (!existingData.containsKey('usageLimits')) {
          updateData['usageLimits'] = user.usageLimits.toMap();
        } else {
          // Check if daily reset is needed for existing users
          final existingUsageLimits = UsageLimits.fromMap(
            existingData['usageLimits'] as Map<String, dynamic>? ?? {},
          );

          // Auto-reset if new day
          if (existingUsageLimits.needsAiReset() ||
              existingUsageLimits.needsQuizReset()) {
            debugPrint(
              '🔄 Auto-resetting daily counters for user: ${user.uid}',
            );

            var newLimits = existingUsageLimits;
            if (existingUsageLimits.needsAiReset()) {
              newLimits = newLimits.resetAiForNewDay();
            }
            if (existingUsageLimits.needsQuizReset()) {
              newLimits = newLimits.resetQuizForNewDay();
            }

            updateData['usageLimits'] = newLimits.toMap();
            debugPrint(
              '✅ Daily counters reset: AI=${newLimits.aiGenerationsToday}, Quiz=${newLimits.quizzesCreatedToday}',
            );
          }
        }

        // Ensure subscriptionTier exists (for users who don't have it)
        if (!existingData.containsKey('subscriptionTier')) {
          updateData['subscriptionTier'] = user.subscriptionTier.value;
        }

        await _firestore
            .collection('users')
            .doc(user.uid)
            .set(updateData, SetOptions(merge: true));
      } else {
        // New user, save with default role
        await _firestore
            .collection('users')
            .doc(user.uid)
            .set(user.toFirestore());
      }

      debugPrint('✅ User data saved to Firestore: ${user.uid}');
    } catch (e) {
      debugPrint('❌ Save user to Firestore error: $e');
      rethrow;
    }
  }

  /// Update user profile
  Future<void> updateProfile({String? displayName, String? photoUrl}) async {
    try {
      final user = currentFirebaseUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      // Only update Firestore (skip Firebase Auth to avoid PigeonUserInfo error)
      final userDoc = _firestore.collection('users').doc(user.uid);
      final updateData = <String, dynamic>{};

      if (displayName != null) {
        updateData['name'] = displayName;
      }
      if (photoUrl != null) {
        updateData['photoUrl'] = photoUrl;
      }

      if (updateData.isNotEmpty) {
        updateData['updatedAt'] = FieldValue.serverTimestamp();
        await userDoc.update(updateData);
      }

      debugPrint('✅ Profile updated successfully (Firestore only)');
    } catch (e) {
      debugPrint('❌ Update profile error: $e');
      rethrow;
    }
  }
}
