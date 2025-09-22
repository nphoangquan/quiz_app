import 'package:flutter/foundation.dart';
import '../../domain/entities/quiz_entity.dart';
import '../../domain/entities/question_entity.dart';
import '../../domain/repositories/quiz_repository.dart';

enum QuizState { idle, loading, success, error }

class QuizProvider with ChangeNotifier {
  final QuizRepository _quizRepository;

  QuizProvider(this._quizRepository);

  // State management
  QuizState _state = QuizState.idle;
  String? _errorMessage;

  // Current quiz being created/edited
  QuizEntity? _currentQuiz;
  List<QuestionEntity> _currentQuestions = [];

  // Quiz lists
  List<QuizEntity> _userQuizzes = [];
  List<QuizEntity> _publicQuizzes = [];
  List<QuizEntity> _featuredQuizzes = [];

  // Search and filter
  String _searchQuery = '';
  QuizCategory? _selectedCategory;
  QuizDifficulty? _selectedDifficulty;

  // Getters
  QuizState get state => _state;
  String? get errorMessage => _errorMessage;
  QuizRepository get quizRepository => _quizRepository;
  QuizEntity? get currentQuiz => _currentQuiz;
  List<QuestionEntity> get currentQuestions => _currentQuestions;
  List<QuizEntity> get userQuizzes => _userQuizzes;
  List<QuizEntity> get publicQuizzes => _publicQuizzes;
  List<QuizEntity> get featuredQuizzes => _featuredQuizzes;
  String get searchQuery => _searchQuery;
  QuizCategory? get selectedCategory => _selectedCategory;
  QuizDifficulty? get selectedDifficulty => _selectedDifficulty;

  bool get isLoading => _state == QuizState.loading;
  bool get hasError => _state == QuizState.error;
  bool get canSaveQuiz =>
      _currentQuiz != null &&
      _currentQuiz!.title.isNotEmpty &&
      _currentQuiz!.description.isNotEmpty &&
      _currentQuestions.isNotEmpty;

  /// Get total questions count from all user quizzes
  int get totalQuestionsCount {
    return _userQuizzes.fold<int>(0, (sum, quiz) => sum + quiz.questionCount);
  }

  // Set state helper
  void _setState(QuizState newState, [String? error]) {
    _state = newState;
    _errorMessage = error;
    notifyListeners();
  }

  /// Update current quiz details
  void updateQuizDetails({
    String? title,
    String? description,
    List<String>? tags,
    String? categoryId,
    bool? isPublic,
    QuizDifficulty? difficulty,
  }) {
    if (_currentQuiz == null) {
      // Initialize a new quiz if it doesn't exist
      initializeNewQuiz();
      // Update with provided values
      if (title != null ||
          description != null ||
          tags != null ||
          categoryId != null ||
          isPublic != null ||
          difficulty != null) {
        updateQuizDetails(
          title: title,
          description: description,
          tags: tags,
          categoryId: categoryId,
          isPublic: isPublic,
          difficulty: difficulty,
        );
      }
      return;
    }

    _currentQuiz = QuizEntity(
      quizId: _currentQuiz!.quizId,
      title: title ?? _currentQuiz!.title,
      description: description ?? _currentQuiz!.description,
      ownerId: _currentQuiz!.ownerId,
      ownerName: _currentQuiz!.ownerName,
      ownerAvatar: _currentQuiz!.ownerAvatar,
      tags: tags ?? _currentQuiz!.tags,
      categoryId: categoryId ?? _currentQuiz!.categoryId,
      isPublic: isPublic ?? _currentQuiz!.isPublic,
      questionCount: _currentQuestions.length,
      difficulty: difficulty ?? _currentQuiz!.difficulty,
      createdAt: _currentQuiz!.createdAt,
      updatedAt: DateTime.now(),
      stats: _currentQuiz!.stats,
    );
    notifyListeners();
  }

  /// Add question to current quiz
  void addQuestion(QuestionEntity question) {
    final newQuestion = QuestionEntity(
      questionId: question.questionId,
      question: question.question,
      type: question.type,
      options: question.options,
      correctAnswerIndex: question.correctAnswerIndex,
      explanation: question.explanation,
      imageUrl: question.imageUrl,
      order: _currentQuestions.length,
      points: question.points,
      timeLimit: question.timeLimit,
    );

    _currentQuestions.add(newQuestion);

    // Update question count in quiz
    updateQuizDetails();
    notifyListeners();
  }

