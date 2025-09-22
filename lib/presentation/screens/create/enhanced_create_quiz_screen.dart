import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/themes/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../domain/entities/quiz_entity.dart';
import '../../../domain/entities/question_entity.dart';
import '../../../domain/entities/category_entity.dart';
import '../../providers/quiz_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/category_provider.dart';
import '../../widgets/ai/ai_quiz_generator_modal.dart';
import '../ai/ai_quiz_preview_screen.dart';
import 'add_questions_screen.dart';

class EnhancedCreateQuizScreen extends StatefulWidget {
  final String? editQuizId; // Quiz ID to edit, null for new quiz

  const EnhancedCreateQuizScreen({super.key, this.editQuizId});

  @override
  State<EnhancedCreateQuizScreen> createState() =>
      _EnhancedCreateQuizScreenState();
}

class _EnhancedCreateQuizScreenState extends State<EnhancedCreateQuizScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _tagController = TextEditingController();

  CategoryEntity? _selectedCategory;
  QuizDifficulty _selectedDifficulty = QuizDifficulty.beginner;
  bool _isPublic = false;
  List<String> _tags = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.editQuizId != null) {
        _initializeEditQuiz();
      } else {
        _initializeNewQuiz();
      }
    });
  }

  void _initializeNewQuiz() {
    final authProvider = context.read<AuthProvider>();
    final quizProvider = context.read<QuizProvider>();

    if (authProvider.user != null) {
      quizProvider.initializeNewQuiz(
        authProvider.user!.uid,
        authProvider.user!.name,
      );
    }

    // Sync form with any existing quiz data
    _syncFormWithQuizProvider();
  }

  void _initializeEditQuiz() {
    final quizProvider = context.read<QuizProvider>();

    // Quiz data should already be loaded by loadQuizForEditing
    if (quizProvider.currentQuiz != null) {
      _populateFormWithQuizData(quizProvider.currentQuiz!);
    }
  }

  void _populateFormWithQuizData(QuizEntity quiz) {
    _titleController.text = quiz.title;
    _descriptionController.text = quiz.description;
    _selectedDifficulty = quiz.difficulty;
    _isPublic = quiz.isPublic;
    _tags = List<String>.from(quiz.tags);
    _tagController.text = _tags.join(', ');

    // Set category - prioritize categoryId, then fall back to enum mapping
    final categoryProvider = context.read<CategoryProvider>();

    if (quiz.categoryId != null && quiz.categoryId!.isNotEmpty) {
      // Find category by categoryId
      try {
        _selectedCategory = categoryProvider.categories.firstWhere(
          (cat) => cat.categoryId == quiz.categoryId,
        );
      } catch (e) {
        _selectedCategory = null;
      }
    } else {
      // No category set
      _selectedCategory = null;
    }

    setState(() {});
  }

  void _syncFormWithQuizProvider() {
    final quizProvider = context.read<QuizProvider>();

    if (quizProvider.currentQuiz != null) {
      final quiz = quizProvider.currentQuiz!;

      // Only update form if it has content from AI
      if (quiz.title.isNotEmpty && _titleController.text.isEmpty) {
        _titleController.text = quiz.title;
      }

      if (quiz.description.isNotEmpty && _descriptionController.text.isEmpty) {
        _descriptionController.text = quiz.description;
      }

      // Update difficulty and category
      _selectedDifficulty = quiz.difficulty;

      // No additional mapping needed - categoryId is already handled above

      _isPublic = quiz.isPublic;
      _tags = List<String>.from(quiz.tags);
      _tagController.text = _tags.join(', ');

      setState(() {});
    }
  }

  void _updateQuizDetails() {
    final quizProvider = context.read<QuizProvider>();

    quizProvider.updateQuizDetails(
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      tags: _tags,
      categoryId: _selectedCategory?.categoryId, // Just pass categoryId
      isPublic: _isPublic,
      difficulty: _selectedDifficulty,
    );
  }

  void _addTag() {
    final tagText = _tagController.text.trim();
    if (tagText.isNotEmpty && !_tags.contains(tagText)) {
      setState(() {
        _tags.add(tagText);
        _tagController.clear();
      });
      _updateQuizDetails();
    }
  }

  void _removeTag(String tag) {
    setState(() {
      _tags.remove(tag);
    });
    _updateQuizDetails();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<QuizProvider>(
      builder: (context, quizProvider, child) {
        // Auto-sync form when quiz provider updates (e.g., from AI)
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _syncFormWithQuizProvider();
        });

        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          body: SafeArea(
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  // Header
                  _buildHeader(quizProvider),

                  // Form
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(
                        AppConstants.defaultPadding,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Progress indicator
                          _buildProgressIndicator(quizProvider),

                          const SizedBox(height: 24),

                          // Title
                          _buildTextField(
                            controller: _titleController,
                            label: 'Tiêu đề quiz *',
                            hint: 'Nhập tiêu đề cho quiz của bạn',
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Vui lòng nhập tiêu đề quiz';
                              }
                              if (value.trim().length < 5) {
                                return 'Tiêu đề phải có ít nhất 5 ký tự';
                              }
                              return null;
                            },
                            onChanged: (value) => _updateQuizDetails(),
                          ),

                          const SizedBox(height: 20),

                          // Description
                          _buildTextField(
                            controller: _descriptionController,
                            label: 'Mô tả *',
                            hint: 'Mô tả ngắn gọn về nội dung quiz',
                            maxLines: 3,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Vui lòng nhập mô tả quiz';
                              }
                              if (value.trim().length < 10) {
                                return 'Mô tả phải có ít nhất 10 ký tự';
                              }
                              return null;
                            },
                            onChanged: (value) => _updateQuizDetails(),
                          ),

                          const SizedBox(height: 20),

                          // Category
                          _buildCategorySelector(),

                          const SizedBox(height: 20),

                          // Difficulty
                          _buildDifficultySelector(),

                          const SizedBox(height: 20),

                          // Public/Private
                          _buildPrivacyToggle(),

                          const SizedBox(height: 20),

                          // Tags
                          _buildTagsSection(),

                          const SizedBox(height: 32),

                          // Questions section
                          _buildQuestionsSection(quizProvider),

                          const SizedBox(height: 32),

                          // Action buttons
                          _buildActionButtons(quizProvider),

                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(QuizProvider quizProvider) {
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
      child: Row(
        children: [
          IconButton(
            onPressed: () {
              if (quizProvider.currentQuiz != null ||
                  quizProvider.currentQuestions.isNotEmpty) {
                _showDiscardDialog();
              } else {
                Navigator.of(context).pop();
              }
            },
            icon: const Icon(Icons.arrow_back),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              widget.editQuizId != null ? 'Chỉnh sửa Quiz' : 'Tạo Quiz Mới',
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.headlineLarge?.color,
              ),
            ),
          ),
          if (quizProvider.isLoading)
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator(QuizProvider quizProvider) {
    final hasBasicInfo =
        _titleController.text.isNotEmpty &&
        _descriptionController.text.isNotEmpty;
    final hasQuestions = quizProvider.currentQuestions.isNotEmpty;

    int currentStep = 0;
    if (hasBasicInfo) currentStep = 1;
    if (hasQuestions) currentStep = 2;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tiến độ tạo quiz',
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _buildStepIndicator(0, currentStep >= 0, 'Thông tin cơ bản'),
            _buildStepConnector(currentStep >= 1),
            _buildStepIndicator(1, currentStep >= 1, 'Câu hỏi'),
            _buildStepConnector(currentStep >= 2),
            _buildStepIndicator(2, currentStep >= 2, 'Hoàn thành'),
          ],
        ),
      ],
    );
  }

  Widget _buildStepIndicator(int step, bool isActive, String label) {
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: isActive ? AppColors.primary : AppColors.lightGrey,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: isActive
                  ? const Icon(Icons.check, color: AppColors.white, size: 16)
                  : Text(
                      '${step + 1}',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.grey,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: isActive ? AppColors.primary : AppColors.grey,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildStepConnector(bool isActive) {
    return Container(
      width: 40,
      height: 2,
      margin: const EdgeInsets.only(bottom: 24),
      color: isActive ? AppColors.primary : AppColors.lightGrey,
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    int maxLines = 1,
    String? Function(String?)? validator,
    void Function(String)? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          validator: validator,
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppColors.lightGrey.withOpacity(0.5),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppColors.lightGrey.withOpacity(0.5),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.error, width: 2),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.error, width: 2),
            ),
            filled: true,
            fillColor: Theme.of(context).brightness == Brightness.dark
                ? AppColors.surfaceDark
                : AppColors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildCategorySelector() {
    return Consumer<CategoryProvider>(
      builder: (context, categoryProvider, child) {
        final categories = categoryProvider.categories;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Danh mục',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<CategoryEntity>(
              value: _selectedCategory,
              hint: Text(
                'Chọn danh mục',
                style: GoogleFonts.inter(fontSize: 16, color: Colors.grey[600]),
              ),
              onChanged: (category) {
                setState(() {
                  _selectedCategory = category;
                });
                _updateQuizDetails();
              },
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: AppColors.lightGrey.withOpacity(0.5),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: AppColors.lightGrey.withOpacity(0.5),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: AppColors.primary,
                    width: 2,
                  ),
                ),
                filled: true,
                fillColor: Theme.of(context).brightness == Brightness.dark
                    ? AppColors.surfaceDark
                    : AppColors.white,
              ),
              items: categories.map((category) {
                return DropdownMenuItem(
                  value: category,
                  child: Text(
                    category.name,
                    style: GoogleFonts.inter(fontSize: 16),
                  ),
                );
              }).toList(),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDifficultySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Độ khó',
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: QuizDifficulty.values.map((difficulty) {
            final isSelected = _selectedDifficulty == difficulty;
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedDifficulty = difficulty;
                    });
                    _updateQuizDetails();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary.withOpacity(0.1)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.lightGrey,
                        width: 1,
                      ),
                    ),
                    child: Text(
                      _getDifficultyName(difficulty),
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? AppColors.primary : AppColors.grey,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildPrivacyToggle() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Quyền riêng tư',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _isPublic
                    ? 'Công khai - Mọi người có thể xem'
                    : 'Riêng tư - Chỉ bạn có thể xem',
                style: GoogleFonts.inter(fontSize: 14, color: AppColors.grey),
              ),
            ],
          ),
        ),
        Switch(
          value: _isPublic,
          onChanged: (value) {
            setState(() {
              _isPublic = value;
            });
            _updateQuizDetails();
          },
          activeColor: AppColors.primary,
        ),
      ],
    );
  }

  Widget _buildTagsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Thẻ (Tags)',
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _tagController,
                decoration: InputDecoration(
                  hintText: 'Thêm thẻ để dễ tìm kiếm',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: AppColors.lightGrey.withOpacity(0.5),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: AppColors.lightGrey.withOpacity(0.5),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: AppColors.primary,
                      width: 2,
                    ),
                  ),
                  filled: true,
                  fillColor: Theme.of(context).brightness == Brightness.dark
                      ? AppColors.surfaceDark
                      : AppColors.white,
                ),
                onSubmitted: (_) => _addTag(),
              ),
            ),
            const SizedBox(width: 12),
            ElevatedButton(
              onPressed: _addTag,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Thêm',
                style: TextStyle(color: AppColors.white),
              ),
            ),
          ],
        ),
        if (_tags.isNotEmpty) ...[
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _tags.map((tag) {
              return Chip(
                label: Text(tag),
                onDeleted: () => _removeTag(tag),
                backgroundColor: AppColors.primary.withOpacity(0.1),
                labelStyle: GoogleFonts.inter(
                  fontSize: 12,
                  color: AppColors.primary,
                ),
                deleteIcon: const Icon(Icons.close, size: 16),
                deleteIconColor: AppColors.primary,
              );
            }).toList(),
          ),
        ],
      ],
    );
  }

  Widget _buildQuestionsSection(QuizProvider quizProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Câu hỏi (${quizProvider.currentQuestions.length})',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.headlineMedium?.color,
              ),
            ),
            Row(
              children: [
                // AI Generate Button
                ElevatedButton.icon(
                  onPressed: () => _showAiGeneratorModal(),
                  icon: const Icon(
                    Icons.auto_awesome,
                    color: AppColors.white,
                    size: 18,
                  ),
                  label: const Text(
                    'Tạo bằng AI',
                    style: TextStyle(color: AppColors.white, fontSize: 14),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Manual Add Button
                ElevatedButton.icon(
                  onPressed: () => _navigateToAddQuestions(),
                  icon: const Icon(Icons.add, color: AppColors.white, size: 18),
                  label: const Text(
                    'Thêm câu hỏi',
                    style: TextStyle(color: AppColors.white, fontSize: 14),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (quizProvider.currentQuestions.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark
                  ? AppColors.surfaceDark
                  : AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.lightGrey.withOpacity(0.3),
                style: BorderStyle.solid,
                width: 2,
              ),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.quiz_outlined,
                  size: 64,
                  color: AppColors.grey.withOpacity(0.5),
                ),
                const SizedBox(height: 16),
                Text(
                  'Chưa có câu hỏi nào',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.grey,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Thêm ít nhất 1 câu hỏi để có thể tạo quiz',
                  style: GoogleFonts.inter(fontSize: 14, color: AppColors.grey),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: quizProvider.currentQuestions.length,
            itemBuilder: (context, index) {
              final question = quizProvider.currentQuestions[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                          Expanded(
                            child: Text(
                              question.question,
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              quizProvider.removeQuestion(index);
                            },
                            icon: const Icon(
                              Icons.delete,
                              color: AppColors.error,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Loại: ${question.type == QuestionType.multipleChoice ? "Trắc nghiệm" : "Đúng/Sai"}',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: AppColors.grey,
                        ),
                      ),
                      Text(
                        'Đáp án đúng: ${question.options[question.correctAnswerIndex]}',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
      ],
    );
  }

  Widget _buildActionButtons(QuizProvider quizProvider) {
    return Column(
      children: [
        if (quizProvider.hasError)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: AppColors.error.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.error.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.error_outline, color: AppColors.error),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    quizProvider.errorMessage ?? 'Có lỗi xảy ra',
                    style: GoogleFonts.inter(color: AppColors.error),
                  ),
                ),
                TextButton(
                  onPressed: () => quizProvider.clearError(),
                  child: const Text('Đóng'),
                ),
              ],
            ),
          ),

        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => _showDiscardDialog(),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.grey),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(
                  'Hủy bỏ',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.grey,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                onPressed: quizProvider.canSaveQuiz && !quizProvider.isLoading
                    ? () => _createQuiz(quizProvider)
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: quizProvider.isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.white,
                        ),
                      )
                    : Text(
                        widget.editQuizId != null
                            ? 'Cập nhật Quiz'
                            : 'Tạo Quiz',
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
      ],
    );
  }

  void _navigateToAddQuestions() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng điền đầy đủ thông tin cơ bản trước'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    _updateQuizDetails();

    final result = await Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const AddQuestionsScreen()));

    if (result == true) {
      // Questions were added, refresh the UI
      setState(() {});
    }
  }

  Future<void> _createQuiz(QuizProvider quizProvider) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final bool isEditMode = widget.editQuizId != null;
    final quizId = isEditMode
        ? await quizProvider.updateQuiz()
        : await quizProvider.createQuiz();

    if (quizId != null && mounted) {
      // Show success dialog instead of just snackbar
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green, size: 28),
                const SizedBox(width: 12),
                const Text('Thành công!'),
              ],
            ),
            content: Text(
              isEditMode
                  ? 'Quiz đã được cập nhật thành công! Bạn có muốn tiếp tục chỉnh sửa hay quay về trang chủ?'
                  : 'Quiz đã được tạo thành công! Bạn có muốn tiếp tục chỉnh sửa hay quay về trang chủ?',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close dialog
                  Navigator.of(context).pop(true); // Go back to create tab
                },
                child: const Text('Quay về'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close dialog
                  _navigateToAddQuestions();
                },
                child: const Text('Thêm câu hỏi'),
              ),
            ],
          );
        },
      );
    } else if (mounted) {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isEditMode
                ? '❌ Có lỗi xảy ra khi cập nhật quiz. Vui lòng thử lại!'
                : '❌ Có lỗi xảy ra khi tạo quiz. Vui lòng thử lại!',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showDiscardDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Xác nhận hủy bỏ'),
          content: const Text(
            'Bạn có chắc chắn muốn hủy bỏ việc tạo quiz này? Tất cả thông tin sẽ bị mất.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Tiếp tục tạo'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                context.read<QuizProvider>().clearCurrentQuiz();
                Navigator.of(context).pop();
              },
              child: const Text(
                'Hủy bỏ',
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

  /// Show AI Quiz Generator Modal
  void _showAiGeneratorModal() async {
    try {
      final result = await showDialog<String>(
        context: context,
        builder: (context) => const AiQuizGeneratorModal(),
      );

      if (result == 'success' && mounted) {
        // Navigate to preview screen
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => const AiQuizPreviewScreen()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Lỗi khi mở AI Generator: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
}
