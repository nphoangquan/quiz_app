import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../../domain/entities/subscription_tier.dart';
import '../../domain/entities/user_entity.dart';

/// Service để quản lý subscription và usage limits
class FirebaseSubscriptionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference get _usersCollection => _firestore.collection('users');

  /// Upgrade user to Pro
  Future<void> upgradeUserToPro(String userId) async {
    try {
      await _usersCollection.doc(userId).update({
        'subscriptionTier': 'pro',
        'updatedAt': FieldValue.serverTimestamp(),
      });
      debugPrint('✅ User upgraded to Pro: $userId');
    } catch (e) {
      debugPrint('❌ Upgrade failed: $e');
      rethrow;
    }
  }

  /// Downgrade user to Free
  Future<void> downgradeUserToFree(String userId) async {
    try {
      await _usersCollection.doc(userId).update({
        'subscriptionTier': 'free',
        'updatedAt': FieldValue.serverTimestamp(),
      });
      debugPrint('✅ User downgraded to Free: $userId');
    } catch (e) {
      debugPrint('❌ Downgrade failed: $e');
      rethrow;
    }
  }

  /// Increment AI generation counter
  Future<void> incrementAIGeneration(String userId) async {
    try {
      final doc = await _usersCollection.doc(userId).get();
      if (!doc.exists) {
        throw Exception('User not found');
      }

      final data = doc.data() as Map<String, dynamic>;

      final usageLimits = UsageLimits.fromMap(
        data['usageLimits'] as Map<String, dynamic>? ?? {},
      );

      // Reset if new day
      final newLimits = usageLimits.needsReset()
          ? usageLimits.resetForNewDay().incrementAIGeneration()
          : usageLimits.incrementAIGeneration();

      await _usersCollection.doc(userId).update({
        'usageLimits': newLimits.toMap(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      debugPrint('✅ AI generation count: ${newLimits.aiGenerationsToday}');
    } catch (e) {
      debugPrint('❌ Increment AI generation failed: $e');
      rethrow;
    }
  }

  /// Check if user can create quiz
  Future<bool> canCreateQuiz(String userId) async {
    try {
      final doc = await _usersCollection.doc(userId).get();
      if (!doc.exists) {
        return false;
      }

      final data = doc.data() as Map<String, dynamic>;

      final tier = SubscriptionTierExtension.fromString(
        data['subscriptionTier'] ?? 'free',
      );
      final stats = UserStats.fromMap(data['stats'] as Map<String, dynamic>);

      if (tier.quizLimit == -1) return true; // Pro = unlimited
      return stats.quizzesCreated < tier.quizLimit;
    } catch (e) {
      debugPrint('❌ Check create quiz failed: $e');
      return false;
    }
  }

  /// Check if user can use AI generation
  Future<bool> canUseAIGeneration(String userId) async {
    try {
      final doc = await _usersCollection.doc(userId).get();
      if (!doc.exists) {
        return false;
      }

      final data = doc.data() as Map<String, dynamic>;

      final tier = SubscriptionTierExtension.fromString(
        data['subscriptionTier'] ?? 'free',
      );
      final usageLimits = UsageLimits.fromMap(
        data['usageLimits'] as Map<String, dynamic>? ?? {},
      );

      if (tier.aiGenerationDailyLimit == -1) return true; // Pro = unlimited
      return usageLimits.aiGenerationsToday < tier.aiGenerationDailyLimit;
    } catch (e) {
      debugPrint('❌ Check AI generation failed: $e');
      return false;
    }
  }

  /// Get user's subscription info
  Future<Map<String, dynamic>> getUserSubscriptionInfo(String userId) async {
    try {
      final doc = await _usersCollection.doc(userId).get();
      if (!doc.exists) {
        throw Exception('User not found');
      }

      final data = doc.data() as Map<String, dynamic>;

      final tier = SubscriptionTierExtension.fromString(
        data['subscriptionTier'] ?? 'free',
      );
      final stats = UserStats.fromMap(data['stats'] as Map<String, dynamic>);
      final usageLimits = UsageLimits.fromMap(
        data['usageLimits'] as Map<String, dynamic>? ?? {},
      );

      return {
        'tier': tier,
        'canCreateQuiz':
            tier.quizLimit == -1 || stats.quizzesCreated < tier.quizLimit,
        'canUseAI':
            tier.aiGenerationDailyLimit == -1 ||
            usageLimits.aiGenerationsToday < tier.aiGenerationDailyLimit,
        'remainingQuizzes': tier.quizLimit == -1
            ? -1
            : tier.quizLimit - stats.quizzesCreated,
        'remainingAI': tier.aiGenerationDailyLimit == -1
            ? -1
            : tier.aiGenerationDailyLimit - usageLimits.aiGenerationsToday,
        'quizzesCreated': stats.quizzesCreated,
        'aiGenerationsToday': usageLimits.aiGenerationsToday,
      };
    } catch (e) {
      debugPrint('❌ Get subscription info failed: $e');
      rethrow;
    }
  }

  /// Reset daily AI generation counter (for testing)
  Future<void> resetDailyAICounter(String userId) async {
    try {
      final newLimits = UsageLimits(
        aiGenerationsToday: 0,
        lastAiResetDate: DateTime.now(),
      );

      await _usersCollection.doc(userId).update({
        'usageLimits': newLimits.toMap(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      debugPrint('✅ Daily AI counter reset for user: $userId');
    } catch (e) {
      debugPrint('❌ Reset AI counter failed: $e');
      rethrow;
    }
  }

  /// Get all users with their subscription info (Admin only)
  Future<List<Map<String, dynamic>>> getAllUsersSubscriptionInfo() async {
    try {
      final snapshot = await _usersCollection.get();

      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        final tier = SubscriptionTierExtension.fromString(
          data['subscriptionTier'] ?? 'free',
        );
        final stats = UserStats.fromMap(data['stats'] as Map<String, dynamic>);
        final usageLimits = UsageLimits.fromMap(
          data['usageLimits'] as Map<String, dynamic>? ?? {},
        );

        return {
          'userId': doc.id,
          'name': data['name'] ?? '',
          'email': data['email'] ?? '',
          'tier': tier,
          'quizzesCreated': stats.quizzesCreated,
          'aiGenerationsToday': usageLimits.aiGenerationsToday,
          'lastAiResetDate': usageLimits.lastAiResetDate,
        };
      }).toList();
    } catch (e) {
      debugPrint('❌ Get all users subscription info failed: $e');
      rethrow;
    }
  }
}
