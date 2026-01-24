import 'package:flutter/material.dart';

class AppStateManager extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;
  Locale _locale = const Locale('mn');

  ThemeMode get themeMode => _themeMode;
  Locale get locale => _locale;

  void toggleTheme(bool isDark) {
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  void setLocale(Locale newLocale) {
    if (_locale != newLocale) {
      _locale = newLocale;
      notifyListeners();
    }
  }

  void logout() {
    // Logic to clear navigation stack and go to login would be handled by the UI listening to this or via global key
    notifyListeners();
  }

  // Singleton pattern for easy access
  static final AppStateManager instance = AppStateManager._internal();
  AppStateManager._internal();
}
