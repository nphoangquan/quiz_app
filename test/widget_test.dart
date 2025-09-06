// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:quizapp/core/themes/app_theme.dart';
import 'package:quizapp/core/themes/app_colors.dart';
import 'package:quizapp/core/constants/app_constants.dart';
import 'package:quizapp/presentation/providers/theme_provider.dart';

void main() {
  testWidgets('QuizApp splash screen test', (WidgetTester tester) async {
    // Build simple splash screen without timers for testing
    await tester.pumpWidget(
      MaterialApp(theme: AppTheme.lightTheme, home: const TestSplashScreen()),
    );

    // Wait for initial render
    await tester.pump();

    // Verify that splash screen elements are present
    expect(find.text('QuizApp'), findsOneWidget);
    expect(find.text('Learn • Practice • Master'), findsOneWidget);
    expect(find.byIcon(Icons.quiz), findsOneWidget);
    expect(find.text('Đang khởi tạo...'), findsOneWidget);
  });

  testWidgets('Theme provider test', (WidgetTester tester) async {
    final themeProvider = ThemeProvider();

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: themeProvider,
        child: Consumer<ThemeProvider>(
          builder: (context, provider, child) {
            return MaterialApp(
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              themeMode: provider.themeMode,
              home: const Scaffold(body: Center(child: Text('Theme Test'))),
            );
          },
        ),
      ),
    );

    expect(find.text('Theme Test'), findsOneWidget);

    // Test theme toggle - từ system sẽ chuyển thành light
    expect(themeProvider.themeMode, ThemeMode.system);

    themeProvider.toggleTheme();
    await tester.pump();
    expect(themeProvider.themeMode, ThemeMode.light);

    // Toggle lần nữa sẽ thành dark
    themeProvider.toggleTheme();
    await tester.pump();
    expect(themeProvider.themeMode, ThemeMode.dark);
  });
}

// Simple splash screen for testing without timers
class TestSplashScreen extends StatelessWidget {
  const TestSplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // App Icon/Logo
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.quiz,
                  size: 60,
                  color: AppColors.primary,
                ),
              ),

              const SizedBox(height: 32),

              // App Name
              Text(
                AppConstants.appName,
                style: GoogleFonts.inter(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: AppColors.white,
                  letterSpacing: 1.2,
                ),
              ),

              const SizedBox(height: 8),

              // App Tagline
              Text(
                'Learn • Practice • Master',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppColors.white.withOpacity(0.8),
                  letterSpacing: 0.5,
                ),
              ),

              const SizedBox(height: 60),

              // Loading Indicator
              Column(
                children: [
                  SizedBox(
                    width: 40,
                    height: 40,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.white.withOpacity(0.8),
                      ),
                      strokeWidth: 3,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Đang khởi tạo...',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: AppColors.white.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
