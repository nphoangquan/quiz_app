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

  /// Clear error
  void clearError() {
    if (_state == ResultState.error) {
      _state = ResultState.idle;
      _errorMessage = null;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    super.dispose();
  }
}
