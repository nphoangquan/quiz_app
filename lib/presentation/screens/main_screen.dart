import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/navigation_provider.dart';
import '../widgets/navigation/bottom_nav_bar.dart';
import 'home/home_tab_screen.dart';
import 'discover/discover_screen.dart';
import 'create/create_quiz_screen.dart';
import 'profile/profile_tab_screen.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<NavigationProvider>(
      builder: (context, navigationProvider, child) {
        return Scaffold(
          body: PageView(
            controller: navigationProvider.pageController,
            onPageChanged: navigationProvider.onPageChanged,
            children: const [
              HomeTabScreen(),
              DiscoverScreen(),
              CreateQuizScreen(),
              ProfileTabScreen(),
            ],
          ),
          bottomNavigationBar: const CustomBottomNavBar(),
        );
      },
    );
  }
}
