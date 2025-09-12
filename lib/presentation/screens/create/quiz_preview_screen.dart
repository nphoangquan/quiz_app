import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/themes/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/category_mapper.dart';
import '../../../domain/entities/quiz_entity.dart';
import '../../../domain/entities/question_entity.dart';
import '../../providers/quiz_provider.dart';

class QuizPreviewScreen extends StatelessWidget {
  final QuizEntity quiz;
  final List<QuestionEntity> questions;

  const QuizPreviewScreen({
    super.key,
    required this.quiz,
    required this.questions,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Xem trước Quiz',
          style: GoogleFonts.inter(fontWeight: FontWeight.bold),
        ),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'edit':
                  Navigator.of(context).pop();
                  break;
                case 'publish':
                  _publishQuiz(context);
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit, size: 20),
                    SizedBox(width: 12),
                    Text('Chỉnh sửa'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'publish',
                child: Row(
                  children: [
                    Icon(Icons.publish, size: 20, color: AppColors.primary),
                    SizedBox(width: 12),
                    Text(
                      'Xuất bản',
                      style: TextStyle(color: AppColors.primary),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Quiz Header
            _buildQuizHeader(context),

            // Quiz Stats
            _buildQuizStats(context),

            // Questions Preview
            _buildQuestionsPreview(context),

            const SizedBox(height: 100), // Space for FAB
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _publishQuiz(context),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.publish, color: AppColors.white),
        label: Text(
          'Xuất bản Quiz',
          style: GoogleFonts.inter(
            color: AppColors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildQuizHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withOpacity(0.1),
            AppColors.primary.withOpacity(0.05),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.primary.withOpacity(0.3)),
            ),
            child: Text(
              CategoryMapper.getDisplayName(quiz.category),
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Quiz title
          Text(
            quiz.title,
            style: GoogleFonts.inter(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.headlineLarge?.color,
            ),
          ),

          const SizedBox(height: 8),

          // Quiz description
          Text(
            quiz.description,
            style: GoogleFonts.inter(
              fontSize: 16,
              color: AppColors.grey,
              height: 1.5,
            ),
          ),

          const SizedBox(height: 16),

          // Tags
          if (quiz.tags.isNotEmpty) ...[
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: quiz.tags.map((tag) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.lightGrey.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '#$tag',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: AppColors.grey,
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
          ],

          // Quiz metadata
          Row(
            children: [
              _buildMetadataItem(Icons.person, quiz.ownerName, AppColors.grey),
              const SizedBox(width: 16),
              _buildMetadataItem(
                Icons.lock,
                quiz.isPublic ? 'Công khai' : 'Riêng tư',
                quiz.isPublic ? Colors.green : Colors.orange,
              ),
              const SizedBox(width: 16),
              _buildMetadataItem(
                Icons.signal_cellular_alt,
                _getDifficultyName(quiz.difficulty),
                _getDifficultyColor(quiz.difficulty),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetadataItem(IconData icon, String text, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 4),
        Text(
          text,
          style: GoogleFonts.inter(
            fontSize: 12,
            color: color,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildQuizStats(BuildContext context) {
    final totalPoints = questions.fold(0, (sum, q) => sum + q.points);
    final hasTimer = questions.any((q) => q.timeLimit > 0);
    final avgTime = hasTimer
        ? (questions
                      .where((q) => q.timeLimit > 0)
                      .fold(0, (sum, q) => sum + q.timeLimit) /
                  questions.where((q) => q.timeLimit > 0).length)
              .round()
        : 0;

    return Container(
      margin: const EdgeInsets.all(AppConstants.defaultPadding),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            'Câu hỏi',
            questions.length.toString(),
            Icons.quiz,
            AppColors.primary,
          ),
          _buildStatItem(
            'Tổng điểm',
            totalPoints.toString(),
            Icons.stars,
            Colors.amber,
          ),
          _buildStatItem(
            'Thời gian',
            hasTimer ? '${avgTime}s' : 'Tự do',
            Icons.timer,
            hasTimer ? Colors.orange : AppColors.grey,
          ),
          _buildStatItem(
            'Loại',
            _getQuizTypeText(),
            Icons.category,
            Colors.blue,
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
            fontSize: 16,
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

  Widget _buildQuestionsPreview(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppConstants.defaultPadding,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Danh sách câu hỏi',
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.headlineMedium?.color,
            ),
          ),
          const SizedBox(height: 16),

          ...questions.asMap().entries.map((entry) {
            final index = entry.key;
            final question = entry.value;
            return _buildQuestionPreviewCard(context, question, index + 1);
          }),
        ],
      ),
    );
  }

  Widget _buildQuestionPreviewCard(
    BuildContext context,
    QuestionEntity question,
    int questionNumber,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
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
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      questionNumber.toString(),
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getQuestionTypeColor(
                      question.type,
                    ).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
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

                const Spacer(),

                // Question settings
                if (question.points != 10 || question.timeLimit > 0) ...[
                  Row(
                    children: [
                      if (question.points != 10) ...[
                        Icon(Icons.stars, size: 16, color: Colors.amber),
                        const SizedBox(width: 4),
                        Text(
                          '${question.points}đ',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: Colors.amber,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 12),
                      ],
                      if (question.timeLimit > 0) ...[
                        Icon(Icons.timer, size: 16, color: Colors.orange),
                        const SizedBox(width: 4),
                        Text(
                          '${question.timeLimit}s',
                          style: GoogleFonts.inter(
                            fontSize: 12,
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

            const SizedBox(height: 12),

            // Question text
            Text(
              question.question,
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),

            const SizedBox(height: 12),

            // Options
            ...question.options.asMap().entries.map((entry) {
              final optionIndex = entry.key;
              final option = entry.value;
              final isCorrect = optionIndex == question.correctAnswerIndex;
              final optionLabel = question.type == QuestionType.multipleChoice
                  ? String.fromCharCode(65 + optionIndex) // A, B, C, D
                  : (optionIndex == 0 ? '✓' : '✗');

              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isCorrect
                        ? Colors.green.withOpacity(0.1)
                        : Theme.of(context).brightness == Brightness.dark
                        ? AppColors.surfaceDark
                        : AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isCorrect
                          ? Colors.green
                          : AppColors.lightGrey.withOpacity(0.3),
                      width: isCorrect ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: isCorrect ? Colors.green : AppColors.lightGrey,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Center(
                          child: Text(
                            optionLabel,
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: isCorrect
                                  ? AppColors.white
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
                            color: isCorrect
                                ? Colors.green
                                : Theme.of(context).textTheme.bodyMedium?.color,
                            fontWeight: isCorrect
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                      if (isCorrect)
                        const Icon(
                          Icons.check_circle,
                          color: Colors.green,
                          size: 20,
                        ),
                    ],
                  ),
                ),
              );
            }),

            // Explanation
            if (question.explanation != null &&
                question.explanation!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColors.primary.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.lightbulb,
                          size: 16,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Giải thích:',
                          style: GoogleFonts.inter(
                            fontSize: 12,
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
                        color: AppColors.grey,
                        height: 1.4,
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

  void _publishQuiz(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Xuất bản Quiz'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Bạn có chắc chắn muốn xuất bản quiz này?'),
              const SizedBox(height: 12),
              Text(
                '• ${questions.length} câu hỏi',
                style: GoogleFonts.inter(fontSize: 14, color: AppColors.grey),
              ),
              Text(
                '• ${quiz.isPublic ? "Công khai" : "Riêng tư"}',
                style: GoogleFonts.inter(fontSize: 14, color: AppColors.grey),
              ),
              Text(
                '• Danh mục: ${CategoryMapper.getDisplayName(quiz.category)}',
                style: GoogleFonts.inter(fontSize: 14, color: AppColors.grey),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();

                final quizProvider = context.read<QuizProvider>();
                final quizId = await quizProvider.createQuiz();

                if (quizId != null && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('🎉 Quiz đã được xuất bản thành công!'),
                      backgroundColor: Colors.green,
                    ),
                  );

                  // Navigate back to main screen
                  Navigator.of(context).popUntil((route) => route.isFirst);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
              ),
              child: const Text(
                'Xuất bản',
                style: TextStyle(color: AppColors.white),
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

  String _getQuizTypeText() {
    final multipleChoice = questions
        .where((q) => q.type == QuestionType.multipleChoice)
        .length;
    final trueFalse = questions
        .where((q) => q.type == QuestionType.trueFalse)
        .length;

    if (multipleChoice > 0 && trueFalse > 0) {
      return 'Hỗn hợp';
    } else if (multipleChoice > 0) {
      return 'Trắc nghiệm';
    } else {
      return 'Đúng/Sai';
    }
  }
}
