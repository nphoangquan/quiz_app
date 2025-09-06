class AppConstants {
  static const String appName = 'QuizApp';
  static const String appVersion = '1.0.0';

  // Animation durations
  static const Duration shortAnimationDuration = Duration(milliseconds: 200);
  static const Duration mediumAnimationDuration = Duration(milliseconds: 400);
  static const Duration longAnimationDuration = Duration(milliseconds: 600);

  // UI Constants
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;

  // Quiz Constants
  static const int maxQuestionsPerQuiz = 50;
  static const int minQuestionsPerQuiz = 1;
  static const int defaultQuizTimeLimit = 300; // 5 minutes in seconds

  // Routes
  static const String splashRoute = '/';
  static const String authRoute = '/auth';
  static const String homeRoute = '/home';
  static const String quizRoute = '/quiz';
  static const String profileRoute = '/profile';
}
