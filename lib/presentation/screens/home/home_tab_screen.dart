import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import '../../widgets/home/welcome_header.dart';
import '../../widgets/home/search_bar.dart';
import '../../widgets/home/featured_section.dart';
import '../../widgets/home/categories_section.dart';
import '../../widgets/home/recent_quizzes_section.dart';
import '../../widgets/home/popular_quizzes_section.dart';

class HomeTabScreen extends StatelessWidget {
  const HomeTabScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            // TODO: Implement refresh logic
            await Future.delayed(const Duration(seconds: 1));
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
                const FeaturedSection(),

                const SizedBox(height: 24),

                // Categories
                const CategoriesSection(),

                const SizedBox(height: 24),

                // Recent Quizzes
                const RecentQuizzesSection(),

                const SizedBox(height: 24),

                // Popular Quizzes
                const PopularQuizzesSection(),

                const SizedBox(height: 100), // Bottom padding for navigation
              ],
            ),
          ),
        ),
      ),
    );
  }
}
