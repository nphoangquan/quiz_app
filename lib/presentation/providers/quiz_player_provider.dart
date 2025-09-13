import 'package:flutter/foundation.dart';
import '../../domain/entities/quiz_entity.dart';
import '../../domain/entities/question_entity.dart';
import '../../domain/entities/result_entity.dart';
import '../../domain/repositories/quiz_repository.dart';
import '../../domain/repositories/result_repository.dart';

enum QuizPlayerState { idle, loading, ready, playing, paused, completed, error }

class QuizPlayerProvider with ChangeNotifier {
  final QuizRepository _quizRepository;
  final ResultRepository _resultRepository;

  QuizPlayerProvider(this._quizRepository, this._resultRepository);

  // State management
  QuizPlayerState _state = QuizPlayerState.idle;
  String? _errorMessage;

  // Quiz data
  QuizEntity? _currentQuiz;
  List<QuestionEntity> _questions = [];

  // Player state
  int _currentQuestionIndex = 0;
  List<UserAnswer> _userAnswers = [];
  DateTime? _quizStartTime;
  DateTime? _questionStartTime;
  bool _isTimerEnabled = false;
  int _timeRemaining = 0; // in seconds

  // Results
  ResultEntity? _currentResult;

  // Getters
  QuizPlayerState get state => _state;
  String? get errorMessage => _errorMessage;
  QuizEntity? get currentQuiz => _currentQuiz;
  List<QuestionEntity> get questions => _questions;
  int get currentQuestionIndex => _currentQuestionIndex;
  List<UserAnswer> get userAnswers => _userAnswers;
  DateTime? get quizStartTime => _quizStartTime;
  bool get isTimerEnabled => _isTimerEnabled;
  int get timeRemaining => _timeRemaining;
  ResultEntity? get currentResult => _currentResult;

  // Computed getters
  bool get isLoading => _state == QuizPlayerState.loading;
  bool get isReady => _state == QuizPlayerState.ready;
  bool get isPlaying => _state == QuizPlayerState.playing;
  bool get isPaused => _state == QuizPlayerState.paused;
  bool get isCompleted => _state == QuizPlayerState.completed;
  bool get hasError => _state == QuizPlayerState.error;

  QuestionEntity? get currentQuestion =>
      _questions.isNotEmpty && _currentQuestionIndex < _questions.length
      ? _questions[_currentQuestionIndex]
      : null;

  int get totalQuestions => _questions.length;
  int get answeredQuestions => _userAnswers.length;
  double get progress =>
      totalQuestions > 0 ? answeredQuestions / totalQuestions : 0.0;

  bool get canGoNext => _currentQuestionIndex < _questions.length - 1;
  bool get canGoPrevious => _currentQuestionIndex > 0;
  bool get isLastQuestion => _currentQuestionIndex == _questions.length - 1;

  /// Check if quiz has any timed questions
  bool get hasTimedQuestions =>
      _questions.any((question) => question.timeLimit > 0);

  UserAnswer? get currentUserAnswer {
    try {
      return _userAnswers.firstWhere(
        (answer) => answer.questionId == currentQuestion?.questionId,
      );
    } catch (e) {
      return null;
    }
  }

  // Set state helper
  void _setState(QuizPlayerState newState, [String? error]) {
    _state = newState;
    _errorMessage = error;
    notifyListeners();
  }

  /// Initialize quiz for playing
  Future<void> initializeQuiz(String quizId, {bool enableTimer = false}) async {
    _setState(QuizPlayerState.loading);

    try {
      // Load quiz
      final quiz = await _quizRepository.getQuiz(quizId);
      if (quiz == null) {
        _setState(QuizPlayerState.error, 'Quiz not found');
        return;
      }

      // Load questions
      final questions = await _quizRepository.getQuizQuestionsOnce(quizId);
      if (questions.isEmpty) {
        _setState(QuizPlayerState.error, 'No questions found');
        return;
      }

      _currentQuiz = quiz;
      _questions = questions;
      _currentQuestionIndex = 0;
      _userAnswers = [];
      _isTimerEnabled = enableTimer;

      // Initialize timer for first question if enabled and has timed questions
      if (enableTimer && questions.isNotEmpty && questions[0].timeLimit > 0) {
        _timeRemaining = questions[0].timeLimit;
      } else {
        _timeRemaining = 0;
      }

      _currentResult = null;

      _setState(QuizPlayerState.ready);
    } catch (e) {
      _setState(QuizPlayerState.error, e.toString());
    }
  }

