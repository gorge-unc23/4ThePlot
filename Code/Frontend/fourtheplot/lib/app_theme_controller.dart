import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppThemeController extends ChangeNotifier {
  static const _preferenceKey = 'settings.appearance.themeMode';
  static const system = 'system';
  static const light = 'light';
  static const dark = 'dark';

  static final AppThemeController instance = AppThemeController._();

  AppThemeController._();

  String _selectedMode = system;

  String get selectedMode => _selectedMode;

  ThemeMode get themeMode {
    switch (_selectedMode) {
      case light:
        return ThemeMode.light;
      case dark:
        return ThemeMode.dark;
      case system:
      default:
        return ThemeMode.system;
    }
  }

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_preferenceKey);
    if (_isValid(saved)) {
      _selectedMode = saved!;
    }
  }

  Future<void> setThemeMode(String mode) async {
    final normalized = _isValid(mode) ? mode : system;
    if (_selectedMode == normalized) {
      return;
    }

    _selectedMode = normalized;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_preferenceKey, normalized);
  }

  bool _isValid(String? value) {
    return value == system || value == light || value == dark;
  }
}