  /// Update question at index
  void updateQuestion(int index, QuestionEntity question) {
    if (index >= 0 && index < _currentQuestions.length) {
      _currentQuestions[index] = question;
      notifyListeners();
    }
  }

  /// Remove question at index
  void removeQuestion(int index) {
    if (index >= 0 && index < _currentQuestions.length) {
      _currentQuestions.removeAt(index);

      // Reorder remaining questions
      for (int i = 0; i < _currentQuestions.length; i++) {
        _currentQuestions[i] = QuestionEntity(
          questionId: _currentQuestions[i].questionId,
          question: _currentQuestions[i].question,
          type: _currentQuestions[i].type,
          options: _currentQuestions[i].options,
          correctAnswerIndex: _currentQuestions[i].correctAnswerIndex,
          explanation: _currentQuestions[i].explanation,
          imageUrl: _currentQuestions[i].imageUrl,
          order: i,
          points: _currentQuestions[i].points,
          timeLimit: _currentQuestions[i].timeLimit,
        );
      }

      // Update question count
      updateQuizDetails();
      notifyListeners();
    }
  }

  /// Reorder questions
  void reorderQuestions(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final question = _currentQuestions.removeAt(oldIndex);
    _currentQuestions.insert(newIndex, question);

    // Update order for all questions
    for (int i = 0; i < _currentQuestions.length; i++) {
      _currentQuestions[i] = QuestionEntity(
        questionId: _currentQuestions[i].questionId,
        question: _currentQuestions[i].question,
        type: _currentQuestions[i].type,
        options: _currentQuestions[i].options,
        correctAnswerIndex: _currentQuestions[i].correctAnswerIndex,
        explanation: _currentQuestions[i].explanation,
        imageUrl: _currentQuestions[i].imageUrl,
        order: i,
        points: _currentQuestions[i].points,
        timeLimit: _currentQuestions[i].timeLimit,
      );
    }

    notifyListeners();
  }

  /// Create quiz
  Future<String?> createQuiz() async {
    if (_currentQuiz == null || !canSaveQuiz) {
      _setState(QuizState.error, 'Quiz data is invalid');
      return null;
    }

    _setState(QuizState.loading);

    try {
      // Create quiz first
      final quizId = await _quizRepository.createQuiz(_currentQuiz!);

      // Add all questions
      for (final question in _currentQuestions) {
        await _quizRepository.addQuestion(quizId, question);
      }

      _setState(QuizState.success);

      // Refresh public quizzes to show the new quiz
      loadPublicQuizzes();

      // Clear current quiz
      _currentQuiz = null;
      _currentQuestions = [];

      return quizId;
    } catch (e) {
      _setState(QuizState.error, e.toString());
      return null;
    }
  }

  /// Load quiz for editing
  Future<void> loadQuizForEditing(String quizId) async {
    _setState(QuizState.loading);

    try {
      final quiz = await _quizRepository.getQuiz(quizId);
      if (quiz != null) {
        _currentQuiz = quiz;

        // Load questions
        final questions = await _quizRepository.getQuizQuestionsOnce(quizId);
        _currentQuestions = questions;

        _setState(QuizState.success);
      } else {
        _setState(QuizState.error, 'Quiz not found');
      }
    } catch (e) {
      _setState(QuizState.error, e.toString());
    }
  }

  /// Update existing quiz
  Future<bool> updateQuiz() async {
    if (_currentQuiz == null || _currentQuiz!.quizId.isEmpty) {
      _setState(QuizState.error, 'No quiz to update');
      return false;
    }

    _setState(QuizState.loading);

    try {
      // Use batch operations for better performance
      await _quizRepository.updateQuizWithQuestions(
        _currentQuiz!.quizId,
        _currentQuiz!,
        _currentQuestions,
      );

      _setState(QuizState.success);

      // Refresh quiz lists in background
      loadPublicQuizzes();
      loadUserQuizzes(''); // Will need current user ID

      return true;
    } catch (e) {
      _setState(QuizState.error, e.toString());
      return false;
    }
  }

  /// Delete quiz
  Future<bool> deleteQuiz(String quizId) async {
    _setState(QuizState.loading);

    try {
      await _quizRepository.deleteQuiz(quizId);

      // Remove from user quizzes list
      _userQuizzes.removeWhere((quiz) => quiz.quizId == quizId);

      _setState(QuizState.success);
      return true;
    } catch (e) {
      _setState(QuizState.error, e.toString());
      return false;
    }
  }

  /// Load user's quizzes
  void loadUserQuizzes(String userId) {
    _quizRepository
        .getUserQuizzes(userId)
        .listen(
          (quizzes) {
            _userQuizzes = quizzes;
            notifyListeners();
          },
          onError: (error) {
            _setState(QuizState.error, error.toString());
          },
        );
  }

