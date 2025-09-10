import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/themes/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../domain/entities/result_entity.dart';
import '../../../domain/entities/question_entity.dart';
import '../../providers/quiz_provider.dart';

class AnswerReviewScreen extends StatefulWidget {
  final ResultEntity result;

  const AnswerReviewScreen({super.key, required this.result});

  @override
  State<AnswerReviewScreen> createState() => _AnswerReviewScreenState();
}

class _AnswerReviewScreenState extends State<AnswerReviewScreen> {
  List<QuestionEntity> _questions = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  void _loadQuestions() async {
    try {
      final quizProvider = context.read<QuizProvider>();
      final questions = await quizProvider.quizRepository.getQuizQuestionsOnce(
        widget.result.quizId,
      );

      setState(() {
        _questions = questions;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Xem đáp án',
          style: GoogleFonts.inter(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _getScoreColor().withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${widget.result.score}/${widget.result.totalQuestions}',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: _getScoreColor(),
              ),
            ),
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Đang tải câu hỏi...'),
          ],
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: AppColors.error),
            const SizedBox(height: 16),
            Text(
              'Có lỗi xảy ra',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              style: GoogleFonts.inter(fontSize: 14, color: AppColors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadQuestions,
              child: const Text('Thử lại'),
            ),
          ],
        ),
      );
    }

    if (_questions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.quiz, size: 64, color: AppColors.grey),
            const SizedBox(height: 16),
            Text(
              'Không có câu hỏi nào',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.grey,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Summary header
        _buildSummaryHeader(),

        // Questions list
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            itemCount: _questions.length,
            itemBuilder: (context, index) {
              final question = _questions[index];
              final userAnswer = _getUserAnswerForQuestion(question.questionId);
              return _buildQuestionCard(question, userAnswer, index + 1);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryHeader() {
    final correctCount = widget.result.correctAnswers;
    final totalCount = widget.result.totalQuestions;
    final percentage = widget.result.percentage;

    return Container(
      margin: const EdgeInsets.all(AppConstants.defaultPadding),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _getScoreColor().withOpacity(0.1),
            _getScoreColor().withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _getScoreColor().withOpacity(0.3), width: 1),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.result.quizTitle,
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Text(
                  'Kết quả: $correctCount/$totalCount câu đúng',
                  style: GoogleFonts.inter(fontSize: 14, color: AppColors.grey),
                ),
              ],
            ),
          ),
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: _getScoreColor().withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(color: _getScoreColor(), width: 3),
            ),
            child: Center(
              child: Text(
                '${percentage.round()}%',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: _getScoreColor(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionCard(
    QuestionEntity question,
    UserAnswer? userAnswer,
    int questionNumber,
  ) {
    final isCorrect = userAnswer?.isCorrect ?? false;
    final userAnswerIndex = userAnswer?.selectedAnswerIndex ?? -1;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Question header
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: isCorrect ? Colors.green : Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      questionNumber.toString(),
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    question.question,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Icon(
                  isCorrect ? Icons.check_circle : Icons.cancel,
                  color: isCorrect ? Colors.green : Colors.red,
                  size: 24,
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Answer options
            ...question.options.asMap().entries.map((entry) {
              final optionIndex = entry.key;
              final option = entry.value;
              final isCorrectOption =
                  optionIndex == question.correctAnswerIndex;
              final isUserSelected = optionIndex == userAnswerIndex;

              return _buildAnswerOption(
                option,
                optionIndex,
                isCorrectOption,
                isUserSelected,
                question.type,
              );
            }).toList(),

            // Explanation if available
            if (question.explanation != null &&
                question.explanation!.isNotEmpty) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.lightGrey.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.lightbulb_outline,
                          size: 16,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Giải thích:',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      question.explanation!,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: AppColors.darkGrey,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAnswerOption(
    String option,
    int optionIndex,
    bool isCorrectOption,
    bool isUserSelected,
    QuestionType questionType,
  ) {
    Color backgroundColor;
    Color borderColor;
    Color textColor;
    IconData? icon;

    if (isCorrectOption && isUserSelected) {
      // User selected correct answer - green
      backgroundColor = Colors.green.withOpacity(0.1);
      borderColor = Colors.green;
      textColor = Colors.green;
      icon = Icons.check_circle;
    } else if (isCorrectOption) {
      // Correct answer but user didn't select - green
      backgroundColor = Colors.green.withOpacity(0.1);
      borderColor = Colors.green;
      textColor = Colors.green;
      icon = Icons.check_circle_outline;
    } else if (isUserSelected) {
      // User selected wrong answer - red
      backgroundColor = Colors.red.withOpacity(0.1);
      borderColor = Colors.red;
      textColor = Colors.red;
      icon = Icons.cancel;
    } else {
      // Not selected, not correct - default
      backgroundColor = Colors.transparent;
      borderColor = AppColors.lightGrey;
      textColor = AppColors.darkGrey;
    }

    final optionLabel = questionType == QuestionType.multipleChoice
        ? String.fromCharCode(65 + optionIndex) // A, B, C, D
        : (optionIndex == 0 ? '✓' : '✗');

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor, width: 1.5),
      ),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: isCorrectOption || isUserSelected
                  ? (isCorrectOption ? Colors.green : Colors.red)
                  : AppColors.lightGrey,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Center(
              child: Text(
                optionLabel,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isCorrectOption || isUserSelected
                      ? Colors.white
                      : AppColors.grey,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              option,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: textColor,
                fontWeight: isCorrectOption || isUserSelected
                    ? FontWeight.w600
                    : FontWeight.normal,
              ),
            ),
          ),
          if (icon != null) ...[
            const SizedBox(width: 8),
            Icon(
              icon,
              color: isCorrectOption ? Colors.green : Colors.red,
              size: 20,
            ),
          ],
        ],
      ),
    );
  }

  UserAnswer? _getUserAnswerForQuestion(String questionId) {
    try {
      return widget.result.answers.firstWhere(
        (answer) => answer.questionId == questionId,
      );
    } catch (e) {
      return null;
    }
  }

  Color _getScoreColor() {
    final percentage = widget.result.percentage;
    if (percentage >= 80) return Colors.green;
    if (percentage >= 60) return Colors.orange;
    return Colors.red;
  }
}
