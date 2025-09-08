import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../domain/entities/quiz_entity.dart';
import '../../widgets/home/welcome_header.dart';
import '../../widgets/home/search_bar.dart';
import '../../widgets/home/featured_section.dart';
import '../../widgets/home/categories_section.dart';
import '../../widgets/home/recent_quizzes_section.dart';
import '../../widgets/home/popular_quizzes_section.dart';
import '../../providers/quiz_provider.dart';

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
      quizProvider.loadFeaturedQuizzes();
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
                quizProvider.loadFeaturedQuizzes();
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

                    // Search Bar
                    const HomeSearchBar(),

                    const SizedBox(height: 24),

                    // Featured Section
                    FeaturedSection(
                      featuredQuizzes: quizProvider.featuredQuizzes,
                      isLoading: quizProvider.isLoading,
                    ),

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
                    ),

                    const SizedBox(height: 24),

                    // Popular Quizzes
                    PopularQuizzesSection(
                      popularQuizzes: _getPopularQuizzes(
                        quizProvider.publicQuizzes,
                      ),
                      isLoading: quizProvider.isLoading,
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
