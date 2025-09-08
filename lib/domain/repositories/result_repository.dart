import '../entities/result_entity.dart';

abstract class ResultRepository {
  // Result operations
  Future<String> saveResult(ResultEntity result);
  Future<void> deleteResult(String resultId);

  // Result queries
  Stream<List<ResultEntity>> getUserResults(String userId);
  Stream<List<ResultEntity>> getQuizResults(String quizId);
  Future<ResultEntity?> getUserQuizResult(String userId, String quizId);
  Future<ResultEntity?> getUserBestResult(String userId, String quizId);
  Future<List<ResultEntity>> getRecentResults(String userId, {int limit = 5});
  Future<List<ResultEntity>> getQuizLeaderboard(
    String quizId, {
    int limit = 10,
  });

  // Statistics
  Future<Map<String, dynamic>> getQuizStatistics(String quizId);

  // Quiz attempts (in-progress)
  Future<String> saveQuizAttempt(QuizAttempt attempt);
  Future<QuizAttempt?> getUserQuizAttempt(String userId, String quizId);
  Future<void> deleteQuizAttempt(String attemptId);
}
