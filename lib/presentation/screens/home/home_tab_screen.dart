import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_constants.dart';
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
                padding: const EdgeInsets.all(AppConstants.defaultPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Welcome Header
                    const WelcomeHeader(),

                    const SizedBox(height: 20),

                    // Search Bar with Filter
                    _buildSearchBarWithFilter(),

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

    return Row(
      children: [
        // Search Bar
        Expanded(
          child: GestureDetector(
            onTap: _navigateToDiscoverScreen,
            child: Container(
              height: 56,
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.grey[800]
                    : Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 16),
                  Icon(Icons.search, color: Colors.grey[600]),
                  const SizedBox(width: 12),
                  Text(
                    l10n.searchHint,
                    style: TextStyle(color: Colors.grey[600], fontSize: 16),
                  ),
                ],
              ),
            ),
          ),
        ),

        const SizedBox(width: 12),

        // Filter Button
        Container(
          height: 56,
          width: 56,
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.grey[800]
                : Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            onPressed: _navigateToDiscoverScreen,
            icon: const Icon(Icons.tune),
            tooltip: 'Bộ lọc nâng cao',
          ),
        ),
      ],
    );
  }

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
}
