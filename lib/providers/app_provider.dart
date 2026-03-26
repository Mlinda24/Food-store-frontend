import 'package:flutter/material.dart';

class AppProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  bool _isDarkMode = false;
  String? _notificationToken;

  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _isDarkMode;
  String? get notificationToken => _notificationToken;

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    _themeMode = _isDarkMode ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    _isDarkMode = mode == ThemeMode.dark;
    notifyListeners();
  }

  void setNotificationToken(String token) {
    _notificationToken = token;
    notifyListeners();
  }
}