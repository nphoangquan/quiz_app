import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/themes/app_colors.dart';
import '../../../domain/entities/quiz_entity.dart';

class CategoriesSection extends StatelessWidget {
  const CategoriesSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Text(
          'Danh mục',
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).textTheme.headlineMedium?.color,
          ),
        ),

        const SizedBox(height: 12),

        // Categories Grid
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _categories.length,
            itemBuilder: (context, index) {
              final category = _categories[index];
              return Padding(
                padding: EdgeInsets.only(
                  right: index == _categories.length - 1 ? 0 : 12,
                ),
                child: _CategoryCard(category: category),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final CategoryData category;

  const _CategoryCard({required this.category});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Danh mục ${category.name} sẽ có trong phiên bản tiếp theo',
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      },
      child: Container(
        width: 80,
        height: 100,
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? AppColors.surfaceDark
              : AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.lightGrey.withOpacity(0.5),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: category.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(category.icon, color: category.color, size: 24),
            ),

            const SizedBox(height: 8),

            // Name
            Text(
              category.name,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class CategoryData {
  final String name;
  final IconData icon;
  final Color color;
  final QuizCategory category;

  const CategoryData({
    required this.name,
    required this.icon,
    required this.color,
    required this.category,
  });
}

final List<CategoryData> _categories = [
  CategoryData(
    name: 'Lập trình',
    icon: Icons.code,
    color: AppColors.primary,
    category: QuizCategory.programming,
  ),
  CategoryData(
    name: 'Toán học',
    icon: Icons.calculate,
    color: Colors.orange,
    category: QuizCategory.mathematics,
  ),
  CategoryData(
    name: 'Khoa học',
    icon: Icons.science,
    color: Colors.green,
    category: QuizCategory.science,
  ),
  CategoryData(
    name: 'Lịch sử',
    icon: Icons.history_edu,
    color: Colors.brown,
    category: QuizCategory.history,
  ),
  CategoryData(
    name: 'Ngôn ngữ',
    icon: Icons.language,
    color: Colors.blue,
    category: QuizCategory.language,
  ),
  CategoryData(
    name: 'Địa lý',
    icon: Icons.public,
    color: Colors.teal,
    category: QuizCategory.geography,
  ),
  CategoryData(
    name: 'Thể thao',
    icon: Icons.sports_soccer,
    color: Colors.red,
    category: QuizCategory.sports,
  ),
  CategoryData(
    name: 'Giải trí',
    icon: Icons.movie,
    color: Colors.purple,
    category: QuizCategory.entertainment,
  ),
];
