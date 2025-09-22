import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/themes/app_colors.dart';
import '../../../domain/entities/quiz_entity.dart';
import '../quiz/quiz_card.dart';
import '../../screens/quiz/quiz_player_screen.dart';

class PopularQuizzesSection extends StatelessWidget {
  final List<QuizEntity> popularQuizzes;
  final bool isLoading;
  final VoidCallback? onViewAll;

  const PopularQuizzesSection({
    super.key,
    required this.popularQuizzes,
    required this.isLoading,
    this.onViewAll,
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
              onPressed: onViewAll,
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

        // Popular Quiz Cards - Horizontal Scrollable
        SizedBox(
          height:
              260, // Increased height to prevent overflow from AI-generated quiz
          child: isLoading
              ? const Center(child: CircularProgressIndicator())
              : popularQuizzes.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
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
              : ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: popularQuizzes.length,
                  itemBuilder: (context, index) {
                    return QuizCard(
                      quiz: popularQuizzes[index],
                      onTap: () =>
                          _navigateToQuizPlayer(context, popularQuizzes[index]),
                    );
                  },
                ),
        ),
      ],
    );
  }

  void _navigateToQuizPlayer(BuildContext context, QuizEntity quiz) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) =>
            QuizPlayerScreen(quizId: quiz.quizId, enableTimer: true),
      ),
    );
  }
}