  /// Start quiz
  void startQuiz() {
    if (_state != QuizPlayerState.ready) return;

    _quizStartTime = DateTime.now();
    _questionStartTime = DateTime.now();

    // Only enable timer if quiz has timed questions
    if (_isTimerEnabled &&
        hasTimedQuestions &&
        currentQuestion?.timeLimit != null &&
        currentQuestion!.timeLimit > 0) {
      _timeRemaining = currentQuestion!.timeLimit;
    } else {
      _timeRemaining = 0;
    }

    _setState(QuizPlayerState.playing);
  }

  /// Resume quiz
  void resumeQuiz() {
    if (_state != QuizPlayerState.paused) return;

    _questionStartTime = DateTime.now();
    _setState(QuizPlayerState.playing);
  }

  /// Pause quiz
  void pauseQuiz() {
    if (_state != QuizPlayerState.playing) return;

    _setState(QuizPlayerState.paused);
  }

  /// Answer current question
  void answerQuestion({
    required int selectedAnswerIndex,
    String? selectedAnswer,
  }) {
    if (_state != QuizPlayerState.playing || currentQuestion == null) return;

    final question = currentQuestion!;
    final isCorrect = selectedAnswerIndex == question.correctAnswerIndex;
    final timeSpent = _questionStartTime != null
        ? DateTime.now().difference(_questionStartTime!).inSeconds
        : 0;

    // Remove existing answer for this question if any
    _userAnswers.removeWhere(
      (answer) => answer.questionId == question.questionId,
    );

    // Add new answer
    final userAnswer = UserAnswer(
      questionId: question.questionId,
      selectedAnswerIndex: selectedAnswerIndex,
      selectedAnswer:
          selectedAnswer ??
          (selectedAnswerIndex < question.options.length
              ? question.options[selectedAnswerIndex]
              : ''),
      isCorrect: isCorrect,
      timeSpent: timeSpent,
      answeredAt: DateTime.now(),
    );

    _userAnswers.add(userAnswer);
    notifyListeners();
  }

  /// Go to next question
  void nextQuestion() {
    if (!canGoNext) return;

    _currentQuestionIndex++;
    _questionStartTime = DateTime.now();

    // Update timer for new question
    if (_isTimerEnabled &&
        hasTimedQuestions &&
        currentQuestion?.timeLimit != null &&
        currentQuestion!.timeLimit > 0) {
      _timeRemaining = currentQuestion!.timeLimit;
    } else {
      _timeRemaining = 0;
    }

    notifyListeners();
  }

  /// Go to previous question
  void previousQuestion() {
    if (!canGoPrevious) return;

    _currentQuestionIndex--;
    _questionStartTime = DateTime.now();

    // Update timer for current question
    if (_isTimerEnabled &&
        currentQuestion?.timeLimit != null &&
        currentQuestion!.timeLimit > 0) {
      _timeRemaining = currentQuestion!.timeLimit;
    }

    notifyListeners();
  }

  /// Jump to specific question
  void jumpToQuestion(int index) {
    if (index < 0 || index >= _questions.length) return;

    _currentQuestionIndex = index;
    _questionStartTime = DateTime.now();

    // Update timer for current question
    if (_isTimerEnabled &&
        hasTimedQuestions &&
        currentQuestion?.timeLimit != null &&
        currentQuestion!.timeLimit > 0) {
      _timeRemaining = currentQuestion!.timeLimit;
    } else {
      _timeRemaining = 0;
    }

    notifyListeners();
  }

  /// Update timer (called by UI timer)
  void updateTimer(int remainingSeconds) {
    _timeRemaining = remainingSeconds;
    notifyListeners();

    // Auto-submit when time runs out
    if (_timeRemaining <= 0 && _state == QuizPlayerState.playing) {
      // Auto-answer with -1 (no answer) if no answer was given
      if (currentUserAnswer == null) {
        answerQuestion(selectedAnswerIndex: -1, selectedAnswer: 'Hết giờ');
      }

      if (isLastQuestion) {
        finishQuiz();
      } else {
        nextQuestion();
      }
    }
  }

