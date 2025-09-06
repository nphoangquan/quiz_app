enum QuestionType { multipleChoice, trueFalse, fillInTheBlank, matching }

class QuestionEntity {
  final String questionId;
  final String question;
  final QuestionType type;
  final List<String> options;
  final int correctAnswerIndex;
  final String? explanation;
  final String? imageUrl;
  final int order;
  final int points;
  final int timeLimit; // in seconds, 0 = no limit

  const QuestionEntity({
    required this.questionId,
    required this.question,
    required this.type,
    required this.options,
    required this.correctAnswerIndex,
    this.explanation,
    this.imageUrl,
    required this.order,
    this.points = 10,
    this.timeLimit = 0,
  });

  bool get isMultipleChoice => type == QuestionType.multipleChoice;
  bool get isTrueFalse => type == QuestionType.trueFalse;
  bool get hasTimed => timeLimit > 0;
  bool get hasImage => imageUrl != null && imageUrl!.isNotEmpty;
  bool get hasExplanation => explanation != null && explanation!.isNotEmpty;

  String get correctAnswer {
    if (correctAnswerIndex >= 0 && correctAnswerIndex < options.length) {
      return options[correctAnswerIndex];
    }
    return '';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is QuestionEntity && other.questionId == questionId;
  }

  @override
  int get hashCode => questionId.hashCode;

  @override
  String toString() {
    return 'QuestionEntity(questionId: $questionId, question: ${question.substring(0, 50)}...)';
  }
}

class UserAnswer {
  final String questionId;
  final int selectedAnswerIndex;
  final String selectedAnswer;
  final bool isCorrect;
  final int timeSpent; // in seconds
  final DateTime answeredAt;

  const UserAnswer({
    required this.questionId,
    required this.selectedAnswerIndex,
    required this.selectedAnswer,
    required this.isCorrect,
    required this.timeSpent,
    required this.answeredAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'questionId': questionId,
      'selectedAnswerIndex': selectedAnswerIndex,
      'selectedAnswer': selectedAnswer,
      'isCorrect': isCorrect,
      'timeSpent': timeSpent,
      'answeredAt': answeredAt.toIso8601String(),
    };
  }

  factory UserAnswer.fromMap(Map<String, dynamic> map) {
    return UserAnswer(
      questionId: map['questionId'] ?? '',
      selectedAnswerIndex: map['selectedAnswerIndex']?.toInt() ?? -1,
      selectedAnswer: map['selectedAnswer'] ?? '',
      isCorrect: map['isCorrect'] ?? false,
      timeSpent: map['timeSpent']?.toInt() ?? 0,
      answeredAt: DateTime.parse(map['answeredAt']),
    );
  }
}
