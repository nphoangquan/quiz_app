import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/themes/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../domain/entities/question_entity.dart';
import '../../providers/quiz_provider.dart';
import 'question_editor_screen.dart';

class AddQuestionsScreen extends StatefulWidget {
  const AddQuestionsScreen({super.key});

  @override
  State<AddQuestionsScreen> createState() => _AddQuestionsScreenState();
}

class _AddQuestionsScreenState extends State<AddQuestionsScreen> {
  @override
  Widget build(BuildContext context) {
    return Consumer<QuizProvider>(
      builder: (context, quizProvider, child) {
        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: AppBar(
            title: Text(
              'Quản lý câu hỏi',
              style: GoogleFonts.inter(fontWeight: FontWeight.bold),
            ),
            actions: [
              TextButton.icon(
                onPressed: () => Navigator.of(context).pop(true),
                icon: const Icon(Icons.check, color: AppColors.primary),
                label: Text(
                  'Xong',
                  style: GoogleFonts.inter(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          body: Column(
            children: [
              // Stats header
              _buildStatsHeader(quizProvider),

              // Questions list
              Expanded(child: _buildQuestionsList(quizProvider)),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _navigateToQuestionEditor(),
            backgroundColor: AppColors.primary,
            icon: const Icon(Icons.add, color: AppColors.white),
            label: Text(
              'Thêm câu hỏi',
              style: GoogleFonts.inter(
                color: AppColors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatsHeader(QuizProvider quizProvider) {
    final questionCount = quizProvider.currentQuestions.length;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        border: Border(
          bottom: BorderSide(
            color: AppColors.primary.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                'Tổng câu hỏi',
                questionCount.toString(),
                Icons.quiz,
                AppColors.primary,
              ),
              _buildStatItem(
                'Trắc nghiệm',
                quizProvider.currentQuestions
                    .where((q) => q.type == QuestionType.multipleChoice)
                    .length
                    .toString(),
                Icons.radio_button_checked,
                Colors.blue,
              ),
              _buildStatItem(
                'Đúng/Sai',
                quizProvider.currentQuestions
                    .where((q) => q.type == QuestionType.trueFalse)
                    .length
                    .toString(),
                Icons.check_box,
                Colors.green,
              ),
            ],
          ),
          if (questionCount == 0) ...[
            const SizedBox(height: 16),
            Text(
              'Thêm ít nhất 1 câu hỏi để tạo quiz',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: AppColors.grey,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
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
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 20,
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

  Widget _buildQuestionsList(QuizProvider quizProvider) {
    if (quizProvider.currentQuestions.isEmpty) {
      return _buildEmptyState();
    }

    return ReorderableListView.builder(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      itemCount: quizProvider.currentQuestions.length,
      onReorder: (oldIndex, newIndex) {
        quizProvider.reorderQuestions(oldIndex, newIndex);
      },
      itemBuilder: (context, index) {
        final question = quizProvider.currentQuestions[index];
        return _buildQuestionCard(question, index, quizProvider);
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.quiz_outlined,
            size: 80,
            color: AppColors.grey.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 24),
          Text(
            'Chưa có câu hỏi nào',
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppColors.grey,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Nhấn nút "+" để thêm câu hỏi đầu tiên',
            style: GoogleFonts.inter(fontSize: 16, color: AppColors.grey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () => _navigateToQuestionEditor(),
            icon: const Icon(Icons.add, color: AppColors.white),
            label: Text(
              'Thêm câu hỏi',
              style: GoogleFonts.inter(
                color: AppColors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionCard(
    QuestionEntity question,
    int index,
    QuizProvider quizProvider,
  ) {
    return Card(
      key: ValueKey(question.questionId),
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () =>
            _navigateToQuestionEditor(question: question, index: index),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row
              Row(
                children: [
                  // Question number
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  // Question type badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getQuestionTypeColor(
                        question.type,
                      ).withValues(alpha: 0.1),
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

                  // Drag handle
                  Icon(
                    Icons.drag_handle,
                    color: AppColors.grey.withValues(alpha: 0.7),
                  ),

                  // More options
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      switch (value) {
                        case 'edit':
                          _navigateToQuestionEditor(
                            question: question,
                            index: index,
                          );
                          break;
                        case 'duplicate':
                          _duplicateQuestion(question, quizProvider);
                          break;
                        case 'delete':
                          _deleteQuestion(index, quizProvider);
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
                        value: 'duplicate',
                        child: Row(
                          children: [
                            Icon(Icons.copy, size: 20),
                            SizedBox(width: 12),
                            Text('Nhân bản'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(
                              Icons.delete,
                              size: 20,
                              color: AppColors.error,
                            ),
                            SizedBox(width: 12),
                            Text(
                              'Xóa',
                              style: TextStyle(color: AppColors.error),
                            ),
                          ],
                        ),
                      ),
                    ],
                    icon: const Icon(Icons.more_vert),
                  ),
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
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 12),

              // Options preview
              if (question.type == QuestionType.multipleChoice) ...[
                ...question.options
                    .asMap()
                    .entries
                    .map((entry) {
                      final optionIndex = entry.key;
                      final option = entry.value;
                      final isCorrect =
                          optionIndex == question.correctAnswerIndex;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          children: [
                            Icon(
                              isCorrect
                                  ? Icons.radio_button_checked
                                  : Icons.radio_button_unchecked,
                              size: 16,
                              color: isCorrect ? Colors.green : AppColors.grey,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                option,
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  color: isCorrect
                                      ? Colors.green
                                      : AppColors.grey,
                                  fontWeight: isCorrect
                                      ? FontWeight.w600
                                      : FontWeight.normal,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      );
                    })
                    .take(2), // Show only first 2 options
                if (question.options.length > 2)
                  Text(
                    '... và ${question.options.length - 2} đáp án khác',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: AppColors.grey,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
              ] else ...[
                Row(
                  children: [
                    Icon(
                      question.correctAnswerIndex == 0
                          ? Icons.check_circle
                          : Icons.cancel,
                      size: 16,
                      color: Colors.green,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Đáp án: ${question.options[question.correctAnswerIndex]}',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: Colors.green,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],

              // Additional info
              if (question.points != 10 || question.timeLimit > 0) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    if (question.points != 10) ...[
                      Icon(Icons.stars, size: 16, color: Colors.amber),
                      const SizedBox(width: 4),
                      Text(
                        '${question.points} điểm',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: Colors.amber,
                        ),
                      ),
                      const SizedBox(width: 16),
                    ],
                    if (question.timeLimit > 0) ...[
                      Icon(Icons.timer, size: 16, color: Colors.orange),
                      const SizedBox(width: 4),
                      Text(
                        '${question.timeLimit}s',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: Colors.orange,
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

  void _navigateToQuestionEditor({QuestionEntity? question, int? index}) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) =>
            QuestionEditorScreen(question: question, questionIndex: index),
      ),
    );

    if (result == true) {
      setState(() {});
    }
  }

  void _duplicateQuestion(QuestionEntity question, QuizProvider quizProvider) {
    final duplicatedQuestion = QuestionEntity(
      questionId: DateTime.now().millisecondsSinceEpoch.toString(),
      question: '${question.question} (Bản sao)',
      type: question.type,
      options: List.from(question.options),
      correctAnswerIndex: question.correctAnswerIndex,
      explanation: question.explanation,
      imageUrl: question.imageUrl,
      order: quizProvider.currentQuestions.length,
      points: question.points,
      timeLimit: question.timeLimit,
    );

    quizProvider.addQuestion(duplicatedQuestion);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Đã nhân bản câu hỏi'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _deleteQuestion(int index, QuizProvider quizProvider) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Xác nhận xóa'),
          content: const Text('Bạn có chắc chắn muốn xóa câu hỏi này?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Hủy'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                quizProvider.removeQuestion(index);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Đã xóa câu hỏi'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              child: const Text(
                'Xóa',
                style: TextStyle(color: AppColors.error),
              ),
            ),
          ],
        );
      },
    );
  }
}
