import 'package:flutter/material.dart';
import '../../data/services/gemini_ai_service.dart';
import '../../domain/entities/question_entity.dart';
// import '../../domain/entities/quiz_entity.dart';
// import '../../core/utils/category_mapper.dart';

class AiQuizProvider extends ChangeNotifier {
  final GeminiAiService _geminiService = GeminiAiService();

  // State variables
  bool _isGenerating = false;
  String? _error;
  Map<String, dynamic>? _generatedQuizData;
  List<QuestionEntity> _generatedQuestions = [];
  String? _generatedTitle;
  String? _generatedDescription;
  String? _generatedCategory;
  String? _generatedDifficulty;

  // Getters
  bool get isGenerating => _isGenerating;
  String? get error => _error;
  Map<String, dynamic>? get generatedQuizData => _generatedQuizData;
  List<QuestionEntity> get generatedQuestions => _generatedQuestions;
  String? get generatedTitle => _generatedTitle;
  String? get generatedDescription => _generatedDescription;
  String? get generatedCategory => _generatedCategory;
  String? get generatedDifficulty => _generatedDifficulty;
  bool get hasGeneratedQuiz => _generatedQuestions.isNotEmpty;

  /// Generate quiz using AI
  Future<void> generateQuiz({
    required String input,
    required int numQuestions,
    required String difficulty,
    required String language,
    String? category,
  }) async {
    try {
      _isGenerating = true;
      _error = null;
      _clearPreviousData();
      notifyListeners();

      print('🤖 Starting AI quiz generation...');
      print('Input: $input');
      print(
        'Questions: $numQuestions, Difficulty: $difficulty, Language: $language',
      );

      final quizData = await _geminiService.generateQuiz(
        input: input,
        numQuestions: numQuestions,
        difficulty: difficulty,
        language: language,
        category: category,
      );

      _generatedQuizData = quizData;
      _processGeneratedData(quizData);

      print('✅ AI quiz generation completed successfully');
      print('Generated ${_generatedQuestions.length} questions');
    } catch (e) {
      _error = _getErrorMessage(e);
      print('❌ AI quiz generation failed: $_error');
    } finally {
      _isGenerating = false;
      notifyListeners();
    }
  }

  /// Process the generated quiz data
  void _processGeneratedData(Map<String, dynamic> quizData) {
    try {
      // Extract quiz metadata
      final quiz = quizData['quiz'] as Map<String, dynamic>;
      _generatedTitle = quiz['title']?.toString();
      _generatedDescription = quiz['description']?.toString();
      _generatedDifficulty = quiz['difficulty']?.toString();

      // Try to map category
      final categorySlug = quiz['category']?.toString();
      if (categorySlug != null) {
        _generatedCategory = categorySlug;
      }

      // Process questions
      final questionsData = quizData['questions'] as List<dynamic>;
      _generatedQuestions = questionsData.map((questionData) {
        final data = questionData as Map<String, dynamic>;

        final options = (data['options'] as List<dynamic>)
            .map((option) => option.toString())
            .toList();

        final correctIndex = data['correctIndex'] as int;
        final explanation = data['explanation']?.toString();

        return QuestionEntity(
          questionId: '', // Will be generated when added to quiz
          question: data['question'].toString(),
          type: QuestionType.multipleChoice,
          options: options,
          correctAnswerIndex: correctIndex,
          explanation: explanation,
          order: 0, // Will be set when added to quiz
          timeLimit: 0, // Can be set later
          imageUrl: null,
        );
      }).toList();

      print('📊 Processed quiz data:');
      print('Title: $_generatedTitle');
      print('Category: $_generatedCategory');
      print('Questions: ${_generatedQuestions.length}');
    } catch (e) {
      throw Exception('Failed to process generated data: $e');
    }
  }

  /// Remove a question
  void removeGeneratedQuestion(int index) {
    if (index >= 0 && index < _generatedQuestions.length) {
      _generatedQuestions.removeAt(index);
      notifyListeners();
    }
  }

  /// Update quiz metadata
  void updateGeneratedQuizMetadata({
    String? title,
    String? description,
    String? category,
    String? difficulty,
  }) {
    if (title != null) _generatedTitle = title;
    if (description != null) _generatedDescription = description;
    if (category != null) _generatedCategory = category;
    if (difficulty != null) _generatedDifficulty = difficulty;
    notifyListeners();
  }

  /// Clear all generated data
  void clearGeneratedData() {
    _clearPreviousData();
    _error = null;
    notifyListeners();
  }

  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Clear previous data
  void _clearPreviousData() {
    _generatedQuizData = null;
    _generatedQuestions.clear();
    _generatedTitle = null;
    _generatedDescription = null;
    _generatedCategory = null;
    _generatedDifficulty = null;
  }

  /// Get user-friendly error message
  String _getErrorMessage(dynamic error) {
    final errorStr = error.toString().toLowerCase();

    if (errorStr.contains('network') || errorStr.contains('connection')) {
      return 'Lỗi kết nối mạng. Vui lòng kiểm tra internet và thử lại.';
    } else if (errorStr.contains('api error: 400')) {
      return 'Yêu cầu không hợp lệ. Vui lòng kiểm tra nội dung nhập vào.';
    } else if (errorStr.contains('api error: 401') ||
        errorStr.contains('api error: 403')) {
      return 'Lỗi xác thực API. Vui lòng liên hệ admin.';
    } else if (errorStr.contains('api error: 429')) {
      return 'Đã vượt quá giới hạn yêu cầu. Vui lòng thử lại sau vài phút.';
    } else if (errorStr.contains('json') || errorStr.contains('parse')) {
      return 'AI trả về dữ liệu không hợp lệ. Vui lòng thử lại.';
    } else if (errorStr.contains('validation')) {
      return 'Dữ liệu được tạo không đúng định dạng. Vui lòng thử lại.';
    } else {
      return 'Có lỗi xảy ra khi tạo quiz bằng AI. Vui lòng thử lại.';
    }
  }

  /// Check if AI service is configured
  bool get isAiConfigured => GeminiAiService.isConfigured;
}
