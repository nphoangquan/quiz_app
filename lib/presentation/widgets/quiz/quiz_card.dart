import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/themes/app_colors.dart';
import '../../../core/utils/category_mapper.dart';
import '../../../domain/entities/quiz_entity.dart';

class QuizCard extends StatelessWidget {
  final QuizEntity quiz;
  final VoidCallback? onTap;

  const QuizCard({super.key, required this.quiz, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap:
          onTap ??
          () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Quiz "${quiz.title}" sẽ có trong phiên bản tiếp theo',
                ),
                duration: const Duration(seconds: 2),
              ),
            );
          },
      child: Container(
        constraints: const BoxConstraints(minWidth: 280, maxWidth: 320),
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? AppColors.surfaceDark
              : AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.lightGrey.withOpacity(0.5),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category & Difficulty
                  Row(
                    children: [
                      _buildCategoryChip(),
                      const SizedBox(width: 8),
                      _buildDifficultyChip(),
                      const Spacer(),
                      Icon(
                        quiz.isPublic ? Icons.public : Icons.lock,
                        size: 16,
                        color: AppColors.grey,
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Title
                  Text(
                    quiz.title,
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).textTheme.headlineMedium?.color,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 8),

                  // Description
                  Text(
                    quiz.description,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: AppColors.grey,
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // Stats
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  _buildStat(Icons.quiz, '${quiz.questionCount} câu'),
                  const SizedBox(width: 16),
                  _buildStat(Icons.people, '${quiz.stats.totalAttempts}'),
                  const SizedBox(width: 16),
                  _buildStat(Icons.star, quiz.stats.rating.toStringAsFixed(1)),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Footer
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppColors.backgroundDark
                    : AppColors.surfaceLight,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  // Author
                  CircleAvatar(
                    radius: 12,
                    backgroundColor: AppColors.primary,
                    backgroundImage: quiz.ownerAvatar != null
                        ? NetworkImage(quiz.ownerAvatar!)
                        : null,
                    child: quiz.ownerAvatar == null
                        ? Text(
                            quiz.ownerName.substring(0, 1).toUpperCase(),
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: AppColors.white,
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      quiz.ownerName,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppColors.grey,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    _formatDate(quiz.createdAt),
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: AppColors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryChip() {
    final categoryData = _getCategoryData(quiz.category);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: categoryData.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        categoryData.name,
        style: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: categoryData.color,
        ),
      ),
    );
  }

  Widget _buildDifficultyChip() {
    Color color;
    String text;

    switch (quiz.difficulty) {
      case QuizDifficulty.beginner:
        color = Colors.green;
        text = 'Dễ';
        break;
      case QuizDifficulty.intermediate:
        color = Colors.orange;
        text = 'Trung bình';
        break;
      case QuizDifficulty.advanced:
        color = Colors.red;
        text = 'Khó';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Widget _buildStat(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 14, color: AppColors.grey),
        const SizedBox(width: 4),
        Text(
          text,
          style: GoogleFonts.inter(fontSize: 12, color: AppColors.grey),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date).inDays;

    if (diff == 0) return 'Hôm nay';
    if (diff == 1) return 'Hôm qua';
    if (diff < 7) return '$diff ngày trước';
    if (diff < 30) return '${(diff / 7).floor()} tuần trước';
    return '${(diff / 30).floor()} tháng trước';
  }

  _CategoryData _getCategoryData(QuizCategory category) {
    return _CategoryData(
      CategoryMapper.getDisplayName(category),
      _getCategoryColor(category),
    );
  }

  Color _getCategoryColor(QuizCategory category) {
    switch (category) {
      case QuizCategory.programming:
        return AppColors.primary;
      case QuizCategory.mathematics:
        return Colors.orange;
      case QuizCategory.science:
        return Colors.green;
      case QuizCategory.history:
        return Colors.brown;
      case QuizCategory.language:
        return Colors.blue;
      case QuizCategory.geography:
        return Colors.teal;
      case QuizCategory.sports:
        return Colors.red;
      case QuizCategory.entertainment:
        return Colors.purple;
      case QuizCategory.general:
        return AppColors.grey;
    }
  }
}

class _CategoryData {
  final String name;
  final Color color;

  const _CategoryData(this.name, this.color);
}
