import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageProvider extends ChangeNotifier {
  static const String _languageKey = 'app_language';

  Locale _currentLocale = const Locale('vi', 'VN'); // Default Vietnamese

  Locale get currentLocale => _currentLocale;

  bool get isVietnamese => _currentLocale.languageCode == 'vi';
  bool get isEnglish => _currentLocale.languageCode == 'en';

  String get currentLanguageName {
    switch (_currentLocale.languageCode) {
      case 'vi':
        return 'Tiếng Việt';
      case 'en':
        return 'English (US)';
      default:
        return 'Tiếng Việt';
    }
  }

  /// Initialize language from saved preferences
  Future<void> initializeLanguage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedLanguage = prefs.getString(_languageKey);

      if (savedLanguage != null) {
        switch (savedLanguage) {
          case 'vi':
            _currentLocale = const Locale('vi', 'VN');
            break;
          case 'en':
            _currentLocale = const Locale('en', 'US');
            break;
          default:
            _currentLocale = const Locale('vi', 'VN');
        }
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Failed to load language preference: $e');
      _currentLocale = const Locale('vi', 'VN');
    }
  }

  /// Change language and save preference
  Future<void> changeLanguage(String languageCode) async {
    try {
      Locale newLocale;
      switch (languageCode) {
        case 'vi':
          newLocale = const Locale('vi', 'VN');
          break;
        case 'en':
          newLocale = const Locale('en', 'US');
          break;
        default:
          newLocale = const Locale('vi', 'VN');
      }

      if (newLocale != _currentLocale) {
        _currentLocale = newLocale;

        // Save to preferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_languageKey, languageCode);

        notifyListeners();
      }
    } catch (e) {
      debugPrint('Failed to change language: $e');
    }
  }

  /// Toggle between Vietnamese and English
  Future<void> toggleLanguage() async {
    final newLanguage = _currentLocale.languageCode == 'vi' ? 'en' : 'vi';
    await changeLanguage(newLanguage);
  }

  /// Get supported locales
  List<Locale> getSupportedLocales() {
    return const [Locale('vi', 'VN'), Locale('en', 'US')];
  }
}
