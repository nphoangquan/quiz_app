import 'package:flutter/foundation.dart';
import '../../domain/entities/result_entity.dart';
import '../../domain/repositories/result_repository.dart';

enum ResultState { idle, loading, success, error }

class ResultProvider with ChangeNotifier {
  final ResultRepository _resultRepository;

  ResultProvider(this._resultRepository);

  // State management
  ResultState _state = ResultState.idle;
  String? _errorMessage;

  // Results data
  List<ResultEntity> _userResults = [];
  List<ResultEntity> _quizResults = [];
  List<ResultEntity> _recentResults = [];
  List<ResultEntity> _leaderboard = [];
  Map<String, dynamic> _quizStatistics = {};

  // Getters
  ResultState get state => _state;
  String? get errorMessage => _errorMessage;
  List<ResultEntity> get userResults => _userResults;
  List<ResultEntity> get quizResults => _quizResults;
  List<ResultEntity> get recentResults => _recentResults;
  List<ResultEntity> get leaderboard => _leaderboard;
  Map<String, dynamic> get quizStatistics => _quizStatistics;

  bool get isLoading => _state == ResultState.loading;
  bool get hasError => _state == ResultState.error;

  // Set state helper
  void _setState(ResultState newState, [String? error]) {
    _state = newState;
    _errorMessage = error;
    notifyListeners();
  }

  /// Load user's results
  void loadUserResults(String userId) {
    _resultRepository
        .getUserResults(userId)
        .listen(
          (results) {
            _userResults = results;
            notifyListeners();
          },
          onError: (error) {
            _setState(ResultState.error, error.toString());
          },
        );
  }

  /// Load results for a specific quiz
  void loadQuizResults(String quizId) {
    _resultRepository
        .getQuizResults(quizId)
        .listen(
          (results) {
            _quizResults = results;
            notifyListeners();
          },
          onError: (error) {
            _setState(ResultState.error, error.toString());
          },
        );
  }

  /// Load recent results for dashboard
  Future<void> loadRecentResults(String userId, {int limit = 5}) async {
    _setState(ResultState.loading);

    try {
      _recentResults = await _resultRepository.getRecentResults(
        userId,
        limit: limit,
      );
      _setState(ResultState.success);
    } catch (e) {
      _setState(ResultState.error, e.toString());
    }
  }

  /// Load leaderboard for a quiz
  Future<void> loadQuizLeaderboard(String quizId, {int limit = 10}) async {
    _setState(ResultState.loading);

    try {
      _leaderboard = await _resultRepository.getQuizLeaderboard(
        quizId,
        limit: limit,
      );
      _setState(ResultState.success);
    } catch (e) {
      _setState(ResultState.error, e.toString());
    }
  }

  /// Load quiz statistics
  Future<void> loadQuizStatistics(String quizId) async {
    _setState(ResultState.loading);

    try {
      _quizStatistics = await _resultRepository.getQuizStatistics(quizId);
      _setState(ResultState.success);
    } catch (e) {
      _setState(ResultState.error, e.toString());
    }
  }

  /// Get user's best result for a specific quiz
  Future<ResultEntity?> getUserBestResult(String userId, String quizId) async {
    try {
      return await _resultRepository.getUserBestResult(userId, quizId);
    } catch (e) {
      _setState(ResultState.error, e.toString());
      return null;
    }
  }

  /// Get user's latest result for a specific quiz
  Future<ResultEntity?> getUserLatestResult(
    String userId,
    String quizId,
  ) async {
    try {
      return await _resultRepository.getUserQuizResult(userId, quizId);
    } catch (e) {
      _setState(ResultState.error, e.toString());
      return null;
    }
  }

  /// Delete a result
  Future<bool> deleteResult(String resultId) async {
    _setState(ResultState.loading);

    try {
      await _resultRepository.deleteResult(resultId);

      // Remove from local lists
      _userResults.removeWhere((result) => result.resultId == resultId);
      _quizResults.removeWhere((result) => result.resultId == resultId);
      _recentResults.removeWhere((result) => result.resultId == resultId);
      _leaderboard.removeWhere((result) => result.resultId == resultId);

      _setState(ResultState.success);
      return true;
    } catch (e) {
      _setState(ResultState.error, e.toString());
      return false;
    }
  }

