import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  bool get isDarkMode {
    switch (_themeMode) {
      case ThemeMode.light:
        return false;
      case ThemeMode.dark:
        return true;
      case ThemeMode.system:
        return WidgetsBinding.instance.platformDispatcher.platformBrightness ==
            Brightness.dark;
    }
  }

  void toggleTheme() {
    debugPrint(
      '🔄 Toggle theme: $_themeMode -> ${_themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light}',
    );
    switch (_themeMode) {
      case ThemeMode.light:
        _themeMode = ThemeMode.dark;
        break;
      case ThemeMode.dark:
        _themeMode = ThemeMode.light;
        break;
      case ThemeMode.system:
        // Nếu đang ở system mode, chuyển trực tiếp sang dark
        _themeMode = ThemeMode.dark;
        break;
    }
    debugPrint('✅ Theme changed to: $_themeMode, isDarkMode: $isDarkMode');
    notifyListeners();
  }
}
