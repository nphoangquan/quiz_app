import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/themes/app_colors.dart';
import '../../../domain/entities/quiz_entity.dart';
import '../quiz/quiz_card.dart';
import '../../screens/quiz/quiz_player_screen.dart';

class PopularQuizzesSection extends StatelessWidget {
  final List<QuizEntity> popularQuizzes;
  final bool isLoading;

  const PopularQuizzesSection({
    super.key,
    required this.popularQuizzes,
    required this.isLoading,
  });

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

        // Popular Quiz Cards
        isLoading
            ? const Center(child: CircularProgressIndicator())
            : popularQuizzes.isEmpty
            ? Center(
                child: Column(
                  children: [
                    Icon(Icons.trending_up, size: 48, color: AppColors.grey),
                    const SizedBox(height: 12),
                    Text(
                      'Chưa có quiz phổ biến',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        color: AppColors.grey,
                      ),
                    ),
                  ],
                ),
              )
            : Column(
                children: popularQuizzes
                    .map(
                      (quiz) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: QuizCard(
                          quiz: quiz,
                          onTap: () => _navigateToQuizPlayer(context, quiz),
                        ),
                      ),
                    )
                    .toList(),
              ),
      ],
    );
  }

  void _navigateToQuizPlayer(BuildContext context, QuizEntity quiz) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) =>
            QuizPlayerScreen(quizId: quiz.quizId, enableTimer: false),
      ),
    );
  }
}