  /// Get user performance analytics
  Map<String, dynamic> getUserPerformanceAnalytics(String userId) {
    final userResultsList = _userResults
        .where((result) => result.userId == userId)
        .toList();

    if (userResultsList.isEmpty) {
      return {
        'totalQuizzesTaken': 0,
        'averageScore': 0.0,
        'averagePercentage': 0.0,
        'totalTimeSpent': 0,
        'bestScore': 0,
        'worstScore': 0,
        'improvementTrend': 0.0,
        'categoryPerformance': <String, dynamic>{},
        'recentActivity': <ResultEntity>[],
      };
    }

    final totalQuizzes = userResultsList.length;
    final totalScore = userResultsList.fold(
      0,
      (sum, result) => sum + result.score,
    );
    final totalPercentage = userResultsList.fold(
      0.0,
      (sum, result) => sum + result.percentage,
    );
    final totalTimeSpent = userResultsList.fold(
      0,
      (sum, result) => sum + result.totalTimeSpent,
    );

    final scores = userResultsList.map((r) => r.score).toList();
    scores.sort();

    final percentages = userResultsList.map((r) => r.percentage).toList();
    percentages.sort();

    // Calculate improvement trend (compare first half vs second half)
    double improvementTrend = 0.0;
    if (totalQuizzes >= 4) {
      final sortedByDate = List<ResultEntity>.from(userResultsList);
      sortedByDate.sort((a, b) => a.completedAt.compareTo(b.completedAt));

      final halfPoint = totalQuizzes ~/ 2;
      final firstHalf = sortedByDate.take(halfPoint);
      final secondHalf = sortedByDate.skip(halfPoint);

      final firstHalfAvg =
          firstHalf.fold(0.0, (sum, r) => sum + r.percentage) /
          firstHalf.length;
      final secondHalfAvg =
          secondHalf.fold(0.0, (sum, r) => sum + r.percentage) /
          secondHalf.length;

      improvementTrend = secondHalfAvg - firstHalfAvg;
    }

    // Category performance (would need quiz category data)
    final categoryPerformance = <String, dynamic>{};

    // Recent activity (last 5 results)
    final recentActivity = List<ResultEntity>.from(userResultsList);
    recentActivity.sort((a, b) => b.completedAt.compareTo(a.completedAt));

    return {
      'totalQuizzesTaken': totalQuizzes,
      'averageScore': totalScore / totalQuizzes,
      'averagePercentage': totalPercentage / totalQuizzes,
      'totalTimeSpent': totalTimeSpent,
      'bestScore': scores.isNotEmpty ? scores.last : 0,
      'worstScore': scores.isNotEmpty ? scores.first : 0,
      'bestPercentage': percentages.isNotEmpty ? percentages.last : 0.0,
      'worstPercentage': percentages.isNotEmpty ? percentages.first : 0.0,
      'improvementTrend': improvementTrend,
      'categoryPerformance': categoryPerformance,
      'recentActivity': recentActivity.take(5).toList(),
    };
  }

  /// Get quiz performance analytics
  Map<String, dynamic> getQuizPerformanceAnalytics(String quizId) {
    final quizResultsList = _quizResults
        .where((result) => result.quizId == quizId)
        .toList();

    if (quizResultsList.isEmpty) {
      return {
        'totalAttempts': 0,
        'averageScore': 0.0,
        'averagePercentage': 0.0,
        'averageTimeSpent': 0,
        'highestScore': 0,
        'lowestScore': 0,
        'passRate': 0.0,
        'difficultyRating': 0.0,
        'popularityTrend': <Map<String, dynamic>>[],
      };
    }

    final totalAttempts = quizResultsList.length;
    final totalScore = quizResultsList.fold(
      0,
      (sum, result) => sum + result.score,
    );
    final totalPercentage = quizResultsList.fold(
      0.0,
      (sum, result) => sum + result.percentage,
    );
    final totalTimeSpent = quizResultsList.fold(
      0,
      (sum, result) => sum + result.totalTimeSpent,
    );

    final scores = quizResultsList.map((r) => r.score).toList();
    scores.sort();

    final passedCount = quizResultsList
        .where((result) => result.isPassed)
        .length;
    final passRate = (passedCount / totalAttempts) * 100;

    // Difficulty rating based on average score and time spent
    final avgPercentage = totalPercentage / totalAttempts;
    final avgTimeSpent = totalTimeSpent / totalAttempts;
    final difficultyRating = (100 - avgPercentage) / 20; // Scale 1-5

    return {
      'totalAttempts': totalAttempts,
      'averageScore': totalScore / totalAttempts,
      'averagePercentage': avgPercentage,
      'averageTimeSpent': avgTimeSpent,
      'highestScore': scores.isNotEmpty ? scores.last : 0,
      'lowestScore': scores.isNotEmpty ? scores.first : 0,
      'passRate': passRate,
      'difficultyRating': difficultyRating.clamp(1.0, 5.0),
      'uniqueUsers': quizResultsList.map((r) => r.userId).toSet().length,
    };
  }

  /// Filter results by date range
  List<ResultEntity> filterResultsByDateRange(
    List<ResultEntity> results,
    DateTime startDate,
    DateTime endDate,
  ) {
    return results.where((result) {
      return result.completedAt.isAfter(startDate) &&
          result.completedAt.isBefore(endDate);
    }).toList();
  }

  /// Filter results by score range
  List<ResultEntity> filterResultsByScore(
    List<ResultEntity> results,
    int minScore,
    int maxScore,
  ) {
    return results.where((result) {
      return result.score >= minScore && result.score <= maxScore;
    }).toList();
  }

  /// Filter results by completion status
  List<ResultEntity> filterResultsByStatus(
    List<ResultEntity> results,
    QuizResultStatus status,
  ) {
    return results.where((result) => result.status == status).toList();
  }

  /// Clear error
  void clearError() {
    if (_state == ResultState.error) {
      _state = ResultState.idle;
      _errorMessage = null;
      notifyListeners();
    }
  }

  /// Clear all data
  void clearData() {
    _userResults = [];
    _quizResults = [];
    _recentResults = [];
    _leaderboard = [];
    _quizStatistics = {};
    _state = ResultState.idle;
    _errorMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    super.dispose();
  }
}
