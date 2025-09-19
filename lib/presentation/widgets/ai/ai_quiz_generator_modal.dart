import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/ai_quiz_provider.dart';
import '../../../core/themes/app_colors.dart';

class AiQuizGeneratorModal extends StatefulWidget {
  const AiQuizGeneratorModal({super.key});

  @override
  State<AiQuizGeneratorModal> createState() => _AiQuizGeneratorModalState();
}

class _AiQuizGeneratorModalState extends State<AiQuizGeneratorModal> {
  final _formKey = GlobalKey<FormState>();
  final _inputController = TextEditingController();

  String _sourceType = 'topic'; // topic, text, url
  int _numQuestions = 5;
  String _difficulty = 'medium';
  String _language = 'vi';
  String? _category;

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AiQuizProvider>(
      builder: (context, aiProvider, child) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            constraints: const BoxConstraints(maxWidth: 500, maxHeight: 700),
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 24),
                Expanded(
                  child: SingleChildScrollView(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSourceTypeSelector(),
                          const SizedBox(height: 20),
                          _buildInputField(),
                          const SizedBox(height: 20),
                          _buildOptionsSection(),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                _buildActionButtons(aiProvider),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.auto_awesome,
            color: AppColors.primary,
            size: 24,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Tạo Quiz bằng AI',
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                'Tự động tạo câu hỏi từ chủ đề hoặc nội dung',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.close, color: AppColors.textSecondary),
        ),
      ],
    );
  }

  Widget _buildSourceTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Nguồn nội dung',
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: [
              _buildSourceOption(
                'topic',
                'Chủ đề',
                'Nhập chủ đề, từ khóa',
                Icons.lightbulb_outline,
              ),
              const Divider(height: 1, color: AppColors.border),
              _buildSourceOption(
                'text',
                'Đoạn văn bản',
                'Dán nội dung, bài viết',
                Icons.article_outlined,
              ),
              const Divider(height: 1, color: AppColors.border),
              _buildSourceOption(
                'url',
                'Liên kết URL',
                'URL bài viết, trang web',
                Icons.link_outlined,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSourceOption(
    String value,
    String title,
    String subtitle,
    IconData icon,
  ) {
    final isSelected = _sourceType == value;

    return InkWell(
      onTap: () => setState(() => _sourceType = value),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
              size: 24,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Radio<String>(
              value: value,
              groupValue: _sourceType,
              onChanged: (val) => setState(() => _sourceType = val!),
              activeColor: AppColors.primary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField() {
    String label, hint;
    int maxLines;

    switch (_sourceType) {
      case 'topic':
        label = 'Chủ đề hoặc từ khóa';
        hint = 'VD: Lịch sử Việt Nam, Toán học lớp 12, JavaScript...';
        maxLines = 2;
        break;
      case 'text':
        label = 'Nội dung văn bản';
        hint = 'Dán đoạn văn, bài viết mà bạn muốn tạo quiz từ đó...';
        maxLines = 6;
        break;
      case 'url':
        label = 'URL liên kết';
        hint = 'https://example.com/article';
        maxLines = 1;
        break;
      default:
        label = 'Nội dung';
        hint = 'Nhập nội dung...';
        maxLines = 3;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _inputController,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.inter(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
            contentPadding: const EdgeInsets.all(16),
          ),
          style: GoogleFonts.inter(fontSize: 14),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Vui lòng nhập nội dung';
            }
            if (_sourceType == 'topic' && value.trim().length < 3) {
              return 'Chủ đề phải có ít nhất 3 ký tự';
            }
            if (_sourceType == 'text' && value.trim().length < 50) {
              return 'Nội dung quá ngắn (tối thiểu 50 ký tự)';
            }
            if (_sourceType == 'url' &&
                (Uri.tryParse(value.trim())?.hasAbsolutePath != true)) {
              return 'URL không hợp lệ';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildOptionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tùy chọn quiz',
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),

        // Number of questions
        _buildSliderOption(
          'Số câu hỏi',
          _numQuestions.toString(),
          _numQuestions.toDouble(),
          5.0,
          15.0,
          5,
          (value) => setState(() => _numQuestions = value.round()),
        ),
        const SizedBox(height: 20),

        // Difficulty
        _buildDropdownOption('Độ khó', _difficulty, [
          {'value': 'easy', 'label': 'Dễ'},
          {'value': 'medium', 'label': 'Trung bình'},
          {'value': 'hard', 'label': 'Khó'},
        ], (value) => setState(() => _difficulty = value!)),
        const SizedBox(height: 20),

        // Language
        _buildDropdownOption('Ngôn ngữ', _language, [
          {'value': 'vi', 'label': 'Tiếng Việt'},
          {'value': 'en', 'label': 'English'},
        ], (value) => setState(() => _language = value!)),
      ],
    );
  }

  Widget _buildSliderOption(
    String label,
    String value,
    double currentValue,
    double min,
    double max,
    int divisions,
    ValueChanged<double> onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                value,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: AppColors.primary,
            inactiveTrackColor: AppColors.primary.withOpacity(0.2),
            thumbColor: AppColors.primary,
            overlayColor: AppColors.primary.withOpacity(0.1),
          ),
          child: Slider(
            value: currentValue,
            min: min,
            max: max,
            divisions: divisions,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownOption(
    String label,
    String value,
    List<Map<String, String>> options,
    ValueChanged<String?> onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
          items: options.map((option) {
            return DropdownMenuItem<String>(
              value: option['value'],
              child: Text(
                option['label']!,
                style: GoogleFonts.inter(fontSize: 14),
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildActionButtons(AiQuizProvider aiProvider) {
    return Row(
      children: [
        Expanded(
          child: TextButton(
            onPressed: aiProvider.isGenerating
                ? null
                : () => Navigator.of(context).pop(),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Hủy',
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
            onPressed: aiProvider.isGenerating ? null : _generateQuiz,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: aiProvider.isGenerating
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Đang tạo...',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.auto_awesome, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Tạo Quiz',
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
    );
  }

  void _generateQuiz() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final aiProvider = context.read<AiQuizProvider>();

    try {
      await aiProvider.generateQuiz(
        input: _inputController.text.trim(),
        numQuestions: _numQuestions,
        difficulty: _difficulty,
        language: _language,
        category: _category,
      );

      if (mounted && aiProvider.hasGeneratedQuiz) {
        Navigator.of(context).pop('success');
      }
    } catch (e) {
      // Error is handled by the provider
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(aiProvider.error ?? 'Có lỗi xảy ra'),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }
}
