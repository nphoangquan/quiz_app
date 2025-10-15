import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/quiz_entity.dart';

class QuizModel extends QuizEntity {
  const QuizModel({
    required super.quizId,
    required super.title,
    required super.description,
    required super.ownerId,
    required super.ownerName,
    super.ownerAvatar,
    required super.tags,
    super.categoryId,
    required super.isPublic,
    required super.questionCount,
    required super.difficulty,
    required super.hasTimedQuestions, // New parameter
    required super.createdAt,
    required super.updatedAt,
    required super.stats,
  });

  /// Create QuizModel from QuizEntity
  factory QuizModel.fromEntity(QuizEntity entity) {
    return QuizModel(
      quizId: entity.quizId,
      title: entity.title,
      description: entity.description,
      ownerId: entity.ownerId,
      ownerName: entity.ownerName,
      ownerAvatar: entity.ownerAvatar,
      tags: entity.tags,
      categoryId: entity.categoryId,
      isPublic: entity.isPublic,
      questionCount: entity.questionCount,
      difficulty: entity.difficulty,
      hasTimedQuestions: entity.hasTimedQuestions, // New field
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      stats: entity.stats,
    );
  }

  /// Create QuizModel from Firestore document
  factory QuizModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return QuizModel(
      quizId: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      ownerId: data['ownerId'] ?? '',
      ownerName: data['ownerName'] ?? '',
      ownerAvatar: data['ownerAvatar'],
      tags: List<String>.from(data['tags'] ?? []),
      categoryId: data['categoryId'] as String?,
      isPublic: data['isPublic'] ?? false,
      questionCount: data['questionCount']?.toInt() ?? 0,
      difficulty: QuizDifficulty.values.firstWhere(
        (diff) => diff.name == data['difficulty'],
        orElse: () => QuizDifficulty.beginner,
      ),
      hasTimedQuestions: data['hasTimedQuestions'] ?? false, // New field
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      stats: data['stats'] != null
          ? QuizStats.fromMap(data['stats'] as Map<String, dynamic>)
          : const QuizStats(),
    );
  }

  /// Convert QuizModel to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'ownerId': ownerId,
      'ownerName': ownerName,
      'ownerAvatar': ownerAvatar,
      'tags': tags,
      'categoryId': categoryId, // Only store categoryId
      'isPublic': isPublic,
      'questionCount': questionCount,
      'difficulty': difficulty.name,
      'hasTimedQuestions': hasTimedQuestions, // New field
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': FieldValue.serverTimestamp(),
      'stats': stats.toMap(),
    };
  }

  /// Create a copy with updated fields
  QuizModel copyWith({
    String? quizId,
    String? title,
    String? description,
    String? ownerId,
    String? ownerName,
    String? ownerAvatar,
    List<String>? tags,
    String? categoryId,
    bool? isPublic,
    int? questionCount,
    QuizDifficulty? difficulty,
    bool? hasTimedQuestions,
    DateTime? createdAt,
    DateTime? updatedAt,
    QuizStats? stats,
  }) {
    return QuizModel(
      quizId: quizId ?? this.quizId,
      title: title ?? this.title,
      description: description ?? this.description,
      ownerId: ownerId ?? this.ownerId,
      ownerName: ownerName ?? this.ownerName,
      ownerAvatar: ownerAvatar ?? this.ownerAvatar,
      tags: tags ?? this.tags,
      categoryId: categoryId ?? this.categoryId,
      isPublic: isPublic ?? this.isPublic,
      questionCount: questionCount ?? this.questionCount,
      difficulty: difficulty ?? this.difficulty,
      hasTimedQuestions: hasTimedQuestions ?? this.hasTimedQuestions,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      stats: stats ?? this.stats,
    );
  }

  /// Create empty quiz for new quiz creation
  factory QuizModel.empty(String ownerId, String ownerName) {
    return QuizModel(
      quizId: '',
      title: '',
      description: '',
      ownerId: ownerId,
      ownerName: ownerName,
      tags: [],
      categoryId: null,
      isPublic: false,
      questionCount: 0,
      difficulty: QuizDifficulty.beginner,
      hasTimedQuestions: false, // Empty quiz has no timed questions
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      stats: const QuizStats(),
    );
  }
}
