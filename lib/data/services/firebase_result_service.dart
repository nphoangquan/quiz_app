import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/result_entity.dart';
import '../../domain/entities/question_entity.dart';
import '../models/result_model.dart';

class FirebaseResultService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collections
  CollectionReference get _resultsCollection =>
      _firestore.collection('results');
  CollectionReference get _usersCollection => _firestore.collection('users');

  /// Save quiz result
  Future<String> saveResult(ResultEntity result) async {
    try {
      final resultModel = ResultModel.fromEntity(result);
      final docRef = await _resultsCollection.add(resultModel.toFirestore());

      // Update user stats
      await _updateUserStats(result.userId, result);

      return docRef.id;
    } catch (e) {
      throw Exception('Failed to save result: $e');
    }
  }

  /// Get user's quiz results
  Stream<List<ResultEntity>> getUserResults(String userId) {
    try {
      return _resultsCollection
          .where('userId', isEqualTo: userId)
          .orderBy('completedAt', descending: true)
          .snapshots()
          .map((snapshot) {
            return snapshot.docs
                .map((doc) => ResultModel.fromFirestore(doc))
                .toList();
          });
    } catch (e) {
      throw Exception('Failed to get user results: $e');
    }
  }

  /// Get results for a specific quiz
  Stream<List<ResultEntity>> getQuizResults(String quizId) {
    try {
      return _resultsCollection
          .where('quizId', isEqualTo: quizId)
          .orderBy('completedAt', descending: true)
          .snapshots()
          .map((snapshot) {
            return snapshot.docs
                .map((doc) => ResultModel.fromFirestore(doc))
                .toList();
          });
    } catch (e) {
      throw Exception('Failed to get quiz results: $e');
    }
  }

  /// Get user's result for a specific quiz
  Future<ResultEntity?> getUserQuizResult(String userId, String quizId) async {
    try {
      final snapshot = await _resultsCollection
          .where('userId', isEqualTo: userId)
          .where('quizId', isEqualTo: quizId)
          .orderBy('completedAt', descending: true)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        return ResultModel.fromFirestore(snapshot.docs.first);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get user quiz result: $e');
    }
  }

  /// Get user's best result for a specific quiz
  Future<ResultEntity?> getUserBestResult(String userId, String quizId) async {
    try {
      final snapshot = await _resultsCollection
          .where('userId', isEqualTo: userId)
          .where('quizId', isEqualTo: quizId)
          .orderBy('score', descending: true)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        return ResultModel.fromFirestore(snapshot.docs.first);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get user best result: $e');
    }
  }

  /// Get recent results for user (for dashboard)
  Future<List<ResultEntity>> getRecentResults(
    String userId, {
    int limit = 5,
  }) async {
    try {
      final snapshot = await _resultsCollection
          .where('userId', isEqualTo: userId)
          .orderBy('completedAt', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => ResultModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to get recent results: $e');
    }
  }

  /// Calculate quiz statistics
  Future<Map<String, dynamic>> getQuizStatistics(String quizId) async {
    try {
      final snapshot = await _resultsCollection
          .where('quizId', isEqualTo: quizId)
          .get();

      if (snapshot.docs.isEmpty) {
        return {
          'totalAttempts': 0,
          'averageScore': 0.0,
          'averagePercentage': 0.0,
          'highestScore': 0,
          'lowestScore': 0,
          'averageTimeSpent': 0,
        };
      }

      final results = snapshot.docs
          .map((doc) => ResultModel.fromFirestore(doc))
          .toList();

      final totalAttempts = results.length;
      final totalScore = results.fold(0, (sum, result) => sum + result.score);
      final totalPercentage = results.fold(
        0.0,
        (sum, result) => sum + result.percentage,
      );
      final totalTimeSpent = results.fold(
        0,
        (sum, result) => sum + result.totalTimeSpent,
      );

      final scores = results.map((r) => r.score).toList();
      scores.sort();

      return {
        'totalAttempts': totalAttempts,
        'averageScore': totalScore / totalAttempts,
        'averagePercentage': totalPercentage / totalAttempts,
        'highestScore': scores.last,
        'lowestScore': scores.first,
        'averageTimeSpent': totalTimeSpent ~/ totalAttempts,
      };
    } catch (e) {
      throw Exception('Failed to get quiz statistics: $e');
    }
  }

  /// Update user statistics after completing a quiz
  Future<void> _updateUserStats(String userId, ResultEntity result) async {
    try {
      final userDoc = _usersCollection.doc(userId);

      await _firestore.runTransaction((transaction) async {
        final userSnapshot = await transaction.get(userDoc);

        if (userSnapshot.exists) {
          final userData = userSnapshot.data() as Map<String, dynamic>;
          final stats = userData['stats'] as Map<String, dynamic>? ?? {};

          // Update stats
          final currentQuizzesTaken = stats['quizzesTaken'] as int? ?? 0;
          final currentTotalScore = stats['totalScore'] as int? ?? 0;
          final currentExperience = stats['experience'] as int? ?? 0;

          // Calculate experience points (based on percentage)
          final experienceGained = (result.percentage * 10).round();
          final newExperience = currentExperience + experienceGained;
          final newLevel = (newExperience / 1000).floor() + 1;

          final updatedStats = {
            'quizzesTaken': currentQuizzesTaken + 1,
            'totalScore': currentTotalScore + result.score,
            'experience': newExperience,
            'level': newLevel,
          };

          transaction.update(userDoc, {
            'stats': updatedStats,
            'updatedAt': FieldValue.serverTimestamp(),
          });
        }
      });
    } catch (e) {
      throw Exception('Failed to update user stats: $e');
    }
  }

  /// Delete result
  Future<void> deleteResult(String resultId) async {
    try {
      await _resultsCollection.doc(resultId).delete();
    } catch (e) {
      throw Exception('Failed to delete result: $e');
    }
  }

  /// Get leaderboard for a quiz
  Future<List<ResultEntity>> getQuizLeaderboard(
    String quizId, {
    int limit = 10,
  }) async {
    try {
      final snapshot = await _resultsCollection
          .where('quizId', isEqualTo: quizId)
          .orderBy('score', descending: true)
          .orderBy(
            'timeSpent',
            descending: false,
          ) // Faster time is better for same score
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => ResultModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to get quiz leaderboard: $e');
    }
  }

  /// Save quiz attempt (for in-progress quizzes)
  Future<String> saveQuizAttempt(QuizAttempt attempt) async {
    try {
      final attemptData = {
        'userId': attempt.userId,
        'quizId': attempt.quizId,
        'currentQuestionIndex': attempt.currentQuestionIndex,
        'status': attempt.status.name,
        'currentAnswers': attempt.currentAnswers
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
        'startedAt': Timestamp.fromDate(attempt.startedAt),
        'completedAt': attempt.completedAt != null
            ? Timestamp.fromDate(attempt.completedAt!)
            : null,
        'lastUpdatedAt': FieldValue.serverTimestamp(),
      };

      final docRef = await _firestore
          .collection('quiz_attempts')
          .add(attemptData);

      return docRef.id;
    } catch (e) {
      throw Exception('Failed to save quiz attempt: $e');
    }
  }

  /// Get user's in-progress quiz attempt
  Future<QuizAttempt?> getUserQuizAttempt(String userId, String quizId) async {
    try {
      final snapshot = await _firestore
          .collection('quiz_attempts')
          .where('userId', isEqualTo: userId)
          .where('quizId', isEqualTo: quizId)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        final doc = snapshot.docs.first;
        final data = doc.data();

        return QuizAttempt(
          attemptId: doc.id,
          userId: data['userId'],
          quizId: data['quizId'],
          startedAt: (data['startedAt'] as Timestamp).toDate(),
          completedAt: data['completedAt'] != null
              ? (data['completedAt'] as Timestamp).toDate()
              : null,
          status: QuizResultStatus.values.firstWhere(
            (status) => status.name == data['status'],
            orElse: () => QuizResultStatus.completed,
          ),
          currentAnswers: (data['currentAnswers'] as List)
              .map(
                (answer) => UserAnswer(
                  questionId: answer['questionId'],
                  selectedAnswer: answer['selectedAnswer'],
                  selectedAnswerIndex: answer['selectedAnswerIndex'],
                  isCorrect: answer['isCorrect'],
                  timeSpent: answer['timeSpent'] ?? 0,
                  answeredAt: (answer['answeredAt'] as Timestamp).toDate(),
                ),
              )
              .toList(),
          currentQuestionIndex: data['currentQuestionIndex'],
        );
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get user quiz attempt: $e');
    }
  }

  /// Delete quiz attempt (when quiz is completed or abandoned)
  Future<void> deleteQuizAttempt(String attemptId) async {
    try {
      await _firestore.collection('quiz_attempts').doc(attemptId).delete();
    } catch (e) {
      throw Exception('Failed to delete quiz attempt: $e');
    }
  }
}
