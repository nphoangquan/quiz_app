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
      final newLimits = usageLimits.needsAiReset()
          ? usageLimits.resetAiForNewDay().incrementAIGeneration()
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

  /// Increment quiz creation counter
  Future<void> incrementQuizCreation(String userId) async {
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
      final newLimits = usageLimits.needsQuizReset()
          ? usageLimits.resetQuizForNewDay().incrementQuizCreation()
          : usageLimits.incrementQuizCreation();

      // Also increment total quiz count in UserStats
      final currentStats = data['stats'] as Map<String, dynamic>? ?? {};
      final currentQuizzesCreated =
          currentStats['quizzesCreated']?.toInt() ?? 0;

      await _usersCollection.doc(userId).update({
        'usageLimits': newLimits.toMap(),
        'stats.quizzesCreated': currentQuizzesCreated + 1,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      debugPrint(
        '✅ Quiz creation count: ${newLimits.quizzesCreatedToday} (Total: ${currentQuizzesCreated + 1})',
      );
    } catch (e) {
      debugPrint('❌ Increment quiz creation failed: $e');
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
      final usageLimits = UsageLimits.fromMap(
        data['usageLimits'] as Map<String, dynamic>? ?? {},
      );

      if (tier.quizDailyLimit == -1) return true; // Pro = unlimited
      return usageLimits.quizzesCreatedToday < tier.quizDailyLimit;
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
      final usageLimits = UsageLimits.fromMap(
        data['usageLimits'] as Map<String, dynamic>? ?? {},
      );

      return {
        'tier': tier,
        'canCreateQuiz':
            tier.quizDailyLimit == -1 ||
            usageLimits.quizzesCreatedToday < tier.quizDailyLimit,
        'canUseAI':
            tier.aiGenerationDailyLimit == -1 ||
            usageLimits.aiGenerationsToday < tier.aiGenerationDailyLimit,
        'remainingQuizzes': tier.quizDailyLimit == -1
            ? -1
            : tier.quizDailyLimit - usageLimits.quizzesCreatedToday,
        'remainingAI': tier.aiGenerationDailyLimit == -1
            ? -1
            : tier.aiGenerationDailyLimit - usageLimits.aiGenerationsToday,
        'quizzesCreatedToday': usageLimits.quizzesCreatedToday,
        'aiGenerationsToday': usageLimits.aiGenerationsToday,
      };
    } catch (e) {
      debugPrint('❌ Get subscription info failed: $e');
      rethrow;
    }
  }

  /// Check and reset daily counters if needed (called on login)
  Future<void> checkAndResetDailyCounters(String userId) async {
    try {
      final doc = await _usersCollection.doc(userId).get();
      if (!doc.exists) {
        throw Exception('User not found');
      }

      final data = doc.data() as Map<String, dynamic>;
      final usageLimits = UsageLimits.fromMap(
        data['usageLimits'] as Map<String, dynamic>? ?? {},
      );

      // Check if reset is needed
      bool needsReset = false;
      var newLimits = usageLimits;

      if (usageLimits.needsAiReset()) {
        newLimits = newLimits.resetAiForNewDay();
        needsReset = true;
        debugPrint('🔄 AI counter reset for user: $userId');
      }

      if (usageLimits.needsQuizReset()) {
        newLimits = newLimits.resetQuizForNewDay();
        needsReset = true;
        debugPrint('🔄 Quiz counter reset for user: $userId');
      }

      // Update Firestore if reset was needed
      if (needsReset) {
        await _usersCollection.doc(userId).update({
          'usageLimits': newLimits.toMap(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
        debugPrint(
          '✅ Daily counters reset: AI=${newLimits.aiGenerationsToday}, Quiz=${newLimits.quizzesCreatedToday}',
        );
      }
    } catch (e) {
      debugPrint('❌ Check and reset daily counters failed: $e');
      rethrow;
    }
  }

  /// Reset daily AI generation counter (for testing)
  Future<void> resetDailyAICounter(String userId) async {
    try {
      final doc = await _usersCollection.doc(userId).get();
      if (!doc.exists) {
        throw Exception('User not found');
      }

      final data = doc.data() as Map<String, dynamic>;
      final usageLimits = UsageLimits.fromMap(
        data['usageLimits'] as Map<String, dynamic>? ?? {},
      );

      final newLimits = usageLimits.copyWith(
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
        final usageLimits = UsageLimits.fromMap(
          data['usageLimits'] as Map<String, dynamic>? ?? {},
        );

        return {
          'userId': doc.id,
          'name': data['name'] ?? '',
          'email': data['email'] ?? '',
          'tier': tier,
          'quizzesCreatedToday': usageLimits.quizzesCreatedToday,
          'aiGenerationsToday': usageLimits.aiGenerationsToday,
          'lastAiResetDate': usageLimits.lastAiResetDate,
          'lastQuizResetDate': usageLimits.lastQuizResetDate,
        };
      }).toList();
    } catch (e) {
      debugPrint('❌ Get all users subscription info failed: $e');
      rethrow;
    }
  }
}
