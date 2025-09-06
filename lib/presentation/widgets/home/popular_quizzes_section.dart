import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/themes/app_colors.dart';
import '../../../domain/entities/quiz_entity.dart';
import '../quiz/quiz_card.dart';

class PopularQuizzesSection extends StatelessWidget {
  const PopularQuizzesSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Phổ biến',
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.headlineMedium?.color,
              ),
            ),
            TextButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Tính năng xem tất cả sẽ có trong phiên bản tiếp theo',
                    ),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              child: Text(
                'Xem tất cả',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // Quiz List
        SizedBox(
          height: 240,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _popularQuizzes.length,
            itemBuilder: (context, index) {
              return QuizCard(quiz: _popularQuizzes[index]);
            },
          ),
        ),
      ],
    );
  }
}

// Sample popular quizzes - sorted by total attempts and rating
final List<QuizEntity> _popularQuizzes = [
  QuizEntity(
    quizId: '4',
    title: 'JavaScript ES6+',
    description:
        'Tìm hiểu các tính năng mới của JavaScript ES6 và những phiên bản sau',
    ownerId: 'user4',
    ownerName: 'Phạm Văn D',
    tags: ['javascript', 'es6', 'programming', 'web'],
    category: QuizCategory.programming,
    isPublic: true,
    questionCount: 30,
    difficulty: QuizDifficulty.intermediate,
    createdAt: DateTime.now().subtract(const Duration(days: 14)),
    updatedAt: DateTime.now().subtract(const Duration(days: 10)),
    stats: const QuizStats(
      totalAttempts: 1247,
      averageScore: 82.3,
      likes: 156,
      rating: 4.8,
      ratingCount: 203,
    ),
  ),
  QuizEntity(
    quizId: '5',
    title: 'Tiếng Anh giao tiếp',
    description: 'Luyện tập từ vựng và ngữ pháp tiếng Anh giao tiếp hàng ngày',
    ownerId: 'user5',
    ownerName: 'Hoàng Thị E',
    tags: ['english', 'communication', 'vocabulary'],
    category: QuizCategory.language,
    isPublic: true,
    questionCount: 40,
    difficulty: QuizDifficulty.beginner,
    createdAt: DateTime.now().subtract(const Duration(days: 21)),
    updatedAt: DateTime.now().subtract(const Duration(days: 15)),
    stats: const QuizStats(
      totalAttempts: 2156,
      averageScore: 75.6,
      likes: 289,
      rating: 4.7,
      ratingCount: 456,
    ),
  ),
  QuizEntity(
    quizId: '6',
    title: 'Vật lý đại cương',
    description:
        'Kiểm tra kiến thức vật lý cơ bản: cơ học, nhiệt học, điện học',
    ownerId: 'user6',
    ownerName: 'Vũ Văn F',
    tags: ['physics', 'science', 'mechanics'],
    category: QuizCategory.science,
    isPublic: true,
    questionCount: 35,
    difficulty: QuizDifficulty.advanced,
    createdAt: DateTime.now().subtract(const Duration(days: 30)),
    updatedAt: DateTime.now().subtract(const Duration(days: 25)),
    stats: const QuizStats(
      totalAttempts: 876,
      averageScore: 68.4,
      likes: 124,
      rating: 4.5,
      ratingCount: 167,
    ),
  ),
  QuizEntity(
    quizId: '7',
    title: 'Địa lý thế giới',
    description:
        'Khám phá kiến thức về các quốc gia, thủ đô và địa danh nổi tiếng',
    ownerId: 'user7',
    ownerName: 'Đỗ Thị G',
    tags: ['geography', 'world', 'countries', 'capitals'],
    category: QuizCategory.geography,
    isPublic: true,
    questionCount: 50,
    difficulty: QuizDifficulty.intermediate,
    createdAt: DateTime.now().subtract(const Duration(days: 45)),
    updatedAt: DateTime.now().subtract(const Duration(days: 40)),
    stats: const QuizStats(
      totalAttempts: 1543,
      averageScore: 71.2,
      likes: 198,
      rating: 4.6,
      ratingCount: 298,
    ),
  ),
];
