import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/quiz_entity.dart';
import '../../domain/entities/question_entity.dart';
import '../models/quiz_model.dart';
import '../models/question_model.dart';

class FirebaseQuizService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collections
  CollectionReference get _quizzesCollection =>
      _firestore.collection('quizzes');
  CollectionReference _questionsCollection(String quizId) =>
      _quizzesCollection.doc(quizId).collection('questions');

  /// Create a new quiz
  Future<String> createQuiz(QuizEntity quiz) async {
    try {
      final quizModel = QuizModel.fromEntity(quiz);
      final docRef = await _quizzesCollection.add(quizModel.toFirestore());
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create quiz: $e');
    }
  }

  /// Update existing quiz
  Future<void> updateQuiz(String quizId, QuizEntity quiz) async {
    try {
      final quizModel = QuizModel.fromEntity(quiz);
      await _quizzesCollection.doc(quizId).update(quizModel.toFirestore());
    } catch (e) {
      throw Exception('Failed to update quiz: $e');
    }
  }

  /// Delete quiz and all its questions
  Future<void> deleteQuiz(String quizId) async {
    try {
      // Delete all questions first
      final questionsSnapshot = await _questionsCollection(quizId).get();
      for (var doc in questionsSnapshot.docs) {
        await doc.reference.delete();
      }

      // Then delete the quiz
      await _quizzesCollection.doc(quizId).delete();
    } catch (e) {
      throw Exception('Failed to delete quiz: $e');
    }
  }

  /// Get quiz by ID
  Future<QuizEntity?> getQuiz(String quizId) async {
    try {
      final doc = await _quizzesCollection.doc(quizId).get();
      if (doc.exists) {
        return QuizModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get quiz: $e');
    }
  }

  /// Get all public quizzes
  Stream<List<QuizEntity>> getPublicQuizzes({
    QuizCategory? category,
    QuizDifficulty? difficulty,
    String? searchQuery,
    int limit = 20,
  }) {
    try {
      Query query = _quizzesCollection
          .where('isPublic', isEqualTo: true)
          .orderBy('createdAt', descending: true);

      if (category != null) {
        query = query.where('category', isEqualTo: category.name);
      }

      if (difficulty != null) {
        query = query.where('difficulty', isEqualTo: difficulty.name);
      }

      query = query.limit(limit);

      return query.snapshots().map((snapshot) {
        final quizzes = snapshot.docs
            .map((doc) => QuizModel.fromFirestore(doc))
            .where((quiz) {
              if (searchQuery != null && searchQuery.isNotEmpty) {
                return quiz.title.toLowerCase().contains(
                      searchQuery.toLowerCase(),
                    ) ||
                    quiz.description.toLowerCase().contains(
                      searchQuery.toLowerCase(),
                    );
              }
              return true;
            })
            .toList();

        return quizzes;
      });
    } catch (e) {
      throw Exception('Failed to get public quizzes: $e');
    }
  }

  /// Get quizzes by user ID
  Stream<List<QuizEntity>> getUserQuizzes(String userId) {
    try {
      return _quizzesCollection
          .where('ownerId', isEqualTo: userId)
          .orderBy('updatedAt', descending: true)
          .snapshots()
          .map((snapshot) {
            return snapshot.docs
                .map((doc) => QuizModel.fromFirestore(doc))
                .toList();
          });
    } catch (e) {
      throw Exception('Failed to get user quizzes: $e');
    }
  }

  /// Get featured quizzes (high rating, popular)
  Stream<List<QuizEntity>> getFeaturedQuizzes({int limit = 5}) {
    try {
      return _quizzesCollection
          .where('isPublic', isEqualTo: true)
          .where('stats.rating', isGreaterThan: 4.0)
          .orderBy('stats.rating', descending: true)
          .orderBy('stats.totalAttempts', descending: true)
          .limit(limit)
          .snapshots()
          .map((snapshot) {
            return snapshot.docs
                .map((doc) => QuizModel.fromFirestore(doc))
                .toList();
          });
    } catch (e) {
      throw Exception('Failed to get featured quizzes: $e');
    }
  }

  /// Add question to quiz
  Future<String> addQuestion(String quizId, QuestionEntity question) async {
    try {
      final questionModel = QuestionModel.fromEntity(question);
      final docRef = await _questionsCollection(
        quizId,
      ).add(questionModel.toFirestore());

      // Update question count in quiz
      await _updateQuestionCount(quizId);

      return docRef.id;
    } catch (e) {
      throw Exception('Failed to add question: $e');
    }
  }

  /// Update question
  Future<void> updateQuestion(
    String quizId,
    String questionId,
    QuestionEntity question,
  ) async {
    try {
      final questionModel = QuestionModel.fromEntity(question);
      await _questionsCollection(
        quizId,
      ).doc(questionId).update(questionModel.toFirestore());
    } catch (e) {
      throw Exception('Failed to update question: $e');
    }
  }

  /// Delete question
  Future<void> deleteQuestion(String quizId, String questionId) async {
    try {
      await _questionsCollection(quizId).doc(questionId).delete();

      // Update question count in quiz
      await _updateQuestionCount(quizId);
    } catch (e) {
      throw Exception('Failed to delete question: $e');
    }
  }

  /// Get all questions for a quiz
  Stream<List<QuestionEntity>> getQuizQuestions(String quizId) {
    try {
      return _questionsCollection(quizId).orderBy('order').snapshots().map((
        snapshot,
      ) {
        return snapshot.docs
            .map((doc) => QuestionModel.fromFirestore(doc))
            .toList();
      });
    } catch (e) {
      throw Exception('Failed to get quiz questions: $e');
    }
  }

  /// Get questions as a one-time fetch (for quiz playing)
  Future<List<QuestionEntity>> getQuizQuestionsOnce(String quizId) async {
    try {
      final snapshot = await _questionsCollection(
        quizId,
      ).orderBy('order').get();

      return snapshot.docs
          .map((doc) => QuestionModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to get quiz questions: $e');
    }
  }

  /// Update question count in quiz document
  Future<void> _updateQuestionCount(String quizId) async {
    try {
      final questionsSnapshot = await _questionsCollection(quizId).get();
      final questionCount = questionsSnapshot.docs.length;

      await _quizzesCollection.doc(quizId).update({
        'questionCount': questionCount,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update question count: $e');
    }
  }

  /// Update quiz stats (likes, attempts, rating)
  Future<void> updateQuizStats(
    String quizId, {
    int? totalAttempts,
    double? averageScore,
    int? likes,
    double? rating,
    int? ratingCount,
  }) async {
    try {
      final Map<String, dynamic> updates = {
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (totalAttempts != null) {
        updates['stats.totalAttempts'] = totalAttempts;
      }
      if (averageScore != null) {
        updates['stats.averageScore'] = averageScore;
      }
      if (likes != null) {
        updates['stats.likes'] = likes;
      }
      if (rating != null) {
        updates['stats.rating'] = rating;
      }
      if (ratingCount != null) {
        updates['stats.ratingCount'] = ratingCount;
      }

      await _quizzesCollection.doc(quizId).update(updates);
    } catch (e) {
      throw Exception('Failed to update quiz stats: $e');
    }
  }

  /// Search quizzes
  Future<List<QuizEntity>> searchQuizzes(
    String searchQuery, {
    QuizCategory? category,
    QuizDifficulty? difficulty,
    int limit = 20,
  }) async {
    try {
      Query query = _quizzesCollection
          .where('isPublic', isEqualTo: true)
          .limit(limit);

      if (category != null) {
        query = query.where('category', isEqualTo: category.name);
      }

      if (difficulty != null) {
        query = query.where('difficulty', isEqualTo: difficulty.name);
      }

      final snapshot = await query.get();

      return snapshot.docs.map((doc) => QuizModel.fromFirestore(doc)).where((
        quiz,
      ) {
        return quiz.title.toLowerCase().contains(searchQuery.toLowerCase()) ||
            quiz.description.toLowerCase().contains(
              searchQuery.toLowerCase(),
            ) ||
            quiz.tags.any(
              (tag) => tag.toLowerCase().contains(searchQuery.toLowerCase()),
            );
      }).toList();
    } catch (e) {
      throw Exception('Failed to search quizzes: $e');
    }
  }
}
