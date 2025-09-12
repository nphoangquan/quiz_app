import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/category_provider.dart';
import '../../providers/navigation_provider.dart';
import '../splash/splash_screen.dart';
import 'login_screen.dart';
import '../main_screen.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        switch (authProvider.status) {
          case AuthStatus.initial:
          case AuthStatus.loading:
            return const SplashScreen();

          case AuthStatus.authenticated:
            // Initialize categories when user is authenticated
            WidgetsBinding.instance.addPostFrameCallback((_) {
              final categoryProvider = context.read<CategoryProvider>();
              categoryProvider.initializeCategories();
            });

            return ChangeNotifierProvider(
              create: (_) => NavigationProvider(),
              child: const MainScreen(),
            );

          case AuthStatus.unauthenticated:
          case AuthStatus.error:
            return const LoginScreen();
        }
      },
    );
  }
}
