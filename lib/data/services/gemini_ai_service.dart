import 'dart:convert';
import 'package:http/http.dart' as http;

class GeminiAiService {
  static const String _apiKey = 'YOUR_API_KEY_HERE';
  static const String _baseUrl =
      'https://generativelanguage.googleapis.com/v1/models/gemini-1.5-flash:generateContent';

  /// Generate quiz from input text/topic
  Future<Map<String, dynamic>> generateQuiz({
    required String input,
    required int numQuestions,
    required String difficulty,
    required String language,
    String? category,
  }) async {
    try {
      final prompt = _buildPrompt(
        input: input,
        numQuestions: numQuestions,
        difficulty: difficulty,
        language: language,
        category: category,
      );

      final response = await http.post(
        Uri.parse('$_baseUrl?key=$_apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {'text': prompt},
              ],
            },
          ],
          'generationConfig': {
            'temperature': 0.7,
            'topK': 40,
            'topP': 0.95,
            'maxOutputTokens': 8192,
          },
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('API Error: ${response.statusCode} - ${response.body}');
      }

      final data = jsonDecode(response.body);

      // Extract text from Gemini response
      final generatedText =
          data['candidates'][0]['content']['parts'][0]['text'];

      // Parse JSON from the generated text
      final quizData = _parseQuizJson(generatedText);

      return quizData;
    } catch (e) {
      print('❌ Gemini API Error: $e');
      rethrow;
    }
  }

  /// Build prompt for Gemini API
  String _buildPrompt({
    required String input,
    required int numQuestions,
    required String difficulty,
    required String language,
    String? category,
  }) {
    final languageInstruction = language == 'vi'
        ? 'Tạo câu hỏi bằng tiếng Việt'
        : 'Create questions in English';

    final difficultyMap = {
      'easy': language == 'vi' ? 'Dễ (cơ bản)' : 'Easy (basic)',
      'medium': language == 'vi'
          ? 'Trung bình (vừa phải)'
          : 'Medium (moderate)',
      'hard': language == 'vi' ? 'Khó (nâng cao)' : 'Hard (advanced)',
    };

    return '''
Bạn là chuyên gia tạo câu hỏi trắc nghiệm chất lượng cao.

NHIỆM VỤ: Tạo $numQuestions câu hỏi trắc nghiệm từ nội dung sau:
"$input"

YÊU CẦU:
- $languageInstruction
- Độ khó: ${difficultyMap[difficulty] ?? 'Trung bình'}
- Mỗi câu hỏi có đúng 4 đáp án (A, B, C, D)
- Chỉ có 1 đáp án đúng duy nhất
- Các đáp án sai phải hợp lý và không quá dễ loại trừ
- Câu hỏi phải rõ ràng, không gây nhầm lẫn
- Có giải thích ngắn gọn cho đáp án đúng

ĐỊNH DẠNG TRƯỚC VỀ JSON (QUAN TRỌNG):
Trả về CHÍNH XÁC định dạng JSON sau, không thêm text nào khác:

{
  "quiz": {
    "title": "Tiêu đề quiz phù hợp",
    "description": "Mô tả ngắn gọn về nội dung quiz",
    "category": "${category ?? 'khác'}",
    "difficulty": "$difficulty"
  },
  "questions": [
    {
      "question": "Nội dung câu hỏi?",
      "options": [
        "Đáp án A",
        "Đáp án B", 
        "Đáp án C",
        "Đáp án D"
      ],
      "correctIndex": 0,
      "explanation": "Giải thích tại sao đáp án A đúng"
    }
  ]
}

CHÚ Ý:
- correctIndex: 0=A, 1=B, 2=C, 3=D
- Đảm bảo JSON hợp lệ, không có lỗi syntax
- Không thêm markdown, code block hay text khác
- Chỉ trả về JSON thuần túy
''';
  }

  /// Parse quiz JSON from generated text
  Map<String, dynamic> _parseQuizJson(String generatedText) {
    try {
      // Clean the text - remove any markdown or extra formatting
      String cleanText = generatedText.trim();

      // Remove code blocks if present
      if (cleanText.startsWith('```json')) {
        cleanText = cleanText.replaceFirst('```json', '');
      }
      if (cleanText.startsWith('```')) {
        cleanText = cleanText.replaceFirst('```', '');
      }
      if (cleanText.endsWith('```')) {
        cleanText = cleanText.substring(0, cleanText.lastIndexOf('```'));
      }

      cleanText = cleanText.trim();

      // Try to find JSON object in the text
      int startIndex = cleanText.indexOf('{');
      int endIndex = cleanText.lastIndexOf('}');

      if (startIndex != -1 && endIndex != -1 && endIndex > startIndex) {
        cleanText = cleanText.substring(startIndex, endIndex + 1);
      }

      final quizData = jsonDecode(cleanText);

      // Validate the structure
      _validateQuizData(quizData);

      return quizData;
    } catch (e) {
      print('❌ JSON Parse Error: $e');
      print('Generated text: $generatedText');
      throw Exception('Không thể parse JSON từ AI response: $e');
    }
  }

  /// Validate quiz data structure
  void _validateQuizData(Map<String, dynamic> data) {
    // Check required fields
    if (!data.containsKey('quiz') || !data.containsKey('questions')) {
      throw Exception('Missing required fields: quiz or questions');
    }

    final quiz = data['quiz'] as Map<String, dynamic>;
    final questions = data['questions'] as List<dynamic>;

    // Validate quiz metadata
    if (!quiz.containsKey('title') || !quiz.containsKey('description')) {
      throw Exception('Missing quiz title or description');
    }

    // Validate questions
    if (questions.isEmpty) {
      throw Exception('No questions generated');
    }

    for (int i = 0; i < questions.length; i++) {
      final question = questions[i] as Map<String, dynamic>;

      // Check required question fields
      if (!question.containsKey('question') ||
          !question.containsKey('options') ||
          !question.containsKey('correctIndex')) {
        throw Exception('Question ${i + 1} missing required fields');
      }

      final options = question['options'] as List<dynamic>;
      final correctIndex = question['correctIndex'] as int;

      // Validate options
      if (options.length != 4) {
        throw Exception('Question ${i + 1} must have exactly 4 options');
      }

      // Validate correct index
      if (correctIndex < 0 || correctIndex >= 4) {
        throw Exception(
          'Question ${i + 1} has invalid correctIndex: $correctIndex',
        );
      }

      // Check for empty options
      for (int j = 0; j < options.length; j++) {
        if (options[j].toString().trim().isEmpty) {
          throw Exception('Question ${i + 1}, option ${j + 1} is empty');
        }
      }
    }

    print('✅ Quiz data validation passed');
  }

  /// Check if API key is configured
  static bool get isConfigured =>
      _apiKey.isNotEmpty && _apiKey != 'YOUR_API_KEY_HERE';
}
