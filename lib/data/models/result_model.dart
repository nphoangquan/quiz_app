import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/result_entity.dart';
import '../../domain/entities/question_entity.dart';

class ResultModel extends ResultEntity {
  const ResultModel({
    required super.resultId,
    required super.userId,
    required super.quizId,
    required super.quizTitle,
    required super.score,
    required super.totalQuestions,
    required super.correctAnswers,
    required super.totalTimeSpent,
    required super.percentage,
    required super.status,
    required super.answers,
    required super.startedAt,
    required super.completedAt,
  });

  /// Create ResultModel from ResultEntity
  factory ResultModel.fromEntity(ResultEntity entity) {
    return ResultModel(
      resultId: entity.resultId,
      userId: entity.userId,
      quizId: entity.quizId,
      quizTitle: entity.quizTitle,
      score: entity.score,
      totalQuestions: entity.totalQuestions,
      correctAnswers: entity.correctAnswers,
      totalTimeSpent: entity.totalTimeSpent,
      percentage: entity.percentage,
      status: entity.status,
      answers: entity.answers,
      startedAt: entity.startedAt,
      completedAt: entity.completedAt,
    );
  }

  /// Create ResultModel from Firestore document
  factory ResultModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return ResultModel(
      resultId: doc.id,
      userId: data['userId'] ?? '',
      quizId: data['quizId'] ?? '',
      quizTitle: data['quizTitle'] ?? '',
      score: data['score'] ?? 0,
      totalQuestions: data['totalQuestions'] ?? 0,
      correctAnswers: data['correctAnswers'] ?? 0,
      totalTimeSpent: data['totalTimeSpent'] ?? 0,
      percentage: (data['percentage'] ?? 0.0).toDouble(),
      status: QuizResultStatus.values.firstWhere(
        (status) => status.name == data['status'],
        orElse: () => QuizResultStatus.completed,
      ),
      answers:
          (data['answers'] as List?)
              ?.map(
                (answer) => UserAnswer(
                  questionId: answer['questionId'] ?? '',
                  selectedAnswer: answer['selectedAnswer'] ?? '',
                  selectedAnswerIndex: answer['selectedAnswerIndex'] ?? -1,
                  isCorrect: answer['isCorrect'] ?? false,
                  timeSpent: answer['timeSpent'] ?? 0,
                  answeredAt:
                      (answer['answeredAt'] as Timestamp?)?.toDate() ??
                      DateTime.now(),
                ),
              )
              .toList() ??
          [],
      startedAt: (data['startedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      completedAt:
          (data['completedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  /// Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'quizId': quizId,
      'quizTitle': quizTitle,
      'score': score,
      'totalQuestions': totalQuestions,
      'correctAnswers': correctAnswers,
      'totalTimeSpent': totalTimeSpent,
      'percentage': percentage,
      'status': status.name,
      'answers': answers
          .map(
            (answer) => {
              'questionId': answer.questionId,
              'selectedAnswer': answer.selectedAnswer,
              'selectedAnswerIndex': answer.selectedAnswerIndex,
              'isCorrect': answer.isCorrect,
              'timeSpent': answer.timeSpent,
              'answeredAt': Timestamp.fromDate(answer.answeredAt),
            },
          )
          .toList(),
      'startedAt': Timestamp.fromDate(startedAt),
      'completedAt': FieldValue.serverTimestamp(),
    };
  }

  /// Create a copy with updated fields
  ResultModel copyWith({
    String? resultId,
    String? userId,
    String? quizId,
    String? quizTitle,
    int? score,
    int? totalQuestions,
    int? correctAnswers,
    int? totalTimeSpent,
    double? percentage,
    QuizResultStatus? status,
    List<UserAnswer>? answers,
    DateTime? startedAt,
    DateTime? completedAt,
  }) {
    return ResultModel(
      resultId: resultId ?? this.resultId,
      userId: userId ?? this.userId,
      quizId: quizId ?? this.quizId,
      quizTitle: quizTitle ?? this.quizTitle,
      score: score ?? this.score,
      totalQuestions: totalQuestions ?? this.totalQuestions,
      correctAnswers: correctAnswers ?? this.correctAnswers,
      totalTimeSpent: totalTimeSpent ?? this.totalTimeSpent,
      percentage: percentage ?? this.percentage,
      status: status ?? this.status,
      answers: answers ?? this.answers,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }
}
