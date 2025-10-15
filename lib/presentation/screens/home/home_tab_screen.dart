import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/themes/app_colors.dart';
import '../../../domain/entities/quiz_entity.dart';
import '../../widgets/home/welcome_header.dart';
import '../../widgets/home/categories_section.dart';
import '../../widgets/home/recent_quizzes_section.dart';
import '../../widgets/home/popular_quizzes_section.dart';
import '../../providers/quiz_provider.dart';
import '../../providers/navigation_provider.dart';
import '../../../generated/l10n/app_localizations.dart';

class HomeTabScreen extends StatefulWidget {
  const HomeTabScreen({super.key});

  @override
  State<HomeTabScreen> createState() => _HomeTabScreenState();
}

class _HomeTabScreenState extends State<HomeTabScreen> {
  @override
  void initState() {
    super.initState();

    // Load data when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final quizProvider = context.read<QuizProvider>();
      quizProvider.loadPublicQuizzes();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Consumer<QuizProvider>(
          builder: (context, quizProvider, child) {
            return RefreshIndicator(
              onRefresh: () async {
                quizProvider.loadPublicQuizzes();
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                clipBehavior: Clip.none,
                padding: const EdgeInsets.all(AppConstants.defaultPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Welcome Header
                    const WelcomeHeader(),

                    const SizedBox(height: 20),

                    // Search Bar with Filter
                    _buildSearchBarWithFilter(),

                    const SizedBox(height: 20),

                    // Banner
                    _buildBanner(),

                    const SizedBox(height: 24),

                    // Categories
                    const CategoriesSection(),

                    const SizedBox(height: 24),

                    // Recent Quizzes
                    RecentQuizzesSection(
                      recentQuizzes: _getRecentQuizzes(
                        quizProvider.publicQuizzes,
                      ),
                      isLoading: quizProvider.isLoading,
                      onViewAll: () => _navigateToRecentQuizzes(),
                    ),

                    const SizedBox(height: 24),

                    // Popular Quizzes
                    PopularQuizzesSection(
                      popularQuizzes: _getPopularQuizzes(
                        quizProvider.publicQuizzes,
                      ),
                      isLoading: quizProvider.isLoading,
                      onViewAll: () => _navigateToPopularQuizzes(),
                    ),

                    const SizedBox(height: 24),

                    // HUTECH Campus Information
                    _buildHutechInfo(),

                    const SizedBox(
                      height: 100,
                    ), // Bottom padding for navigation
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSearchBarWithFilter() {
    final l10n = AppLocalizations.of(context);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Row(
      children: [
        // Search Bar
        Expanded(
          child: GestureDetector(
            onTap: _navigateToDiscoverScreen,
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor, // Use theme card color
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: isDarkMode
                        ? Colors.black.withValues(alpha: 0.3)
                        : Colors.black.withValues(alpha: 0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                    spreadRadius: 0,
                  ),
                  BoxShadow(
                    color: isDarkMode
                        ? Colors.black.withValues(alpha: 0.15)
                        : Colors.black.withValues(alpha: 0.04),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: Row(
                children: [
                  const SizedBox(width: 16),
                  Icon(
                    Icons.search,
                    color: Theme.of(
                      context,
                    ).textTheme.bodyLarge?.color?.withValues(alpha: 0.6),
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    l10n.searchHint,
                    style: GoogleFonts.inter(
                      color: Theme.of(
                        context,
                      ).textTheme.bodyLarge?.color?.withValues(alpha: 0.6),
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        const SizedBox(width: 12),

        // Filter Button
        Container(
          height: 50,
          width: 50,
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor, // Use theme card color
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: isDarkMode
                    ? Colors.black.withValues(alpha: 0.3)
                    : Colors.black.withValues(alpha: 0.08),
                blurRadius: 12,
                offset: const Offset(0, 4),
                spreadRadius: 0,
              ),
              BoxShadow(
                color: isDarkMode
                    ? Colors.black.withValues(alpha: 0.15)
                    : Colors.black.withValues(alpha: 0.04),
                blurRadius: 4,
                offset: const Offset(0, 2),
                spreadRadius: 0,
              ),
            ],
          ),
          child: IconButton(
            onPressed: _navigateToDiscoverScreen,
            icon: Icon(Icons.tune, color: AppColors.primary, size: 20),
            tooltip: 'Bộ lọc nâng cao',
          ),
        ),
      ],
    );
  }

  // void _navigateToCategoryFilter() {
  //   Navigator.of(context).push(
  //     MaterialPageRoute(
  //       builder: (context) => const CategoryFilterScreen(
  //         categoryName: '',
  //         categoryColor: AppColors.primary,
  //         categoryIcon: Icons.category,
  //       ),
  //     ),
  //   );
  // }

  void _navigateToDiscoverScreen() {
    // Switch to discover tab
    final navigationProvider = context.read<NavigationProvider>();
    navigationProvider.setCurrentIndex(1); // Index 1 = DiscoverScreen
  }

  void _navigateToRecentQuizzes() {
    // Switch to discover tab (can be enhanced to show recent filter)
    final navigationProvider = context.read<NavigationProvider>();
    navigationProvider.setCurrentIndex(1); // Index 1 = DiscoverScreen
  }

  void _navigateToPopularQuizzes() {
    // Switch to discover tab (can be enhanced to show popular filter)
    final navigationProvider = context.read<NavigationProvider>();
    navigationProvider.setCurrentIndex(1); // Index 1 = DiscoverScreen
  }

  List<QuizEntity> _getRecentQuizzes(List<QuizEntity> allQuizzes) {
    final recentQuizzes = List<QuizEntity>.from(allQuizzes)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return recentQuizzes.take(5).toList();
  }

  List<QuizEntity> _getPopularQuizzes(List<QuizEntity> allQuizzes) {
    final popularQuizzes = List<QuizEntity>.from(allQuizzes)
      ..sort((a, b) => b.stats.totalAttempts.compareTo(a.stats.totalAttempts));
    return popularQuizzes.take(5).toList();
  }

  Widget _buildBanner() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: 120,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDarkMode
                ? Colors.black.withValues(alpha: 0.3)
                : Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: isDarkMode
                ? Colors.black.withValues(alpha: 0.15)
                : Colors.black.withValues(alpha: 0.04),
            blurRadius: 4,
            offset: const Offset(0, 2),
            spreadRadius: 0,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.asset(
          'assets/images/banner1.png',
          fit: BoxFit.cover,
          width: double.infinity,
        ),
      ),
    );
  }

  Widget _buildHutechInfo() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDarkMode
                ? Colors.black.withValues(alpha: 0.3)
                : Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: isDarkMode
                ? Colors.black.withValues(alpha: 0.15)
                : Colors.black.withValues(alpha: 0.04),
            blurRadius: 4,
            offset: const Offset(0, 2),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.school, color: AppColors.primary, size: 24),
              const SizedBox(width: 12),
              Text(
                'Các cơ sở đào tạo HUTECH',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.headlineMedium?.color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildCampusInfo(
            'Trụ sở chính',
            '475A Điện Biên Phủ, P.25, Q. Bình Thạnh, TP.HCM',
          ),
          const SizedBox(height: 12),
          _buildCampusInfo(
            'Cơ sở Ung Văn Khiêm',
            '31/36 Ung Văn Khiêm, P.25, Q. Bình Thạnh, TP.HCM',
          ),
          const SizedBox(height: 12),
          _buildCampusInfo(
            'Cơ sở 475B Điện Biên Phủ',
            '475B Điện Biên Phủ, P.25, Q. Bình Thạnh',
          ),
          const SizedBox(height: 12),
          _buildCampusInfo(
            'Cơ sở tại Khu công nghệ cao TP.HCM',
            'SHTP – gồm các tòa nhà của Trung tâm Đào tạo nhân lực chất lượng cao và Viện Công nghệ cao HUTECH',
          ),
        ],
      ),
    );
  }

  Widget _buildCampusInfo(String title, String address) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 6,
          height: 6,
          margin: const EdgeInsets.only(top: 6, right: 12),
          decoration: BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                address,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
