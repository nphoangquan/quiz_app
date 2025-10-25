import '../../domain/entities/quiz_entity.dart';
import '../../domain/entities/question_entity.dart';
import '../../domain/repositories/quiz_repository.dart';
import '../services/firebase_quiz_service.dart';

class QuizRepositoryImpl implements QuizRepository {
  final FirebaseQuizService _quizService;

  QuizRepositoryImpl(this._quizService);

  @override
  Future<String> createQuiz(QuizEntity quiz) {
    return _quizService.createQuiz(quiz);
  }

  @override
  Future<void> updateQuiz(String quizId, QuizEntity quiz) {
    return _quizService.updateQuiz(quizId, quiz);
  }

  @override
  Future<void> updateQuizWithQuestions(
    String quizId,
    QuizEntity quiz,
    List<QuestionEntity> questions,
  ) {
    return _quizService.updateQuizWithQuestions(quizId, quiz, questions);
  }

  @override
  Future<void> deleteQuiz(String quizId) {
    return _quizService.deleteQuiz(quizId);
  }

  @override
  Future<QuizEntity?> getQuiz(String quizId) {
    return _quizService.getQuiz(quizId);
  }

  @override
  Stream<List<QuizEntity>> getPublicQuizzes({
    QuizCategory? category,
    QuizDifficulty? difficulty,
    String? searchQuery,
    int limit = 20,
  }) {
    return _quizService.getPublicQuizzes(
      category: category,
      difficulty: difficulty,
      searchQuery: searchQuery,
      limit: limit,
    );
  }

  @override
  Stream<List<QuizEntity>> getUserQuizzes(String userId) {
    return _quizService.getUserQuizzes(userId);
  }

  @override
  Stream<List<QuizEntity>> getFeaturedQuizzes({int limit = 5}) {
    return _quizService.getFeaturedQuizzes(limit: limit);
  }

  @override
  Future<List<QuizEntity>> searchQuizzes(
    String searchQuery, {
    QuizCategory? category,
    QuizDifficulty? difficulty,
    int limit = 20,
  }) {
    return _quizService.searchQuizzes(
      searchQuery,
      category: category,
      difficulty: difficulty,
      limit: limit,
    );
  }

  @override
  Future<String> addQuestion(String quizId, QuestionEntity question) {
    return _quizService.addQuestion(quizId, question);
  }

  @override
  Future<void> updateQuestion(
    String quizId,
    String questionId,
    QuestionEntity question,
  ) {
    return _quizService.updateQuestion(quizId, questionId, question);
  }

  @override
  Future<void> deleteQuestion(String quizId, String questionId) {
    return _quizService.deleteQuestion(quizId, questionId);
  }

  @override
  Stream<List<QuestionEntity>> getQuizQuestions(String quizId) {
    return _quizService.getQuizQuestions(quizId);
  }

  @override
  Future<List<QuestionEntity>> getQuizQuestionsOnce(String quizId) {
    return _quizService.getQuizQuestionsOnce(quizId);
  }

  @override
  Future<void> updateQuizStats(
    String quizId, {
    int? totalAttempts,
    double? averageScore,
    int? likes,
    double? rating,
    int? ratingCount,
  }) {
    return _quizService.updateQuizStats(
      quizId,
      totalAttempts: totalAttempts,
      averageScore: averageScore,
      likes: likes,
      rating: rating,
      ratingCount: ratingCount,
    );
  }
}
