import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

class FirebaseTestService {
  /// Test Firebase connection and services
  static Future<bool> testConnection() async {
    try {
      // Check if Firebase is initialized
      if (Firebase.apps.isEmpty) {
        debugPrint('⚠️ Firebase not initialized, skipping test');
        return false;
      }

      debugPrint('🔥 Testing Firebase connection...');

      // Test Firestore connection
      await FirebaseFirestore.instance
          .collection('test')
          .doc('connection_test')
          .set({
            'message': 'Firebase connected successfully!',
            'timestamp': FieldValue.serverTimestamp(),
            'app_version': '1.0.0',
          });

      debugPrint('✅ Firestore connection successful!');

      // Test Auth initialization
      final auth = FirebaseAuth.instance;
      debugPrint('✅ Firebase Auth initialized: ${auth.app.name}');
      debugPrint('✅ Current user: ${auth.currentUser?.uid ?? "Not signed in"}');

      // Test read from Firestore
      final doc = await FirebaseFirestore.instance
          .collection('test')
          .doc('connection_test')
          .get();

      if (doc.exists) {
        debugPrint('✅ Firestore read successful: ${doc.data()}');
      }

      debugPrint('🎉 All Firebase services are working!');
      return true;
    } catch (e) {
      debugPrint('❌ Firebase connection error: $e');
      return false;
    }
  }

  /// Check if user is authenticated
  static bool isUserAuthenticated() {
    return FirebaseAuth.instance.currentUser != null;
  }

  /// Get current user info
  static User? getCurrentUser() {
    return FirebaseAuth.instance.currentUser;
  }
}
