import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/themes/app_colors.dart';
import '../../../domain/entities/quiz_entity.dart';
import '../quiz/quiz_card.dart';

class RecentQuizzesSection extends StatelessWidget {
  const RecentQuizzesSection({super.key});

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
              'Gần đây',
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
            itemCount: _sampleQuizzes.length,
            itemBuilder: (context, index) {
              return QuizCard(quiz: _sampleQuizzes[index]);
            },
          ),
        ),
      ],
    );
  }
}

// Sample data - sẽ được thay thế bằng data thật từ Firestore
final List<QuizEntity> _sampleQuizzes = [
  QuizEntity(
    quizId: '1',
    title: 'Flutter Cơ bản',
    description: 'Học những kiến thức nền tảng về Flutter framework',
    ownerId: 'user1',
    ownerName: 'Nguyễn Văn A',
    tags: ['flutter', 'mobile', 'dart'],
    category: QuizCategory.programming,
    isPublic: true,
    questionCount: 15,
    difficulty: QuizDifficulty.beginner,
    createdAt: DateTime.now().subtract(const Duration(days: 2)),
    updatedAt: DateTime.now().subtract(const Duration(days: 1)),
    stats: const QuizStats(
      totalAttempts: 234,
      averageScore: 78.5,
      likes: 45,
      rating: 4.6,
      ratingCount: 89,
    ),
  ),
  QuizEntity(
    quizId: '2',
    title: 'Toán học lớp 10',
    description: 'Ôn tập các kiến thức toán học cơ bản lớp 10',
    ownerId: 'user2',
    ownerName: 'Trần Thị B',
    tags: ['toán', 'lớp10', 'cơbản'],
    category: QuizCategory.mathematics,
    isPublic: true,
    questionCount: 20,
    difficulty: QuizDifficulty.intermediate,
    createdAt: DateTime.now().subtract(const Duration(days: 5)),
    updatedAt: DateTime.now().subtract(const Duration(days: 3)),
    stats: const QuizStats(
      totalAttempts: 156,
      averageScore: 65.2,
      likes: 23,
      rating: 4.2,
      ratingCount: 34,
    ),
  ),
  QuizEntity(
    quizId: '3',
    title: 'Lịch sử Việt Nam',
    description: 'Kiểm tra kiến thức về lịch sử Việt Nam qua các thời kỳ',
    ownerId: 'user3',
    ownerName: 'Lê Văn C',
    tags: ['lịchsử', 'việtnam', 'truyềnthống'],
    category: QuizCategory.history,
    isPublic: true,
    questionCount: 25,
    difficulty: QuizDifficulty.advanced,
    createdAt: DateTime.now().subtract(const Duration(days: 7)),
    updatedAt: DateTime.now().subtract(const Duration(days: 6)),
    stats: const QuizStats(
      totalAttempts: 89,
      averageScore: 72.8,
      likes: 34,
      rating: 4.4,
      ratingCount: 21,
    ),
  ),
];
