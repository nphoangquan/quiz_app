import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'firebase_options.dart';

import 'core/themes/app_theme.dart';
import 'presentation/providers/theme_provider.dart';
import 'presentation/providers/language_provider.dart';
import 'presentation/providers/navigation_provider.dart';
import 'presentation/providers/category_provider.dart';
import 'presentation/providers/auth_provider.dart';
import 'presentation/providers/quiz_provider.dart';
import 'presentation/providers/quiz_player_provider.dart';
import 'presentation/providers/result_provider.dart';
import 'presentation/providers/ai_quiz_provider.dart';
import 'presentation/providers/payment_provider.dart';
import 'presentation/providers/paypal_payment_provider.dart';
import 'presentation/screens/auth/auth_wrapper.dart';
import 'presentation/screens/quiz/quiz_player_screen.dart';
import 'presentation/screens/dashboard/dashboard_screen.dart';
import 'presentation/screens/subscription/pricing_screen.dart';
import 'presentation/screens/payment/payment_screen.dart';
import 'presentation/screens/payment/payment_history_screen.dart';
import 'presentation/screens/admin/admin_dashboard_screen.dart';
import 'data/services/firebase_auth_service.dart';
import 'data/services/firebase_quiz_service.dart';
import 'data/services/firebase_result_service.dart';
import 'data/services/firebase_category_service.dart';
import 'data/repositories/auth_repository_impl.dart';
import 'data/repositories/quiz_repository_impl.dart';
import 'data/repositories/result_repository_impl.dart';
import 'data/repositories/category_repository_impl.dart';
import 'generated/l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await dotenv.load(fileName: ".env");

  // Initialize Firebase with generated options
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize language provider
  final languageProvider = LanguageProvider();
  await languageProvider.initializeLanguage();

  // Initialize category provider
  final categoryProvider = CategoryProvider(
    CategoryRepositoryImpl(FirebaseCategoryService()),
  );

  runApp(
    MyApp(
      languageProvider: languageProvider,
      categoryProvider: categoryProvider,
    ),
  );
}

class MyApp extends StatelessWidget {
  final LanguageProvider languageProvider;
  final CategoryProvider categoryProvider;

  const MyApp({
    super.key,
    required this.languageProvider,
    required this.categoryProvider,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider.value(value: languageProvider),
        ChangeNotifierProvider.value(value: categoryProvider),
        ChangeNotifierProvider(create: (_) => NavigationProvider()),
        ChangeNotifierProvider(
          create: (_) =>
              AuthProvider(AuthRepositoryImpl(FirebaseAuthService())),
        ),
        ChangeNotifierProvider(
          create: (_) =>
              QuizProvider(QuizRepositoryImpl(FirebaseQuizService())),
        ),
        ChangeNotifierProvider(
          create: (_) => QuizPlayerProvider(
            QuizRepositoryImpl(FirebaseQuizService()),
            ResultRepositoryImpl(FirebaseResultService()),
          ),
        ),
        ChangeNotifierProvider(
          create: (_) =>
              ResultProvider(ResultRepositoryImpl(FirebaseResultService())),
        ),
        ChangeNotifierProvider(create: (_) => AiQuizProvider()),
        ChangeNotifierProvider(create: (_) => PaymentProvider()),
        ChangeNotifierProvider(create: (_) => PayPalPaymentProvider()),
      ],
      child: Consumer2<ThemeProvider, LanguageProvider>(
        builder: (context, themeProvider, languageProvider, child) {
          return MaterialApp(
            title: 'QuizApp - Quiz App with AI by QTV',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,

            // Localization support
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: languageProvider.getSupportedLocales(),
            locale: languageProvider.currentLocale,

            home: const AuthWrapper(),

            // Named routes configuration
            routes: {
              '/auth': (context) => const AuthWrapper(),
              '/dashboard': (context) => const DashboardScreen(),
              '/pricing': (context) => const PricingScreen(),
              '/payment': (context) => const PaymentScreen(),
              '/payment-history': (context) => const PaymentHistoryScreen(),
              '/admin': (context) => const AdminDashboardScreen(),
              '/quiz-play': (context) {
                final args =
                    ModalRoute.of(context)!.settings.arguments
                        as Map<String, dynamic>?;
                return QuizPlayerScreen(
                  quizId: args?['quizId'] ?? '',
                  enableTimer: args?['enableTimer'] ?? false,
                );
              },
            },
          );
        },
      ),
    );
  }
}

// TODO: Remove this demo code when authentication is implemented
// This is kept temporarily for reference
