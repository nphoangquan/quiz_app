import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/themes/app_colors.dart';
import '../../../domain/entities/quiz_entity.dart';
import '../../providers/category_provider.dart';

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
        width: 300,
        height: 240,
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? AppColors.surfaceDark
              : AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.lightGrey.withOpacity(0.2),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category & Status Row
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

                    const SizedBox(height: 16),

                    // Title
                    Text(
                      quiz.title,
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Theme.of(
                          context,
                        ).textTheme.headlineMedium?.color,
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 8),

                    // Description
                    Expanded(
                      child: Text(
                        quiz.description,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: AppColors.grey,
                          height: 1.4,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Stats Row
                    Row(
                      children: [
                        _buildStat(
                          Icons.quiz_outlined,
                          '${quiz.questionCount}',
                        ),
                        const SizedBox(width: 16),
                        _buildStat(
                          Icons.people_outline,
                          '${quiz.stats.totalAttempts}',
                        ),
                        const SizedBox(width: 16),
                        _buildStat(
                          Icons.star_outline,
                          quiz.stats.rating.toStringAsFixed(1),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Footer
            Container(
              height: 52,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppColors.backgroundDark.withOpacity(0.5)
                    : AppColors.lightGrey.withOpacity(0.3),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
              ),
              child: Row(
                children: [
                  // Author Avatar
                  CircleAvatar(
                    radius: 14,
                    backgroundColor: AppColors.primary,
                    backgroundImage: quiz.ownerAvatar != null
                        ? NetworkImage(quiz.ownerAvatar!)
                        : null,
                    child: quiz.ownerAvatar == null
                        ? Text(
                            quiz.ownerName.substring(0, 1).toUpperCase(),
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.white,
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(width: 10),
                  // Author Name
                  Expanded(
                    child: Text(
                      quiz.ownerName,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  // Date
                  Text(
                    _formatDate(quiz.createdAt),
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: AppColors.grey,
                      fontWeight: FontWeight.w400,
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
    return Consumer<CategoryProvider>(
      builder: (context, categoryProvider, child) {
        final categoryData = _getCategoryDisplayData(categoryProvider);
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: categoryData.color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: categoryData.color.withOpacity(0.2),
              width: 0.5,
            ),
          ),
          child: Text(
            categoryData.name,
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: categoryData.color,
            ),
          ),
        );
      },
    );
  }

  Widget _buildDifficultyChip() {
    Color color;
    String text;

    switch (quiz.difficulty) {
      case QuizDifficulty.beginner:
        color = const Color(0xFF22C55E); // Green-500
        text = 'Dễ';
        break;
      case QuizDifficulty.intermediate:
        color = const Color(0xFFF59E0B); // Amber-500
        text = 'TB';
        break;
      case QuizDifficulty.advanced:
        color = const Color(0xFFEF4444); // Red-500
        text = 'Khó';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.2), width: 0.5),
      ),
      child: Text(
        text,
        style: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Widget _buildStat(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppColors.grey.withOpacity(0.8)),
        const SizedBox(width: 4),
        Text(
          text,
          style: GoogleFonts.inter(
            fontSize: 12,
            color: AppColors.grey,
            fontWeight: FontWeight.w500,
          ),
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

  _CategoryData _getCategoryDisplayData(CategoryProvider categoryProvider) {
    // Try to find category by categoryId
    if (quiz.categoryId != null && quiz.categoryId!.isNotEmpty) {
      try {
        final category = categoryProvider.categories.firstWhere(
          (cat) => cat.categoryId == quiz.categoryId,
        );

        // Return category data
        return _CategoryData(
          category.name,
          Color(int.parse(category.color.substring(1), radix: 16) + 0xFF000000),
        );
      } catch (e) {
        // Category not found, fallback
      }
    }

    // Fallback - show "Chưa phân loại"
    return _CategoryData('Chưa phân loại', Colors.grey);
  }
}

class _CategoryData {
  final String name;
  final Color color;

  const _CategoryData(this.name, this.color);
}
