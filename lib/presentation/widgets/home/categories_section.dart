import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../domain/entities/category_entity.dart';
// import '../../../core/utils/category_mapper.dart';
import '../../providers/category_provider.dart';
import '../../screens/category/category_filter_screen.dart';
import '../../../core/themes/app_colors.dart';

class CategoriesSection extends StatelessWidget {
  const CategoriesSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<CategoryProvider>(
      builder: (context, categoryProvider, child) {
        if (categoryProvider.isLoading) {
          debugPrint('🏠 CategoriesSection: Loading categories...');
          return _buildLoadingState(context);
        }

        if (categoryProvider.hasError) {
          debugPrint(
            '🏠 CategoriesSection: Error - ${categoryProvider.errorMessage}',
          );
          return _buildErrorState(
            context,
            categoryProvider.errorMessage ?? 'Unknown error',
          );
        }

        final categories = categoryProvider.categories;

        // Debug: Print category info
        debugPrint(
          '🏠 CategoriesSection: ${categories.length} categories available',
        );
        debugPrint('🏠 CategoryProvider state: ${categoryProvider.state}');

        if (categories.isEmpty) {
          debugPrint(
            '🏠 CategoriesSection: No categories found, showing empty state',
          );
          // Show debug info in empty state
          return _buildEmptyStateWithDebug(context, categoryProvider);
        }

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

            // Categories Grid with margin for shadows
            Container(
              height: 40,
              margin: const EdgeInsets.symmetric(
                vertical: 4,
              ), // Space for shadows
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                clipBehavior:
                    Clip.none, // Allow shadows to extend beyond bounds
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final category = categories[index];
                  return Padding(
                    padding: EdgeInsets.only(
                      right: index == categories.length - 1 ? 0 : 12,
                    ),
                    child: _CategoryCard(category: category),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Danh mục',
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).textTheme.headlineMedium?.color,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 80,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 5, // Show 5 shimmer cards
            itemBuilder: (context, index) {
              return Padding(
                padding: EdgeInsets.only(right: index == 4 ? 0 : 12),
                child: Container(
                  width: 120,
                  height: 80,
                  decoration: BoxDecoration(
                    color: isDarkMode ? Colors.grey[700] : Colors.grey[300],
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState(BuildContext context, String error) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Danh mục',
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).textTheme.headlineMedium?.color,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDarkMode
                ? Colors.red[900]?.withOpacity(0.3)
                : Colors.red[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDarkMode ? Colors.red[700]! : Colors.red[200]!,
            ),
          ),
          child: Text(
            'Lỗi tải danh mục: $error',
            style: GoogleFonts.inter(
              color: isDarkMode ? Colors.red[300] : Colors.red[700],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyStateWithDebug(
    BuildContext context,
    CategoryProvider categoryProvider,
  ) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Danh mục',
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).textTheme.headlineMedium?.color,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDarkMode ? Colors.grey[800] : Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDarkMode
                  ? AppColors.borderDarkSubtle
                  : Colors.grey[200]!,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Chưa có danh mục nào',
                style: GoogleFonts.inter(
                  color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
              if (kDebugMode) ...[
                const SizedBox(height: 8),
                Text(
                  'Debug: State = ${categoryProvider.state}',
                  style: GoogleFonts.inter(fontSize: 12, color: Colors.red),
                ),
                if (categoryProvider.errorMessage != null)
                  Text(
                    'Error: ${categoryProvider.errorMessage}',
                    style: GoogleFonts.inter(fontSize: 12, color: Colors.red),
                  ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final CategoryEntity category;

  const _CategoryCard({required this.category});

  @override
  Widget build(BuildContext context) {
    final categoryProvider = context.read<CategoryProvider>();
    final categoryColor = categoryProvider.getCategoryColor(
      category.categoryId,
    );
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => CategoryFilterScreen(
              initialCategory: category, // Pass CategoryEntity directly
              categoryName: category.name,
              categoryColor: categoryColor,
              categoryIcon: Icons.category, // Default icon
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor, // Use theme card color
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: isDarkMode
                  ? Colors.black.withOpacity(0.3)
                  : Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
              spreadRadius: 0,
            ),
            BoxShadow(
              color: isDarkMode
                  ? Colors.black.withOpacity(0.15)
                  : Colors.black.withOpacity(0.04),
              blurRadius: 4,
              offset: const Offset(0, 1),
              spreadRadius: 0,
            ),
          ],
        ),
        child: Text(
          category.name,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
