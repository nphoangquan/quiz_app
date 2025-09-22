import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/themes/app_colors.dart';
import '../../../domain/entities/quiz_entity.dart';
import '../quiz/quiz_card.dart';
import '../../screens/quiz/quiz_player_screen.dart';

class RecentQuizzesSection extends StatelessWidget {
  final List<QuizEntity> recentQuizzes;
  final bool isLoading;
  final VoidCallback? onViewAll;

  const RecentQuizzesSection({
    super.key,
    required this.recentQuizzes,
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
              'Gần đây',
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

        // Recent Quiz Cards - Horizontal Scrollable
        SizedBox(
          height:
              260, // Increased height to prevent overflow from AI-generated quiz
          child: isLoading
              ? const Center(child: CircularProgressIndicator())
              : recentQuizzes.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.history, size: 48, color: AppColors.grey),
                      const SizedBox(height: 12),
                      Text(
                        'Chưa có quiz gần đây',
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
                  itemCount: recentQuizzes.length,
                  itemBuilder: (context, index) {
                    return QuizCard(
                      quiz: recentQuizzes[index],
                      onTap: () =>
                          _navigateToQuizPlayer(context, recentQuizzes[index]),
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
