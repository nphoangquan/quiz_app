// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Quiz App';

  @override
  String get welcome => 'Good afternoon!';

  @override
  String get searchHint => 'Search quizzes, topics...';

  @override
  String get categories => 'Categories';

  @override
  String get recent => 'Recent';

  @override
  String get popular => 'Popular';

  @override
  String get viewAll => 'View all';

  @override
  String get home => 'Home';

  @override
  String get discover => 'Discover';

  @override
  String get createQuiz => 'Create Quiz';

  @override
  String get profile => 'Profile';

  @override
  String get settings => 'Settings';

  @override
  String get interface => 'Interface';

  @override
  String get darkMode => 'Dark mode';

  @override
  String get darkModeDesc => 'Toggle dark interface';

  @override
  String get language => 'Language';

  @override
  String get languageDesc => 'Change app language';

  @override
  String get account => 'Account';

  @override
  String get signOut => 'Sign out';

  @override
  String get signOutDesc => 'Exit current account';

  @override
  String get deleteAccount => 'Delete account';

  @override
  String get deleteAccountDesc => 'Permanently delete account and data';

  @override
  String get appInfo => 'Quiz App';

  @override
  String get version => 'Version 1.0.0';

  @override
  String get all => 'All';

  @override
  String get newest => 'Newest';

  @override
  String get programming => 'Programming';

  @override
  String get mathematics => 'Mathematics';

  @override
  String get science => 'Science';

  @override
  String get history => 'History';

  @override
  String get languageSubject => 'Language';

  @override
  String get geography => 'Geography';

  @override
  String get sports => 'Sports';

  @override
  String get entertainment => 'Entertainment';

  @override
  String get general => 'General';

  @override
  String get easy => 'Easy';

  @override
  String get medium => 'Medium';

  @override
  String get hard => 'Hard';

  @override
  String get backToHome => 'Back to home';

  @override
  String get noQuizFound => 'No quiz found';

  @override
  String get tryChangeFilter => 'Try changing filters or search keywords';

  @override
  String get clearFilters => 'Clear filters';

  @override
  String get apply => 'Apply';

  @override
  String get difficulty => 'Difficulty';

  @override
  String get category => 'Category';

  @override
  String get advancedFilter => 'Advanced filter';

  @override
  String question(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count questions',
      one: '1 question',
    );
    return '$_temp0';
  }

  @override
  String attempt(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count',
      one: '1',
      zero: '0',
    );
    return '$_temp0';
  }

  @override
  String get selectLanguage => 'Select Language';
}
