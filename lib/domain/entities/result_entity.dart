import 'question_entity.dart';

enum QuizResultStatus { completed, abandoned, timeExpired }

class ResultEntity {
  final String resultId;
  final String userId;
  final String quizId;
  final String quizTitle;
  final int score;
  final int totalQuestions;
  final int correctAnswers;
  final int totalTimeSpent; // in seconds
  final double percentage;
  final QuizResultStatus status;
  final List<UserAnswer> answers;
  final DateTime startedAt;
  final DateTime completedAt;

  const ResultEntity({
    required this.resultId,
    required this.userId,
    required this.quizId,
    required this.quizTitle,
    required this.score,
    required this.totalQuestions,
    required this.correctAnswers,
    required this.totalTimeSpent,
    required this.percentage,
    required this.status,
    required this.answers,
    required this.startedAt,
    required this.completedAt,
  });

  bool get isPassed => percentage >= 70.0;
  bool get isCompleted => status == QuizResultStatus.completed;

  String get grade {
    if (percentage >= 90) return 'A';
    if (percentage >= 80) return 'B';
    if (percentage >= 70) return 'C';
    if (percentage >= 60) return 'D';
    return 'F';
  }

  String get performanceMessage {
    if (percentage >= 90) return 'Xuất sắc! 🏆';
    if (percentage >= 80) return 'Rất tốt! 🌟';
    if (percentage >= 70) return 'Tốt! 👍';
    if (percentage >= 60) return 'Khá! 👌';
    return 'Cần cố gắng thêm! 💪';
  }

  Duration get duration => completedAt.difference(startedAt);

  String get formattedDuration {
    final duration = this.duration;
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes}m ${seconds}s';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ResultEntity && other.resultId == resultId;
  }

  @override
  int get hashCode => resultId.hashCode;

  @override
  String toString() {
    return 'ResultEntity(resultId: $resultId, score: $score/$totalQuestions, percentage: ${percentage.toStringAsFixed(1)}%)';
  }
}

class QuizAttempt {
  final String attemptId;
  final String userId;
  final String quizId;
  final DateTime startedAt;
  final DateTime? completedAt;
  final QuizResultStatus status;
  final List<UserAnswer> currentAnswers;
  final int currentQuestionIndex;

  const QuizAttempt({
    required this.attemptId,
    required this.userId,
    required this.quizId,
    required this.startedAt,
    this.completedAt,
    required this.status,
    required this.currentAnswers,
    required this.currentQuestionIndex,
  });

  bool get isInProgress =>
      completedAt == null && status == QuizResultStatus.completed;
  bool get isCompleted => completedAt != null;

  Map<String, dynamic> toMap() {
    return {
      'attemptId': attemptId,
      'userId': userId,
      'quizId': quizId,
      'startedAt': startedAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'status': status.name,
      'currentAnswers': currentAnswers.map((answer) => answer.toMap()).toList(),
      'currentQuestionIndex': currentQuestionIndex,
    };
  }

  factory QuizAttempt.fromMap(Map<String, dynamic> map) {
    return QuizAttempt(
      attemptId: map['attemptId'] ?? '',
      userId: map['userId'] ?? '',
      quizId: map['quizId'] ?? '',
      startedAt: DateTime.parse(map['startedAt']),
      completedAt: map['completedAt'] != null
          ? DateTime.parse(map['completedAt'])
          : null,
      status: QuizResultStatus.values.firstWhere(
        (status) => status.name == map['status'],
        orElse: () => QuizResultStatus.abandoned,
      ),
      currentAnswers:
          (map['currentAnswers'] as List<dynamic>?)
              ?.map(
                (answer) => UserAnswer.fromMap(answer as Map<String, dynamic>),
              )
              .toList() ??
          [],
      currentQuestionIndex: map['currentQuestionIndex']?.toInt() ?? 0,
    );
  }
}
