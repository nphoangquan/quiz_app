import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/ai_quiz_provider.dart';
import '../../providers/quiz_provider.dart';
import '../../providers/category_provider.dart';
import '../../providers/auth_provider.dart';
import '../../../core/themes/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../domain/entities/quiz_entity.dart';
import '../../../domain/entities/category_entity.dart';
import '../../../domain/entities/question_entity.dart';

class AiQuizPreviewScreen extends StatefulWidget {
  const AiQuizPreviewScreen({super.key});

  @override
  State<AiQuizPreviewScreen> createState() => _AiQuizPreviewScreenState();
}

class _AiQuizPreviewScreenState extends State<AiQuizPreviewScreen> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  CategoryEntity? _selectedCategory;
  QuizDifficulty? _selectedDifficulty;

  @override
  void initState() {
    super.initState();
    final aiProvider = context.read<AiQuizProvider>();
    _titleController = TextEditingController(
      text: aiProvider.generatedTitle ?? '',
    );
    _descriptionController = TextEditingController(
      text: aiProvider.generatedDescription ?? '',
    );
    // Map generated category to CategoryEntity if needed
    _selectedCategory = _mapStringToCategory(aiProvider.generatedCategory);
    _selectedDifficulty = _mapStringToDifficulty(
      aiProvider.generatedDifficulty,
    );
  }

  QuizDifficulty? _mapStringToDifficulty(String? difficultyString) {
    switch (difficultyString) {
      case 'easy':
        return QuizDifficulty.beginner;
      case 'medium':
        return QuizDifficulty.intermediate;
      case 'hard':
        return QuizDifficulty.advanced;
      default:
        return null;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: Consumer<AiQuizProvider>(
        builder: (context, aiProvider, child) {
          if (!aiProvider.hasGeneratedQuiz) {
            return _buildEmptyState();
          }

          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppConstants.defaultPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildQuizMetadata(aiProvider),
                      const SizedBox(height: 24),
                      _buildQuestionsSection(aiProvider),
                    ],
                  ),
                ),
              ),
              _buildBottomActions(aiProvider),
            ],
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        onPressed: () => Navigator.of(context).pop(),
        icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
      ),
      title: Text(
        'Xem trước Quiz AI',
        style: GoogleFonts.inter(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
      actions: [
        Consumer<AiQuizProvider>(
          builder: (context, aiProvider, child) {
            return TextButton.icon(
              onPressed: () => _showRegenerateDialog(aiProvider),
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Tạo lại'),
              style: TextButton.styleFrom(foregroundColor: AppColors.primary),
            );
          },
        ),
      ],
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
            color: AppColors.textSecondary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'Chưa có quiz nào được tạo',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Vui lòng quay lại và tạo quiz mới',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuizMetadata(AiQuizProvider aiProvider) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Thông tin Quiz',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 20),

          // Title
          _buildEditableField(
            label: 'Tiêu đề',
            controller: _titleController,
            maxLines: 2,
            onChanged: (value) {
              aiProvider.updateGeneratedQuizMetadata(title: value);
            },
          ),
          const SizedBox(height: 16),

          // Description
          _buildEditableField(
            label: 'Mô tả',
            controller: _descriptionController,
            maxLines: 3,
            onChanged: (value) {
              aiProvider.updateGeneratedQuizMetadata(description: value);
            },
          ),
          const SizedBox(height: 16),

          // Category and Difficulty
          Row(
            children: [
              Expanded(child: _buildCategoryDropdown(aiProvider)),
              const SizedBox(width: 16),
              Expanded(child: _buildDifficultyDropdown(aiProvider)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEditableField({
    required String label,
    required TextEditingController controller,
    int maxLines = 1,
    Function(String)? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          onChanged: onChanged,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
            contentPadding: const EdgeInsets.all(12),
          ),
          style: GoogleFonts.inter(fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildCategoryDropdown(AiQuizProvider aiProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Danh mục',
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Consumer<CategoryProvider>(
          builder: (context, categoryProvider, child) {
            return DropdownButtonFormField<CategoryEntity>(
              value: _selectedCategory,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
              items: categoryProvider.categories.map((category) {
                return DropdownMenuItem<CategoryEntity>(
                  value: category,
                  child: Text(
                    category.name,
                    style: GoogleFonts.inter(fontSize: 14),
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() => _selectedCategory = value);
                // Update AI provider with category name
                aiProvider.updateGeneratedQuizMetadata(category: value?.name);
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildDifficultyDropdown(AiQuizProvider aiProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Độ khó',
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<QuizDifficulty>(
          value: _selectedDifficulty,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
          ),
          items: QuizDifficulty.values.map((difficulty) {
            return DropdownMenuItem<QuizDifficulty>(
              value: difficulty,
              child: Text(
                _getDifficultyDisplayName(difficulty),
                style: GoogleFonts.inter(fontSize: 14),
              ),
            );
          }).toList(),
          onChanged: (value) {
            setState(() => _selectedDifficulty = value);
            aiProvider.updateGeneratedQuizMetadata(
              difficulty: _mapDifficultyToString(value),
            );
          },
        ),
      ],
    );
  }

  String _getDifficultyDisplayName(QuizDifficulty difficulty) {
    switch (difficulty) {
      case QuizDifficulty.beginner:
        return 'Dễ';
      case QuizDifficulty.intermediate:
        return 'Trung bình';
      case QuizDifficulty.advanced:
        return 'Khó';
    }
  }

  String? _mapDifficultyToString(QuizDifficulty? difficulty) {
    switch (difficulty) {
      case QuizDifficulty.beginner:
        return 'easy';
      case QuizDifficulty.intermediate:
        return 'medium';
      case QuizDifficulty.advanced:
        return 'hard';
      default:
        return null;
    }
  }

  Widget _buildQuestionsSection(AiQuizProvider aiProvider) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Câu hỏi (${aiProvider.generatedQuestions.length})',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      TextButton.icon(
                        onPressed: () => _showTimeLimitDialog(aiProvider),
                        icon: const Icon(Icons.timer_outlined, size: 18),
                        label: const Text('Thời gian'),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      TextButton.icon(
                        onPressed: () => _addNewQuestion(aiProvider),
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text('Thêm câu hỏi'),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: aiProvider.generatedQuestions.length,
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              return _buildQuestionCard(aiProvider, index);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionCard(AiQuizProvider aiProvider, int index) {
    final question = aiProvider.generatedQuestions[index];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    '${index + 1}',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const Spacer(),
              PopupMenuButton<String>(
                onSelected: (value) =>
                    _handleQuestionAction(value, aiProvider, index),
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit, size: 18),
                        SizedBox(width: 8),
                        Text('Chỉnh sửa'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, size: 18, color: AppColors.error),
                        SizedBox(width: 8),
                        Text('Xóa', style: TextStyle(color: AppColors.error)),
                      ],
                    ),
                  ),
                ],
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
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),

          // Options
          ...question.options.asMap().entries.map((entry) {
            final optionIndex = entry.key;
            final option = entry.value;
            final isCorrect = optionIndex == question.correctAnswerIndex;

            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isCorrect
                    ? AppColors.success.withValues(alpha: 0.1)
                    : Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isCorrect ? AppColors.success : AppColors.border,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: isCorrect
                          ? AppColors.success
                          : AppColors.background,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Center(
                      child: Text(
                        String.fromCharCode(65 + optionIndex), // A, B, C, D
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isCorrect
                              ? Colors.white
                              : AppColors.textSecondary,
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
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  if (isCorrect)
                    const Icon(
                      Icons.check_circle,
                      color: AppColors.success,
                      size: 20,
                    ),
                ],
              ),
            );
          }),

          // Explanation
          if (question.explanation != null &&
              question.explanation!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.lightbulb_outline,
                    color: AppColors.primary,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      question.explanation!,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBottomActions(AiQuizProvider aiProvider) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextButton(
              onPressed: () => _discardQuiz(aiProvider),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Hủy bỏ',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: aiProvider.generatedQuestions.isEmpty
                  ? null
                  : () => _addToCurrentQuiz(aiProvider),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.add_circle_outline, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Thêm vào Quiz',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleQuestionAction(
    String action,
    AiQuizProvider aiProvider,
    int index,
  ) {
    switch (action) {
      case 'edit':
        _editQuestion(aiProvider, index);
        break;
      case 'delete':
        _deleteQuestion(aiProvider, index);
        break;
    }
  }

  void _editQuestion(AiQuizProvider aiProvider, int index) {
    final question = aiProvider.generatedQuestions[index];

    showDialog(
      context: context,
      builder: (context) => _EditQuestionDialog(
        question: question,
        onQuestionUpdated: (updatedQuestion) {
          aiProvider.editGeneratedQuestion(index, updatedQuestion);
          Navigator.of(context).pop();
        },
      ),
    );
  }

  void _deleteQuestion(AiQuizProvider aiProvider, int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa câu hỏi'),
        content: const Text('Bạn có chắc chắn muốn xóa câu hỏi này?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              aiProvider.removeGeneratedQuestion(index);
              Navigator.of(context).pop();
            },
            child: const Text('Xóa', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  void _addNewQuestion(AiQuizProvider aiProvider) {
    showDialog(
      context: context,
      builder: (context) => _AddQuestionDialog(
        onQuestionAdded: (question) {
          aiProvider.addGeneratedQuestion(question);
          Navigator.of(context).pop();
        },
      ),
    );
  }

  void _showTimeLimitDialog(AiQuizProvider aiProvider) {
    bool enableTimeLimit =
        aiProvider.generatedQuestions.isNotEmpty &&
        aiProvider.generatedQuestions.first.timeLimit > 0;
    int timeLimitSeconds = enableTimeLimit
        ? aiProvider.generatedQuestions.first.timeLimit
        : 30;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Cài đặt thời gian'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SwitchListTile(
                title: const Text('Bật giới hạn thời gian'),
                subtitle: const Text('Áp dụng cho tất cả câu hỏi'),
                value: enableTimeLimit,
                onChanged: (value) {
                  setState(() {
                    enableTimeLimit = value;
                  });
                },
              ),
              if (enableTimeLimit) ...[
                const SizedBox(height: 16),
                Text('Thời gian mỗi câu: ${timeLimitSeconds}s'),
                Slider(
                  value: timeLimitSeconds.toDouble(),
                  min: 10,
                  max: 120,
                  divisions: 11,
                  onChanged: (value) {
                    setState(() {
                      timeLimitSeconds = value.round();
                    });
                  },
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Hủy'),
            ),
            TextButton(
              onPressed: () {
                aiProvider.toggleTimeLimitForAllQuestions(
                  enableTimeLimit,
                  timeLimitSeconds,
                );
                Navigator.of(context).pop();
              },
              child: const Text('Áp dụng'),
            ),
          ],
        ),
      ),
    );
  }

  void _showRegenerateDialog(AiQuizProvider aiProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tạo lại Quiz'),
        content: const Text(
          'Bạn có muốn tạo lại quiz với các câu hỏi mới? Dữ liệu hiện tại sẽ bị mất.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop(); // Go back to create screen
            },
            child: const Text('Tạo lại'),
          ),
        ],
      ),
    );
  }

  void _discardQuiz(AiQuizProvider aiProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hủy bỏ Quiz'),
        content: const Text(
          'Bạn có chắc chắn muốn hủy bỏ quiz này? Tất cả dữ liệu sẽ bị mất.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Tiếp tục chỉnh sửa'),
          ),
          TextButton(
            onPressed: () {
              aiProvider.clearGeneratedData();
              Navigator.of(context).pop(); // Close dialog
              Navigator.of(context).pop(); // Go back to create screen
            },
            child: const Text(
              'Hủy bỏ',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  void _addToCurrentQuiz(AiQuizProvider aiProvider) async {
    try {
      final quizProvider = context.read<QuizProvider>();
      final authProvider = context.read<AuthProvider>();

      // Store questions count before clearing
      final questionsCount = aiProvider.generatedQuestions.length;

      // Update quiz details if needed
      if (_titleController.text.trim().isNotEmpty) {
        quizProvider.updateQuizDetails(
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          categoryId: _selectedCategory?.categoryId,
          difficulty: _selectedDifficulty ?? QuizDifficulty.intermediate,
        );
      }

      // Add all questions to current quiz
      for (final question in aiProvider.generatedQuestions) {
        quizProvider.addQuestion(question);
      }

      // Increment AI generation counter
      await authProvider.incrementAIGeneration();

      // Clear generated data
      aiProvider.clearGeneratedData();

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ Đã thêm $questionsCount câu hỏi vào quiz'),
            backgroundColor: AppColors.success,
          ),
        );

        // Go back to create screen
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Lỗi khi thêm câu hỏi: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  CategoryEntity? _mapStringToCategory(String? categoryString) {
    if (categoryString == null) return null;

    final categoryProvider = context.read<CategoryProvider>();
    try {
      // Try to find category by name first
      return categoryProvider.categories.firstWhere(
        (cat) => cat.name.toLowerCase() == categoryString.toLowerCase(),
      );
    } catch (e) {
      // If not found by name, try by slug
      try {
        return categoryProvider.categories.firstWhere(
          (cat) => cat.slug == categoryString,
        );
      } catch (e) {
        // If still not found, return null
        return null;
      }
    }
  }
}

// Dialog for adding new questions
class _AddQuestionDialog extends StatefulWidget {
  final Function(QuestionEntity) onQuestionAdded;

  const _AddQuestionDialog({required this.onQuestionAdded});

  @override
  State<_AddQuestionDialog> createState() => _AddQuestionDialogState();
}

class _AddQuestionDialogState extends State<_AddQuestionDialog> {
  final _formKey = GlobalKey<FormState>();
  final _questionController = TextEditingController();
  final _explanationController = TextEditingController();
  final List<TextEditingController> _optionControllers = [
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
  ];
  int _correctAnswerIndex = 0;
  int _timeLimitSeconds = 30;
  bool _enableTimeLimit = false;

  @override
  void dispose() {
    _questionController.dispose();
    _explanationController.dispose();
    for (final controller in _optionControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Thêm câu hỏi mới'),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.8,
        height: MediaQuery.of(context).size.height * 0.7,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Question text
                TextFormField(
                  controller: _questionController,
                  decoration: const InputDecoration(
                    labelText: 'Câu hỏi',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Vui lòng nhập câu hỏi';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Options
                ...List.generate(4, (index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Radio<int>(
                          value: index,
                          groupValue: _correctAnswerIndex,
                          onChanged: (value) {
                            setState(() {
                              _correctAnswerIndex = value!;
                            });
                          },
                        ),
                        Expanded(
                          child: TextFormField(
                            controller: _optionControllers[index],
                            decoration: InputDecoration(
                              labelText: 'Lựa chọn ${index + 1}',
                              border: const OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Vui lòng nhập lựa chọn';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                  );
                }),

                const SizedBox(height: 16),

                // Explanation
                TextFormField(
                  controller: _explanationController,
                  decoration: const InputDecoration(
                    labelText: 'Giải thích (tùy chọn)',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),

                const SizedBox(height: 16),

                // Time limit
                SwitchListTile(
                  title: const Text('Giới hạn thời gian'),
                  subtitle: Text(
                    _enableTimeLimit ? '${_timeLimitSeconds}s' : 'Tự do',
                  ),
                  value: _enableTimeLimit,
                  onChanged: (value) {
                    setState(() {
                      _enableTimeLimit = value;
                    });
                  },
                ),

                if (_enableTimeLimit) ...[
                  const SizedBox(height: 8),
                  Text('Thời gian: ${_timeLimitSeconds}s'),
                  Slider(
                    value: _timeLimitSeconds.toDouble(),
                    min: 10,
                    max: 120,
                    divisions: 11,
                    onChanged: (value) {
                      setState(() {
                        _timeLimitSeconds = value.round();
                      });
                    },
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Hủy'),
        ),
        ElevatedButton(onPressed: _saveQuestion, child: const Text('Thêm')),
      ],
    );
  }

  void _saveQuestion() {
    if (_formKey.currentState!.validate()) {
      final question = QuestionEntity(
        questionId: '',
        question: _questionController.text.trim(),
        type: QuestionType.multipleChoice,
        options: _optionControllers.map((c) => c.text.trim()).toList(),
        correctAnswerIndex: _correctAnswerIndex,
        explanation: _explanationController.text.trim().isEmpty
            ? null
            : _explanationController.text.trim(),
        order: 0,
        timeLimit: _enableTimeLimit ? _timeLimitSeconds : 0,
        imageUrl: null,
      );

      widget.onQuestionAdded(question);
    }
  }
}

// Dialog for editing questions
class _EditQuestionDialog extends StatefulWidget {
  final QuestionEntity question;
  final Function(QuestionEntity) onQuestionUpdated;

  const _EditQuestionDialog({
    required this.question,
    required this.onQuestionUpdated,
  });

  @override
  State<_EditQuestionDialog> createState() => _EditQuestionDialogState();
}

class _EditQuestionDialogState extends State<_EditQuestionDialog> {
  late final _formKey = GlobalKey<FormState>();
  late final _questionController = TextEditingController(
    text: widget.question.question,
  );
  late final _explanationController = TextEditingController(
    text: widget.question.explanation ?? '',
  );
  late final List<TextEditingController> _optionControllers = widget
      .question
      .options
      .map((option) => TextEditingController(text: option))
      .toList();
  late int _correctAnswerIndex = widget.question.correctAnswerIndex;
  late int _timeLimitSeconds = widget.question.timeLimit;
  late bool _enableTimeLimit = widget.question.timeLimit > 0;

  @override
  void dispose() {
    _questionController.dispose();
    _explanationController.dispose();
    for (final controller in _optionControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Chỉnh sửa câu hỏi'),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.8,
        height: MediaQuery.of(context).size.height * 0.7,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Question text
                TextFormField(
                  controller: _questionController,
                  decoration: const InputDecoration(
                    labelText: 'Câu hỏi',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Vui lòng nhập câu hỏi';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Options
                ...List.generate(4, (index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Radio<int>(
                          value: index,
                          groupValue: _correctAnswerIndex,
                          onChanged: (value) {
                            setState(() {
                              _correctAnswerIndex = value!;
                            });
                          },
                        ),
                        Expanded(
                          child: TextFormField(
                            controller: _optionControllers[index],
                            decoration: InputDecoration(
                              labelText: 'Lựa chọn ${index + 1}',
                              border: const OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Vui lòng nhập lựa chọn';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                  );
                }),

                const SizedBox(height: 16),

                // Explanation
                TextFormField(
                  controller: _explanationController,
                  decoration: const InputDecoration(
                    labelText: 'Giải thích (tùy chọn)',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),

                const SizedBox(height: 16),

                // Time limit
                SwitchListTile(
                  title: const Text('Giới hạn thời gian'),
                  subtitle: Text(
                    _enableTimeLimit ? '${_timeLimitSeconds}s' : 'Tự do',
                  ),
                  value: _enableTimeLimit,
                  onChanged: (value) {
                    setState(() {
                      _enableTimeLimit = value;
                    });
                  },
                ),

                if (_enableTimeLimit) ...[
                  const SizedBox(height: 8),
                  Text('Thời gian: ${_timeLimitSeconds}s'),
                  Slider(
                    value: _timeLimitSeconds.toDouble(),
                    min: 10,
                    max: 120,
                    divisions: 11,
                    onChanged: (value) {
                      setState(() {
                        _timeLimitSeconds = value.round();
                      });
                    },
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Hủy'),
        ),
        ElevatedButton(onPressed: _saveQuestion, child: const Text('Lưu')),
      ],
    );
  }

  void _saveQuestion() {
    if (_formKey.currentState!.validate()) {
      final updatedQuestion = QuestionEntity(
        questionId: widget.question.questionId,
        question: _questionController.text.trim(),
        type: widget.question.type,
        options: _optionControllers.map((c) => c.text.trim()).toList(),
        correctAnswerIndex: _correctAnswerIndex,
        explanation: _explanationController.text.trim().isEmpty
            ? null
            : _explanationController.text.trim(),
        order: widget.question.order,
        timeLimit: _enableTimeLimit ? _timeLimitSeconds : 0,
        imageUrl: widget.question.imageUrl,
      );

      widget.onQuestionUpdated(updatedQuestion);
    }
  }
}
