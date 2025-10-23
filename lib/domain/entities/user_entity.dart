import 'user_role.dart';
import 'subscription_tier.dart';

class UserEntity {
  final String uid;
  final String name;
  final String email;
  final DateTime createdAt;
  final String? avatar;
  final String? photoUrl;
  final UserStats stats;
  final UserRole role;
  final SubscriptionTier subscriptionTier; // NEW: Subscription tier
  final UsageLimits usageLimits; // NEW: Daily usage tracking

  const UserEntity({
    required this.uid,
    required this.name,
    required this.email,
    required this.createdAt,
    this.avatar,
    this.photoUrl,
    required this.stats,
    this.role = UserRole.user,
    this.subscriptionTier = SubscriptionTier.free, // Default FREE
    required this.usageLimits,
  });

  /// Kiểm tra có phải admin không
  bool get isAdmin => role.isAdmin;

  /// Kiểm tra có phải user thường không
  bool get isUser => role.isUser;

  /// Kiểm tra có phải Pro user không
  bool get isPro => subscriptionTier.isPro;

  /// Kiểm tra có phải Free user không
  bool get isFree => subscriptionTier.isFree;

  /// Kiểm tra có thể tạo quiz không
  bool get canCreateQuiz {
    if (subscriptionTier.quizDailyLimit == -1) return true; // Pro = unlimited
    return usageLimits.quizzesCreatedToday < subscriptionTier.quizDailyLimit;
  }

  /// Kiểm tra có thể sử dụng AI generation không
  bool get canUseAIGeneration {
    if (subscriptionTier.aiGenerationDailyLimit == -1)
      return true; // Pro = unlimited
    return usageLimits.aiGenerationsToday <
        subscriptionTier.aiGenerationDailyLimit;
  }

  /// Số quiz còn lại có thể tạo hôm nay
  int get remainingQuizzes {
    if (subscriptionTier.quizDailyLimit == -1) return -1; // unlimited
    return subscriptionTier.quizDailyLimit - usageLimits.quizzesCreatedToday;
  }

  /// Số AI generation còn lại hôm nay
  int get remainingAIGenerations {
    if (subscriptionTier.aiGenerationDailyLimit == -1) return -1; // unlimited
    return subscriptionTier.aiGenerationDailyLimit -
        usageLimits.aiGenerationsToday;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserEntity && other.uid == uid;
  }

  @override
  int get hashCode => uid.hashCode;

  @override
  String toString() {
    return 'UserEntity(uid: $uid, name: $name, email: $email, role: ${role.displayName}, tier: ${subscriptionTier.displayName})';
  }
}

/// Track daily usage limits
class UsageLimits {
  final int aiGenerationsToday;
  final int quizzesCreatedToday;
  final DateTime lastAiResetDate;
  final DateTime lastQuizResetDate;

  const UsageLimits({
    this.aiGenerationsToday = 0,
    this.quizzesCreatedToday = 0,
    required this.lastAiResetDate,
    required this.lastQuizResetDate,
  });

  /// Tạo copy với các field được update
  UsageLimits copyWith({
    int? aiGenerationsToday,
    int? quizzesCreatedToday,
    DateTime? lastAiResetDate,
    DateTime? lastQuizResetDate,
  }) {
    return UsageLimits(
      aiGenerationsToday: aiGenerationsToday ?? this.aiGenerationsToday,
      quizzesCreatedToday: quizzesCreatedToday ?? this.quizzesCreatedToday,
      lastAiResetDate: lastAiResetDate ?? this.lastAiResetDate,
      lastQuizResetDate: lastQuizResetDate ?? this.lastQuizResetDate,
    );
  }

  /// Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'aiGenerationsToday': aiGenerationsToday,
      'quizzesCreatedToday': quizzesCreatedToday,
      'lastAiResetDate': lastAiResetDate.toIso8601String(),
      'lastQuizResetDate': lastQuizResetDate.toIso8601String(),
    };
  }

  /// Create from Map (from Firestore)
  factory UsageLimits.fromMap(Map<String, dynamic> map) {
    return UsageLimits(
      aiGenerationsToday: map['aiGenerationsToday']?.toInt() ?? 0,
      quizzesCreatedToday: map['quizzesCreatedToday']?.toInt() ?? 0,
      lastAiResetDate: map['lastAiResetDate'] != null
          ? DateTime.parse(map['lastAiResetDate'])
          : DateTime.now(),
      lastQuizResetDate: map['lastQuizResetDate'] != null
          ? DateTime.parse(map['lastQuizResetDate'])
          : DateTime.now(),
    );
  }

  /// Kiểm tra có cần reset AI counter hàng ngày không
  bool needsAiReset() {
    final now = DateTime.now();
    return now.year != lastAiResetDate.year ||
        now.month != lastAiResetDate.month ||
        now.day != lastAiResetDate.day;
  }

  /// Kiểm tra có cần reset Quiz counter hàng ngày không
  bool needsQuizReset() {
    final now = DateTime.now();
    return now.year != lastQuizResetDate.year ||
        now.month != lastQuizResetDate.month ||
        now.day != lastQuizResetDate.day;
  }

  /// Reset AI counter về 0 cho ngày mới
  UsageLimits resetAiForNewDay() {
    return copyWith(aiGenerationsToday: 0, lastAiResetDate: DateTime.now());
  }

  /// Reset Quiz counter về 0 cho ngày mới
  UsageLimits resetQuizForNewDay() {
    return copyWith(quizzesCreatedToday: 0, lastQuizResetDate: DateTime.now());
  }

  /// Increment AI generation counter
  UsageLimits incrementAIGeneration() {
    return copyWith(aiGenerationsToday: aiGenerationsToday + 1);
  }

  /// Increment Quiz creation counter
  UsageLimits incrementQuizCreation() {
    return copyWith(quizzesCreatedToday: quizzesCreatedToday + 1);
  }
}

class UserStats {
  final int quizzesCreated;
  final int quizzesTaken;
  final int totalScore;
  final int level;
  final int experience;

  const UserStats({
    this.quizzesCreated = 0,
    this.quizzesTaken = 0,
    this.totalScore = 0,
    this.level = 1,
    this.experience = 0,
  });

  UserStats copyWith({
    int? quizzesCreated,
    int? quizzesTaken,
    int? totalScore,
    int? level,
    int? experience,
  }) {
    return UserStats(
      quizzesCreated: quizzesCreated ?? this.quizzesCreated,
      quizzesTaken: quizzesTaken ?? this.quizzesTaken,
      totalScore: totalScore ?? this.totalScore,
      level: level ?? this.level,
      experience: experience ?? this.experience,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'quizzesCreated': quizzesCreated,
      'quizzesTaken': quizzesTaken,
      'totalScore': totalScore,
      'level': level,
      'experience': experience,
    };
  }

  factory UserStats.fromMap(Map<String, dynamic> map) {
    return UserStats(
      quizzesCreated: map['quizzesCreated']?.toInt() ?? 0,
      quizzesTaken: map['quizzesTaken']?.toInt() ?? 0,
      totalScore: map['totalScore']?.toInt() ?? 0,
      level: map['level']?.toInt() ?? 1,
      experience: map['experience']?.toInt() ?? 0,
    );
  }
}
