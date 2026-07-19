import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppStateManager extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;
  Locale _locale = const Locale('mn');

  ThemeMode get themeMode => _themeMode;
  Locale get locale => _locale;

  static const String _themeKey = 'theme_mode';
  static const String _languageKey = 'language_code';

  /// Loads saved theme and language preferences from disk.
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();

    // Load theme
    final savedTheme = prefs.getString(_themeKey);
    if (savedTheme != null) {
      _themeMode = savedTheme == 'dark' ? ThemeMode.dark : ThemeMode.light;
    }

    // Load language
    final savedLanguage = prefs.getString(_languageKey);
    if (savedLanguage != null) {
      _locale = Locale(savedLanguage);
    }

    notifyListeners();
  }

  /// Toggles the theme and persists the choice.
  void toggleTheme(bool isDark) async {
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeKey, isDark ? 'dark' : 'light');
  }

  /// Updates the locale and persists the choice.
  void setLocale(Locale newLocale) async {
    if (_locale != newLocale) {
      _locale = newLocale;
      notifyListeners();

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_languageKey, newLocale.languageCode);
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
