import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/themes/app_colors.dart';
import '../../../domain/entities/quiz_entity.dart';
import '../quiz/quiz_card.dart';
import '../../screens/quiz/quiz_player_screen.dart';

class FeaturedSection extends StatelessWidget {
  final List<QuizEntity> featuredQuizzes;
  final bool isLoading;

  const FeaturedSection({
    super.key,
    required this.featuredQuizzes,
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
              'Nổi bật',
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.headlineMedium?.color,
              ),
            ),
            TextButton(
              onPressed: () {
                ScaffoldMessenger.of(context).clearSnackBars();
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

        // Horizontal Scrollable Quiz Cards
        SizedBox(
          height:
              260, // Increased height to prevent overflow from AI-generated quiz
          child: isLoading
              ? const Center(child: CircularProgressIndicator())
              : featuredQuizzes.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.quiz, size: 48, color: AppColors.grey),
                      const SizedBox(height: 12),
                      Text(
                        'Chưa có quiz nổi bật',
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                  ), // Consistent padding
                  itemCount: featuredQuizzes.length,
                  itemBuilder: (context, index) {
                    final quiz = featuredQuizzes[index];
                    return QuizCard(
                      quiz: quiz,
                      onTap: () => _navigateToQuizPlayer(context, quiz),
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
