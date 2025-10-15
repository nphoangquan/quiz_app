import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/themes/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../domain/entities/question_entity.dart';
import '../../providers/quiz_provider.dart';

class QuestionEditorScreen extends StatefulWidget {
  final QuestionEntity? question;
  final int? questionIndex;

  const QuestionEditorScreen({super.key, this.question, this.questionIndex});

  @override
  State<QuestionEditorScreen> createState() => _QuestionEditorScreenState();
}

class _QuestionEditorScreenState extends State<QuestionEditorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _questionController = TextEditingController();
  final _explanationController = TextEditingController();
  final _pointsController = TextEditingController();
  final _timeLimitController = TextEditingController();

  QuestionType _selectedType = QuestionType.multipleChoice;
  List<TextEditingController> _optionControllers = [];
  int _correctAnswerIndex = 0;

  bool get _isEditing => widget.question != null;

  @override
  void initState() {
    super.initState();
    _initializeFields();
  }

  void _initializeFields() {
    if (_isEditing) {
      final question = widget.question!;
      _questionController.text = question.question;
      _explanationController.text = question.explanation ?? '';
      _pointsController.text = question.points.toString();
      _timeLimitController.text = question.timeLimit.toString();
      _selectedType = question.type;
      _correctAnswerIndex = question.correctAnswerIndex;

      // Initialize option controllers
      _optionControllers = question.options
          .map((option) => TextEditingController(text: option))
          .toList();
    } else {
      _pointsController.text = '10';
      _timeLimitController.text = '0';
      _initializeDefaultOptions();
    }
  }

  void _initializeDefaultOptions() {
    _optionControllers.clear();
    if (_selectedType == QuestionType.multipleChoice) {
      // 4 options for multiple choice
      for (int i = 0; i < 4; i++) {
        _optionControllers.add(TextEditingController());
      }
    } else {
      // 2 options for true/false
      _optionControllers.add(TextEditingController(text: 'Đúng'));
      _optionControllers.add(TextEditingController(text: 'Sai'));
    }
    _correctAnswerIndex = 0;
  }

  @override
  void dispose() {
    _questionController.dispose();
    _explanationController.dispose();
    _pointsController.dispose();
    _timeLimitController.dispose();
    for (var controller in _optionControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          _isEditing ? 'Chỉnh sửa câu hỏi' : 'Thêm câu hỏi mới',
          style: GoogleFonts.inter(fontWeight: FontWeight.bold),
        ),
        actions: [
          TextButton.icon(
            onPressed: _saveQuestion,
            icon: const Icon(Icons.save, color: AppColors.primary),
            label: Text(
              'Lưu',
              style: GoogleFonts.inter(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Question Type Selector
              _buildQuestionTypeSelector(),

              const SizedBox(height: 24),

              // Question Text
              _buildQuestionTextField(),

              const SizedBox(height: 24),

              // Options Section
              _buildOptionsSection(),

              const SizedBox(height: 24),

              // Settings Section
              _buildSettingsSection(),

              const SizedBox(height: 24),

              // Explanation Section
              _buildExplanationSection(),

              const SizedBox(height: 32),

              // Action Buttons
              _buildActionButtons(),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuestionTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Loại câu hỏi',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).textTheme.headlineMedium?.color,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildTypeOption(
                QuestionType.multipleChoice,
                'Trắc nghiệm',
                'Nhiều lựa chọn (A, B, C, D)',
                Icons.radio_button_checked,
                Colors.blue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildTypeOption(
                QuestionType.trueFalse,
                'Đúng/Sai',
                'Chỉ có 2 lựa chọn',
                Icons.check_box,
                Colors.green,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTypeOption(
    QuestionType type,
    String title,
    String subtitle,
    IconData icon,
    Color color,
  ) {
    final isSelected = _selectedType == type;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedType = type;
          _initializeDefaultOptions();
        });
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withOpacity(0.1)
              : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : AppColors.lightGrey,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, size: 32, color: isSelected ? color : AppColors.grey),
            const SizedBox(height: 8),
            Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isSelected ? color : AppColors.grey,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: GoogleFonts.inter(fontSize: 12, color: AppColors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionTextField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Câu hỏi *',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).textTheme.headlineMedium?.color,
          ),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _questionController,
          maxLines: 3,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Vui lòng nhập nội dung câu hỏi';
            }
            if (value.trim().length < 5) {
              return 'Câu hỏi phải có ít nhất 5 ký tự';
            }
            return null;
          },
          decoration: InputDecoration(
            hintText: 'Nhập nội dung câu hỏi của bạn...',
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

  Widget _buildOptionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Các lựa chọn *',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.headlineMedium?.color,
              ),
            ),
            const SizedBox(width: 8),
            if (_selectedType == QuestionType.multipleChoice)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'Chọn đáp án đúng',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),

        ...List.generate(_optionControllers.length, (index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildOptionField(index),
          );
        }),

        // Add/Remove option buttons for multiple choice
        if (_selectedType == QuestionType.multipleChoice) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              if (_optionControllers.length < 6)
                TextButton.icon(
                  onPressed: _addOption,
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Thêm lựa chọn'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primary,
                  ),
                ),
              const SizedBox(width: 16),
              if (_optionControllers.length > 2)
                TextButton.icon(
                  onPressed: _removeLastOption,
                  icon: const Icon(Icons.remove, size: 16),
                  label: const Text('Xóa lựa chọn cuối'),
                  style: TextButton.styleFrom(foregroundColor: AppColors.error),
                ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildOptionField(int index) {
    final isCorrect = _correctAnswerIndex == index;
    final optionLabel = _selectedType == QuestionType.multipleChoice
        ? String.fromCharCode(65 + index) // A, B, C, D...
        : (index == 0 ? '✓' : '✗');

    return Row(
      children: [
        // Radio button or checkbox for correct answer
        GestureDetector(
          onTap: () {
            setState(() {
              _correctAnswerIndex = index;
            });
          },
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: isCorrect
                  ? Colors.green.withOpacity(0.1)
                  : AppColors.lightGrey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isCorrect ? Colors.green : AppColors.lightGrey,
                width: 2,
              ),
            ),
            child: Center(
              child: Text(
                optionLabel,
                style: GoogleFonts.inter(
                  fontSize: _selectedType == QuestionType.multipleChoice
                      ? 14
                      : 16,
                  fontWeight: FontWeight.bold,
                  color: isCorrect ? Colors.green : AppColors.grey,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
              ),
            ),
          ),
        ),

        const SizedBox(width: 12),

        // Option text field
        Expanded(
          child: TextFormField(
            controller: _optionControllers[index],
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Vui lòng nhập nội dung lựa chọn';
              }
              return null;
            },
            decoration: InputDecoration(
              hintText: 'Nhập nội dung lựa chọn ${optionLabel}...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: isCorrect
                      ? Colors.green
                      : AppColors.lightGrey.withOpacity(0.5),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: isCorrect
                      ? Colors.green.withOpacity(0.7)
                      : AppColors.lightGrey.withOpacity(0.5),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: isCorrect ? Colors.green : AppColors.primary,
                  width: 2,
                ),
              ),
              filled: true,
              fillColor: isCorrect
                  ? Colors.green.withOpacity(0.05)
                  : Theme.of(context).brightness == Brightness.dark
                  ? AppColors.surfaceDark
                  : AppColors.white,
            ),
          ),
        ),

        // Correct answer indicator
        if (isCorrect) ...[
          const SizedBox(width: 8),
          const Icon(Icons.check_circle, color: Colors.green, size: 20),
        ],
      ],
    );
  }

  Widget _buildSettingsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Cài đặt câu hỏi',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).textTheme.headlineMedium?.color,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Điểm số',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _pointsController,
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Nhập điểm số';
                      }
                      final points = int.tryParse(value);
                      if (points == null || points < 1 || points > 100) {
                        return 'Điểm từ 1-100';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      hintText: '10',
                      suffixText: 'điểm',
                      helperText: 'Từ 1-100 điểm',
                      helperStyle: GoogleFonts.inter(fontSize: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: true,
                      fillColor: Theme.of(context).brightness == Brightness.dark
                          ? AppColors.surfaceDark
                          : AppColors.white,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Thời gian (giây)',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _timeLimitController,
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Nhập thời gian';
                      }
                      final time = int.tryParse(value);
                      if (time == null || time < 0 || time > 300) {
                        return 'Thời gian từ 0-300s';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      hintText: '0',
                      suffixText: 'giây',
                      helperText: '0 = Không giới hạn',
                      helperStyle: GoogleFonts.inter(fontSize: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: true,
                      fillColor: Theme.of(context).brightness == Brightness.dark
                          ? AppColors.surfaceDark
                          : AppColors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildExplanationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Giải thích (Tùy chọn)',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).textTheme.headlineMedium?.color,
          ),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _explanationController,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'Thêm giải thích cho đáp án đúng (tùy chọn)...',
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
            filled: true,
            fillColor: Theme.of(context).brightness == Brightness.dark
                ? AppColors.surfaceDark
                : AppColors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.grey),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: Text(
              'Hủy',
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
            onPressed: _saveQuestion,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: Text(
              _isEditing ? 'Cập nhật' : 'Thêm câu hỏi',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _addOption() {
    if (_optionControllers.length < 6) {
      setState(() {
        _optionControllers.add(TextEditingController());
      });
    }
  }

  void _removeLastOption() {
    if (_optionControllers.length > 2) {
      setState(() {
        _optionControllers.removeLast().dispose();
        // Adjust correct answer index if needed
        if (_correctAnswerIndex >= _optionControllers.length) {
          _correctAnswerIndex = _optionControllers.length - 1;
        }
      });
    }
  }

  void _saveQuestion() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Validate that all options are filled
    for (int i = 0; i < _optionControllers.length; i++) {
      if (_optionControllers[i].text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Vui lòng điền đầy đủ tất cả các lựa chọn'),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }
    }

    final quizProvider = context.read<QuizProvider>();

    final questionEntity = QuestionEntity(
      questionId: _isEditing
          ? widget.question!.questionId
          : DateTime.now().millisecondsSinceEpoch.toString(),
      question: _questionController.text.trim(),
      type: _selectedType,
      options: _optionControllers
          .map((controller) => controller.text.trim())
          .toList(),
      correctAnswerIndex: _correctAnswerIndex,
      explanation: _explanationController.text.trim().isEmpty
          ? null
          : _explanationController.text.trim(),
      order: _isEditing
          ? widget.question!.order
          : quizProvider.currentQuestions.length,
      points: int.parse(_pointsController.text),
      timeLimit: int.parse(_timeLimitController.text),
    );

    if (_isEditing && widget.questionIndex != null) {
      quizProvider.updateQuestion(widget.questionIndex!, questionEntity);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Câu hỏi đã được cập nhật!'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      quizProvider.addQuestion(questionEntity);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Câu hỏi đã được thêm!'),
          backgroundColor: Colors.green,
        ),
      );
    }

    Navigator.of(context).pop(true);
  }
}
