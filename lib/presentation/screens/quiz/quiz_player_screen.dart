import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/themes/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../domain/entities/quiz_entity.dart';
import '../../../domain/entities/question_entity.dart';
import '../../providers/quiz_player_provider.dart';
import 'quiz_result_screen.dart';

class QuizPlayerScreen extends StatefulWidget {
  final String quizId;
  final bool enableTimer;

  const QuizPlayerScreen({
    super.key,
    required this.quizId,
    this.enableTimer = false,
  });

  @override
  State<QuizPlayerScreen> createState() => _QuizPlayerScreenState();
}

class _QuizPlayerScreenState extends State<QuizPlayerScreen>
    with TickerProviderStateMixin {
  late AnimationController _progressController;
  late AnimationController _questionController;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _questionController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeQuiz();
    });
  }

  void _initializeQuiz() async {
    final quizPlayer = context.read<QuizPlayerProvider>();
    await quizPlayer.initializeQuiz(
      widget.quizId,
      enableTimer: widget.enableTimer,
    );

    if (quizPlayer.isReady) {
      _showStartDialog();
    }
  }

  @override
  void dispose() {
    _progressController.dispose();
    _questionController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<QuizPlayerProvider>(
      builder: (context, quizPlayer, child) {
        if (quizPlayer.isLoading) {
          return _buildLoadingScreen();
        }

        if (quizPlayer.hasError) {
          return _buildErrorScreen(quizPlayer.errorMessage ?? 'Có lỗi xảy ra');
        }

        if (quizPlayer.isCompleted) {
          return QuizResultScreen(result: quizPlayer.currentResult!);
        }

        if (quizPlayer.isReady) {
          return _buildReadyScreen(quizPlayer);
        }

        return _buildPlayingScreen(quizPlayer);
      },
    );
  }

  Widget _buildLoadingScreen() {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Đang tải quiz...'),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorScreen(String error) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(title: const Text('Lỗi')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: AppColors.error),
            const SizedBox(height: 16),
            Text(
              'Oops! Có lỗi xảy ra',
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: GoogleFonts.inter(fontSize: 16, color: AppColors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Quay lại'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReadyScreen(QuizPlayerProvider quizPlayer) {
    final quiz = quizPlayer.currentQuiz!;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: Column(
            children: [
              // Close button
              Row(
                children: [
                  IconButton(
                    onPressed: () => _showExitDialog(),
                    icon: const Icon(Icons.close),
                  ),
                  const Spacer(),
                ],
              ),

              const SizedBox(height: 32),

              // Quiz info
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.quiz, size: 80, color: AppColors.primary),

                    const SizedBox(height: 24),

                    Text(
                      quiz.title,
                      style: GoogleFonts.inter(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 12),

                    Text(
                      quiz.description,
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        color: AppColors.grey,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 32),

                    // Quiz stats
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildStatItem(
                                'Câu hỏi',
                                '${quizPlayer.totalQuestions}',
                                Icons.quiz,
                                AppColors.primary,
                              ),
                              _buildStatItem(
                                'Thời gian',
                                widget.enableTimer ? 'Có giới hạn' : 'Tự do',
                                Icons.timer,
                                widget.enableTimer
                                    ? Colors.orange
                                    : Colors.green,
                              ),
                              _buildStatItem(
                                'Độ khó',
                                _getDifficultyName(quiz.difficulty),
                                Icons.signal_cellular_alt,
                                _getDifficultyColor(quiz.difficulty),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Instructions
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Hướng dẫn:',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          _buildInstruction(
                            '• Đọc kỹ câu hỏi trước khi chọn đáp án',
                          ),
                          _buildInstruction(
                            '• Bạn có thể quay lại câu hỏi trước đó',
                          ),
                          if (widget.enableTimer)
                            _buildInstruction(
                              '• Mỗi câu hỏi có thời gian giới hạn',
                            ),
                          _buildInstruction('• Nhấn "Hoàn thành" khi làm xong'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Start button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _startQuiz(quizPlayer),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Bắt đầu Quiz',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlayingScreen(QuizPlayerProvider quizPlayer) {
    final currentQuestion = quizPlayer.currentQuestion;
    if (currentQuestion == null) return Container();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildPlayingHeader(quizPlayer),

            // Question content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppConstants.defaultPadding),
                child: Column(
                  children: [
                    // Question card
                    _buildQuestionCard(currentQuestion, quizPlayer),

                    const SizedBox(height: 24),

                    // Options
                    _buildOptionsSection(currentQuestion, quizPlayer),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),

            // Navigation buttons
            _buildNavigationButtons(quizPlayer),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayingHeader(QuizPlayerProvider quizPlayer) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Top row
          Row(
            children: [
              IconButton(
                onPressed: () => _showExitDialog(),
                icon: const Icon(Icons.close),
              ),

              Expanded(
                child: Text(
                  'Câu ${quizPlayer.currentQuestionIndex + 1}/${quizPlayer.totalQuestions}',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              // Timer
              if (widget.enableTimer && quizPlayer.timeRemaining > 0)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: quizPlayer.timeRemaining <= 10
                        ? AppColors.error.withOpacity(0.1)
                        : AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.timer,
                        size: 16,
                        color: quizPlayer.timeRemaining <= 10
                            ? AppColors.error
                            : AppColors.primary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${quizPlayer.timeRemaining}s',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: quizPlayer.timeRemaining <= 10
                              ? AppColors.error
                              : AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),

          const SizedBox(height: 16),

          // Progress bar
          LinearProgressIndicator(
            value: quizPlayer.progress,
            backgroundColor: AppColors.lightGrey.withOpacity(0.3),
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            minHeight: 6,
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionCard(
    QuestionEntity question,
    QuizPlayerProvider quizPlayer,
  ) {
    return AnimatedBuilder(
      animation: _questionController,
      builder: (context, child) {
        return Transform.scale(
          scale: 0.95 + (_questionController.value * 0.05),
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Question type badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _getQuestionTypeColor(
                        question.type,
                      ).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _getQuestionTypeName(question.type),
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: _getQuestionTypeColor(question.type),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Question text
                  Text(
                    question.question,
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      height: 1.5,
                    ),
                  ),

                  // Points and time info
                  if (question.points != 10 || question.timeLimit > 0) ...[
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        if (question.points != 10) ...[
                          Icon(Icons.stars, size: 16, color: Colors.amber),
                          const SizedBox(width: 4),
                          Text(
                            '${question.points} điểm',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: Colors.amber,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                        if (question.points != 10 && question.timeLimit > 0)
                          const SizedBox(width: 16),
                        if (question.timeLimit > 0) ...[
                          Icon(Icons.timer, size: 16, color: Colors.orange),
                          const SizedBox(width: 4),
                          Text(
                            '${question.timeLimit} giây',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: Colors.orange,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildOptionsSection(
    QuestionEntity question,
    QuizPlayerProvider quizPlayer,
  ) {
    final userAnswer = quizPlayer.currentUserAnswer;

    return Column(
      children: question.options.asMap().entries.map((entry) {
        final index = entry.key;
        final option = entry.value;
        final isSelected = userAnswer?.selectedAnswerIndex == index;
        final optionLabel = question.type == QuestionType.multipleChoice
            ? String.fromCharCode(65 + index) // A, B, C, D
            : (index == 0 ? 'Đúng' : 'Sai');

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            child: InkWell(
              onTap: () => _selectAnswer(quizPlayer, index, option),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary.withOpacity(0.1)
                      : Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.lightGrey.withOpacity(0.3),
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    // Option label
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.lightGrey,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          optionLabel,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: isSelected
                                ? AppColors.white
                                : AppColors.grey,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 16),

                    // Option text
                    Expanded(
                      child: Text(
                        option,
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          color: isSelected
                              ? AppColors.primary
                              : Theme.of(context).textTheme.bodyLarge?.color,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      ),
                    ),

                    // Selected indicator
                    if (isSelected)
                      const Icon(
                        Icons.check_circle,
                        color: AppColors.primary,
                        size: 24,
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildNavigationButtons(QuizPlayerProvider quizPlayer) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Previous button
          if (quizPlayer.canGoPrevious)
            Expanded(
              child: OutlinedButton(
                onPressed: () => _previousQuestion(quizPlayer),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.grey),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Trước',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.grey,
                  ),
                ),
              ),
            ),

          if (quizPlayer.canGoPrevious) const SizedBox(width: 16),

          // Next/Finish button
          Expanded(
            flex: quizPlayer.canGoPrevious ? 1 : 2,
            child: ElevatedButton(
              onPressed: quizPlayer.currentUserAnswer != null
                  ? () => quizPlayer.isLastQuestion
                        ? _finishQuiz(quizPlayer)
                        : _nextQuestion(quizPlayer)
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                quizPlayer.isLastQuestion ? 'Hoàn thành' : 'Tiếp theo',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.inter(fontSize: 12, color: AppColors.grey),
        ),
      ],
    );
  }

  Widget _buildInstruction(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        text,
        style: GoogleFonts.inter(fontSize: 14, color: AppColors.grey),
      ),
    );
  }

  void _showStartDialog() {
    // Auto-start after a brief delay
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        final quizPlayer = context.read<QuizPlayerProvider>();
        if (quizPlayer.isReady) {
          // Dialog is optional, we can start directly
        }
      }
    });
  }

  void _startQuiz(QuizPlayerProvider quizPlayer) {
    quizPlayer.startQuiz();
    _questionController.forward();
    _startTimer(quizPlayer);
  }

  void _startTimer(QuizPlayerProvider quizPlayer) {
    if (widget.enableTimer) {
      _timer?.cancel();
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (quizPlayer.timeRemaining > 0) {
          quizPlayer.updateTimer(quizPlayer.timeRemaining - 1);
        }
      });
    }
  }

  void _selectAnswer(QuizPlayerProvider quizPlayer, int index, String answer) {
    quizPlayer.answerQuestion(
      selectedAnswerIndex: index,
      selectedAnswer: answer,
    );
  }

  void _nextQuestion(QuizPlayerProvider quizPlayer) {
    _questionController.reset();
    quizPlayer.nextQuestion();
    _questionController.forward();
    _startTimer(quizPlayer);
  }

  void _previousQuestion(QuizPlayerProvider quizPlayer) {
    _questionController.reset();
    quizPlayer.previousQuestion();
    _questionController.forward();
    _startTimer(quizPlayer);
  }

  void _finishQuiz(QuizPlayerProvider quizPlayer) async {
    _timer?.cancel();
    await quizPlayer.finishQuiz();
  }

  void _showExitDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Thoát quiz'),
          content: const Text(
            'Bạn có chắc chắn muốn thoát? Tiến độ của bạn sẽ không được lưu.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Tiếp tục'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              child: const Text(
                'Thoát',
                style: TextStyle(color: AppColors.error),
              ),
            ),
          ],
        );
      },
    );
  }

  String _getDifficultyName(QuizDifficulty difficulty) {
    switch (difficulty) {
      case QuizDifficulty.beginner:
        return 'Dễ';
      case QuizDifficulty.intermediate:
        return 'Trung bình';
      case QuizDifficulty.advanced:
        return 'Khó';
    }
  }

  Color _getDifficultyColor(QuizDifficulty difficulty) {
    switch (difficulty) {
      case QuizDifficulty.beginner:
        return Colors.green;
      case QuizDifficulty.intermediate:
        return Colors.orange;
      case QuizDifficulty.advanced:
        return Colors.red;
    }
  }

  Color _getQuestionTypeColor(QuestionType type) {
    switch (type) {
      case QuestionType.multipleChoice:
        return Colors.blue;
      case QuestionType.trueFalse:
        return Colors.green;
      case QuestionType.fillInTheBlank:
        return Colors.orange;
      case QuestionType.matching:
        return Colors.purple;
    }
  }

  String _getQuestionTypeName(QuestionType type) {
    switch (type) {
      case QuestionType.multipleChoice:
        return 'Trắc nghiệm';
      case QuestionType.trueFalse:
        return 'Đúng/Sai';
      case QuestionType.fillInTheBlank:
        return 'Điền từ';
      case QuestionType.matching:
        return 'Nối từ';
    }
  }
}
