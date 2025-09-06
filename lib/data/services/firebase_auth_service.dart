import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

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
      print('🔑 Starting Google Sign-In...');

      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        print('❌ Google Sign-In cancelled by user');
        return null;
      }

      print('✅ Google user signed in: ${googleUser.email}');

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

      print('✅ Firebase user authenticated: ${firebaseUser.uid}');

      // Create UserModel from Firebase user
      final userModel = UserModel.fromFirebaseUser(firebaseUser);

      // Save or update user data in Firestore
      await _saveUserToFirestore(userModel);

      print('🎉 Google Sign-In completed successfully!');
      return userModel;
    } catch (e) {
      print('❌ Google Sign-In error: $e');
      rethrow;
    }
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      print('🚪 Signing out...');

      // Sign out from Google
      await _googleSignIn.signOut();

      // Sign out from Firebase
      await _firebaseAuth.signOut();

      print('✅ Signed out successfully');
    } catch (e) {
      print('❌ Sign out error: $e');
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
      print('❌ Get current user error: $e');
      return null;
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

      print('✅ Account deleted successfully');
    } catch (e) {
      print('❌ Delete account error: $e');
      rethrow;
    }
  }

  /// Save user data to Firestore
  Future<void> _saveUserToFirestore(UserModel user) async {
    try {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .set(
            user.toFirestore(),
            SetOptions(merge: true), // Merge to avoid overwriting existing data
          );
      print('✅ User data saved to Firestore: ${user.uid}');
    } catch (e) {
      print('❌ Save user to Firestore error: $e');
      rethrow;
    }
  }
}
