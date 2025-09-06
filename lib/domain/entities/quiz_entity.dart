enum QuizDifficulty { beginner, intermediate, advanced }

enum QuizCategory {
  programming,
  mathematics,
  science,
  history,
  language,
  geography,
  sports,
  entertainment,
  general,
}

class QuizEntity {
  final String quizId;
  final String title;
  final String description;
  final String ownerId;
  final String ownerName;
  final String? ownerAvatar;
  final List<String> tags;
  final QuizCategory category;
  final bool isPublic;
  final int questionCount;
  final QuizDifficulty difficulty;
  final DateTime createdAt;
  final DateTime updatedAt;
  final QuizStats stats;

  const QuizEntity({
    required this.quizId,
    required this.title,
    required this.description,
    required this.ownerId,
    required this.ownerName,
    this.ownerAvatar,
    required this.tags,
    required this.category,
    required this.isPublic,
    required this.questionCount,
    required this.difficulty,
    required this.createdAt,
    required this.updatedAt,
    required this.stats,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is QuizEntity && other.quizId == quizId;
  }

  @override
  int get hashCode => quizId.hashCode;

  @override
  String toString() {
    return 'QuizEntity(quizId: $quizId, title: $title, owner: $ownerName)';
  }
}

class QuizStats {
  final int totalAttempts;
  final double averageScore;
  final int likes;
  final int shares;
  final double rating;
  final int ratingCount;

  const QuizStats({
    this.totalAttempts = 0,
    this.averageScore = 0.0,
    this.likes = 0,
    this.shares = 0,
    this.rating = 0.0,
    this.ratingCount = 0,
  });

  QuizStats copyWith({
    int? totalAttempts,
    double? averageScore,
    int? likes,
    int? shares,
    double? rating,
    int? ratingCount,
  }) {
    return QuizStats(
      totalAttempts: totalAttempts ?? this.totalAttempts,
      averageScore: averageScore ?? this.averageScore,
      likes: likes ?? this.likes,
      shares: shares ?? this.shares,
      rating: rating ?? this.rating,
      ratingCount: ratingCount ?? this.ratingCount,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'totalAttempts': totalAttempts,
      'averageScore': averageScore,
      'likes': likes,
      'shares': shares,
      'rating': rating,
      'ratingCount': ratingCount,
    };
  }

  factory QuizStats.fromMap(Map<String, dynamic> map) {
    return QuizStats(
      totalAttempts: map['totalAttempts']?.toInt() ?? 0,
      averageScore: map['averageScore']?.toDouble() ?? 0.0,
      likes: map['likes']?.toInt() ?? 0,
      shares: map['shares']?.toInt() ?? 0,
      rating: map['rating']?.toDouble() ?? 0.0,
      ratingCount: map['ratingCount']?.toInt() ?? 0,
    );
  }
}