  /// Load public quizzes with optional filters
  void loadPublicQuizzes({
    QuizCategory? category,
    QuizDifficulty? difficulty,
    String? searchQuery,
    int limit = 20,
  }) {
    // Use provided parameters or fall back to instance variables
    final effectiveCategory = category ?? _selectedCategory;
    final effectiveDifficulty = difficulty ?? _selectedDifficulty;
    final effectiveSearchQuery =
        searchQuery ?? (_searchQuery.isEmpty ? null : _searchQuery);

    print(
      '🔍 Loading public quizzes with search: $effectiveSearchQuery, category: $effectiveCategory, difficulty: $effectiveDifficulty',
    );

    _setState(QuizState.loading);

    _quizRepository
        .getPublicQuizzes(
          category: effectiveCategory,
          difficulty: effectiveDifficulty,
          searchQuery: effectiveSearchQuery,
          limit: limit,
        )
        .listen(
          (quizzes) {
            _publicQuizzes = quizzes;
            _setState(QuizState.success);
          },
          onError: (error) {
            _setState(QuizState.error, error.toString());
          },
        );
  }

  /// Load featured quizzes
  void loadFeaturedQuizzes() {
    _quizRepository.getFeaturedQuizzes().listen(
      (quizzes) {
        _featuredQuizzes = quizzes;
        notifyListeners();
      },
      onError: (error) {
        _setState(QuizState.error, error.toString());
      },
    );
  }

  /// Search quizzes
  Future<List<QuizEntity>> searchQuizzes(String query) async {
    if (query.isEmpty) return [];

    try {
      return await _quizRepository.searchQuizzes(
        query,
        category: _selectedCategory,
        difficulty: _selectedDifficulty,
      );
    } catch (e) {
      _setState(QuizState.error, e.toString());
      return [];
    }
  }

  /// Update search and filter
  void updateSearch(String query) {
    _searchQuery = query;
    loadPublicQuizzes(); // Reload with new search
  }

  void updateCategoryFilter(QuizCategory? category) {
    _selectedCategory = category;
    loadPublicQuizzes(); // Reload with new filter
  }

  void updateDifficultyFilter(QuizDifficulty? difficulty) {
    _selectedDifficulty = difficulty;
    loadPublicQuizzes(); // Reload with new filter
  }

  void clearFilters() {
    _searchQuery = '';
    _selectedCategory = null;
    _selectedDifficulty = null;
    loadPublicQuizzes();
  }

  /// Clear current quiz (cancel creation/editing)
  void clearCurrentQuiz() {
    _currentQuiz = null;
    _currentQuestions = [];
    _state = QuizState.idle;
    _errorMessage = null;
    notifyListeners();
  }

  /// Initialize new quiz
  void initializeNewQuiz([String? ownerId, String? ownerName]) {
    _currentQuiz = QuizEntity(
      quizId: '',
      title: '',
      description: '',
      ownerId: ownerId ?? '',
      ownerName: ownerName ?? '',
      categoryId: null, // Will be set when user selects category
      difficulty: QuizDifficulty.beginner,
      tags: [],
      isPublic: true,
      questionCount: 0,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      stats: const QuizStats(
        totalAttempts: 0,
        averageScore: 0.0,
        likes: 0,
        shares: 0,
        rating: 0.0,
        ratingCount: 0,
      ),
    );
    _currentQuestions = [];
    _state = QuizState.idle;
    _errorMessage = null;
    notifyListeners();
  }

  // Search and filter methods
  void updateSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  /// Clear all filters and reload
  void clearAllFilters() {
    _searchQuery = '';
    _selectedCategory = null;
    _selectedDifficulty = null;
    loadPublicQuizzes();
  }

  /// Get quizzes by category ID
  List<QuizEntity> getQuizzesByCategoryId(String? categoryId) {
    if (categoryId == null) return _publicQuizzes;
    return _publicQuizzes
        .where((quiz) => quiz.categoryId == categoryId)
        .toList();
  }

  /// Get quiz count by category ID
  int getQuizCountByCategoryId(String? categoryId) {
    if (categoryId == null) return _publicQuizzes.length;
    return _publicQuizzes.where((quiz) => quiz.categoryId == categoryId).length;
  }

  /// Clear error
  void clearError() {
    if (_state == QuizState.error) {
      _state = QuizState.idle;
      _errorMessage = null;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    super.dispose();
  }
}
