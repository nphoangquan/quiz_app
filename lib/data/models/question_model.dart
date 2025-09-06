import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/question_entity.dart';

class QuestionModel extends QuestionEntity {
  const QuestionModel({
    required super.questionId,
    required super.question,
    required super.type,
    required super.options,
    required super.correctAnswerIndex,
    super.explanation,
    super.imageUrl,
    required super.order,
    super.points = 10,
    super.timeLimit = 0,
  });

  /// Create QuestionModel from Firestore document
  factory QuestionModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return QuestionModel(
      questionId: doc.id,
      question: data['question'] ?? '',
      type: QuestionType.values.firstWhere(
        (type) => type.name == data['type'],
        orElse: () => QuestionType.multipleChoice,
      ),
      options: List<String>.from(data['options'] ?? []),
      correctAnswerIndex: data['correctAnswerIndex']?.toInt() ?? 0,
      explanation: data['explanation'],
      imageUrl: data['imageUrl'],
      order: data['order']?.toInt() ?? 0,
      points: data['points']?.toInt() ?? 10,
      timeLimit: data['timeLimit']?.toInt() ?? 0,
    );
  }

  /// Convert QuestionModel to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'question': question,
      'type': type.name,
      'options': options,
      'correctAnswerIndex': correctAnswerIndex,
      'explanation': explanation,
      'imageUrl': imageUrl,
      'order': order,
      'points': points,
      'timeLimit': timeLimit,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  /// Create a copy with updated fields
  QuestionModel copyWith({
    String? questionId,
    String? question,
    QuestionType? type,
    List<String>? options,
    int? correctAnswerIndex,
    String? explanation,
    String? imageUrl,
    int? order,
    int? points,
    int? timeLimit,
  }) {
    return QuestionModel(
      questionId: questionId ?? this.questionId,
      question: question ?? this.question,
      type: type ?? this.type,
      options: options ?? this.options,
      correctAnswerIndex: correctAnswerIndex ?? this.correctAnswerIndex,
      explanation: explanation ?? this.explanation,
      imageUrl: imageUrl ?? this.imageUrl,
      order: order ?? this.order,
      points: points ?? this.points,
      timeLimit: timeLimit ?? this.timeLimit,
    );
  }

  /// Create empty question for new question creation
  factory QuestionModel.empty(int order) {
    return QuestionModel(
      questionId: '',
      question: '',
      type: QuestionType.multipleChoice,
      options: ['', '', '', ''],
      correctAnswerIndex: 0,
      order: order,
      points: 10,
      timeLimit: 0,
    );
  }

  /// Create True/False question
  factory QuestionModel.trueFalse({
    required String questionId,
    required String question,
    required bool correctAnswer,
    String? explanation,
    String? imageUrl,
    required int order,
    int points = 10,
    int timeLimit = 0,
  }) {
    return QuestionModel(
      questionId: questionId,
      question: question,
      type: QuestionType.trueFalse,
      options: ['Đúng', 'Sai'],
      correctAnswerIndex: correctAnswer ? 0 : 1,
      explanation: explanation,
      imageUrl: imageUrl,
      order: order,
      points: points,
      timeLimit: timeLimit,
    );
  }
}
