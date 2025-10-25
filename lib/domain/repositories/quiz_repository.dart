import '../entities/quiz_entity.dart';
import '../entities/question_entity.dart';

abstract class QuizRepository {
  // Quiz CRUD operations
  Future<String> createQuiz(QuizEntity quiz);
  Future<void> updateQuiz(String quizId, QuizEntity quiz);
  Future<void> updateQuizWithQuestions(
    String quizId,
    QuizEntity quiz,
    List<QuestionEntity> questions,
  );
  Future<void> deleteQuiz(String quizId);
  Future<QuizEntity?> getQuiz(String quizId);

  // Quiz queries
  Stream<List<QuizEntity>> getPublicQuizzes({
    QuizCategory? category,
    QuizDifficulty? difficulty,
    String? searchQuery,
    int limit = 20,
  });

  Stream<List<QuizEntity>> getUserQuizzes(String userId);
  Stream<List<QuizEntity>> getFeaturedQuizzes({int limit = 5});
  Future<List<QuizEntity>> searchQuizzes(
    String searchQuery, {
    QuizCategory? category,
    QuizDifficulty? difficulty,
    int limit = 20,
  });

  // Question operations
  Future<String> addQuestion(String quizId, QuestionEntity question);
  Future<void> updateQuestion(
    String quizId,
    String questionId,
    QuestionEntity question,
  );
  Future<void> deleteQuestion(String quizId, String questionId);
  Stream<List<QuestionEntity>> getQuizQuestions(String quizId);
  Future<List<QuestionEntity>> getQuizQuestionsOnce(String quizId);

  // Quiz stats
  Future<void> updateQuizStats(
    String quizId, {
    int? totalAttempts,
    double? averageScore,
    int? likes,
    double? rating,
    int? ratingCount,
  });
}
