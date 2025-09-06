class UserEntity {
  final String uid;
  final String name;
  final String email;
  final DateTime createdAt;
  final String? avatar;
  final String? photoUrl;
  final UserStats stats;

  const UserEntity({
    required this.uid,
    required this.name,
    required this.email,
    required this.createdAt,
    this.avatar,
    this.photoUrl,
    required this.stats,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserEntity && other.uid == uid;
  }

  @override
  int get hashCode => uid.hashCode;

  @override
  String toString() {
    return 'UserEntity(uid: $uid, name: $name, email: $email)';
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
