import '../../domain/entities/result_entity.dart';
import '../../domain/repositories/result_repository.dart';
import '../services/firebase_result_service.dart';

class ResultRepositoryImpl implements ResultRepository {
  final FirebaseResultService _resultService;

  ResultRepositoryImpl(this._resultService);

  @override
  Future<String> saveResult(ResultEntity result) {
    return _resultService.saveResult(result);
  }

  @override
  Future<void> deleteResult(String resultId) {
    return _resultService.deleteResult(resultId);
  }

  @override
  Stream<List<ResultEntity>> getUserResults(String userId) {
    return _resultService.getUserResults(userId);
  }

  @override
  Stream<List<ResultEntity>> getQuizResults(String quizId) {
    return _resultService.getQuizResults(quizId);
  }

  @override
  Future<ResultEntity?> getUserQuizResult(String userId, String quizId) {
    return _resultService.getUserQuizResult(userId, quizId);
  }

  @override
  Future<ResultEntity?> getUserBestResult(String userId, String quizId) {
    return _resultService.getUserBestResult(userId, quizId);
  }

  @override
  Future<List<ResultEntity>> getRecentResults(String userId, {int limit = 5}) {
    return _resultService.getRecentResults(userId, limit: limit);
  }

  @override
  Future<List<ResultEntity>> getQuizLeaderboard(
    String quizId, {
    int limit = 10,
  }) {
    return _resultService.getQuizLeaderboard(quizId, limit: limit);
  }

  @override
  Future<Map<String, dynamic>> getQuizStatistics(String quizId) {
    return _resultService.getQuizStatistics(quizId);
  }

  @override
  Future<String> saveQuizAttempt(QuizAttempt attempt) {
    return _resultService.saveQuizAttempt(attempt);
  }

  @override
  Future<QuizAttempt?> getUserQuizAttempt(String userId, String quizId) {
    return _resultService.getUserQuizAttempt(userId, quizId);
  }

  @override
  Future<void> deleteQuizAttempt(String attemptId) {
    return _resultService.deleteQuizAttempt(attemptId);
  }
}