  /// Finish quiz and calculate results
  Future<void> finishQuiz() async {
    if (_currentQuiz == null || _quizStartTime == null) return;

    _setState(QuizPlayerState.loading);

    try {
      // Calculate results
      final correctAnswers = _userAnswers
          .where((answer) => answer.isCorrect)
          .length;
      final totalTimeSpent = DateTime.now()
          .difference(_quizStartTime!)
          .inSeconds;
      final score = correctAnswers * 10; // 10 points per correct answer
      final percentage = totalQuestions > 0
          ? (correctAnswers / totalQuestions) * 100
          : 0.0;

      // Create result entity
      _currentResult = ResultEntity(
        resultId: '',
        userId: _currentQuiz!.ownerId, // This should be current user ID
        quizId: _currentQuiz!.quizId,
        quizTitle: _currentQuiz!.title,
        score: score,
        totalQuestions: totalQuestions,
        correctAnswers: correctAnswers,
        totalTimeSpent: totalTimeSpent,
        percentage: percentage,
        status: QuizResultStatus.completed,
        answers: _userAnswers,
        startedAt: _quizStartTime!,
        completedAt: DateTime.now(),
      );

      // Save result to Firestore
      await _resultRepository.saveResult(_currentResult!);

      _setState(QuizPlayerState.completed);
    } catch (e) {
      _setState(QuizPlayerState.error, e.toString());
    }
  }

  /// Abandon quiz
  Future<void> abandonQuiz() async {
    if (_currentQuiz == null || _quizStartTime == null) return;

    try {
      // Save partial result if any answers were given
      if (_userAnswers.isNotEmpty) {
        final correctAnswers = _userAnswers
            .where((answer) => answer.isCorrect)
            .length;
        final totalTimeSpent = DateTime.now()
            .difference(_quizStartTime!)
            .inSeconds;
        final score = correctAnswers * 10;
        final percentage = totalQuestions > 0
            ? (correctAnswers / totalQuestions) * 100
            : 0.0;

        final result = ResultEntity(
          resultId: '',
          userId: _currentQuiz!.ownerId, // This should be current user ID
          quizId: _currentQuiz!.quizId,
          quizTitle: _currentQuiz!.title,
          score: score,
          totalQuestions: totalQuestions,
          correctAnswers: correctAnswers,
          totalTimeSpent: totalTimeSpent,
          percentage: percentage,
          status: QuizResultStatus.abandoned,
          answers: _userAnswers,
          startedAt: _quizStartTime!,
          completedAt: DateTime.now(),
        );

        await _resultRepository.saveResult(result);
      }

      reset();
    } catch (e) {
      _setState(QuizPlayerState.error, e.toString());
    }
  }

  /// Reset quiz player
  void reset() {
    _state = QuizPlayerState.idle;
    _errorMessage = null;
    _currentQuiz = null;
    _questions = [];
    _currentQuestionIndex = 0;
    _userAnswers = [];
    _quizStartTime = null;
    _questionStartTime = null;
    _isTimerEnabled = false;
    _timeRemaining = 0;
    _currentResult = null;
    notifyListeners();
  }

  /// Get quiz statistics for review
  Map<String, dynamic> getQuizStatistics() {
    if (_currentResult == null) return {};

    final correctAnswers = _currentResult!.correctAnswers;
    final totalQuestions = _currentResult!.totalQuestions;
    final incorrectAnswers = totalQuestions - correctAnswers;
    final accuracy = _currentResult!.percentage;
    final timePerQuestion = totalQuestions > 0
        ? _currentResult!.totalTimeSpent / totalQuestions
        : 0;

    return {
      'correctAnswers': correctAnswers,
      'incorrectAnswers': incorrectAnswers,
      'totalQuestions': totalQuestions,
      'accuracy': accuracy,
      'score': _currentResult!.score,
      'totalTimeSpent': _currentResult!.totalTimeSpent,
      'averageTimePerQuestion': timePerQuestion,
      'grade': _currentResult!.grade,
      'performanceMessage': _currentResult!.performanceMessage,
    };
  }

  /// Get answers for review
  List<Map<String, dynamic>> getAnswersForReview() {
    final reviewData = <Map<String, dynamic>>[];

    for (int i = 0; i < _questions.length; i++) {
      final question = _questions[i];
      final userAnswer = _userAnswers.firstWhere(
        (answer) => answer.questionId == question.questionId,
        orElse: () => UserAnswer(
          questionId: question.questionId,
          selectedAnswerIndex: -1,
          selectedAnswer: 'Không trả lời',
          isCorrect: false,
          timeSpent: 0,
          answeredAt: DateTime.now(),
        ),
      );

      reviewData.add({
        'question': question,
        'userAnswer': userAnswer,
        'correctAnswer': question.options[question.correctAnswerIndex],
        'explanation': question.explanation,
        'isCorrect': userAnswer.isCorrect,
        'timeSpent': userAnswer.timeSpent,
      });
    }

    return reviewData;
  }

  /// Clear error
  void clearError() {
    if (_state == QuizPlayerState.error) {
      _state = QuizPlayerState.idle;
      _errorMessage = null;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    super.dispose();
  }
}
