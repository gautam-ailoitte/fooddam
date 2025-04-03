// lib/core/theme/theme_provider.dart
import 'package:flutter/material.dart';
import 'package:foodam/core/service/storage_service.dart';

enum ThemeMode {
  system,
  light,
  dark,
}

class ThemeProvider extends ChangeNotifier {
  final StorageService _storageService;
  static const String _themeKey = 'THEME_MODE';

  ThemeMode _themeMode = ThemeMode.light;
  bool _isFirstRun = true;

  ThemeProvider(this._storageService) {
    _loadThemePreference();
  }

  ThemeMode get themeMode => _themeMode;
  bool get isFirstRun => _isFirstRun;

  bool get isDarkMode {
    // if (_themeMode == ThemeMode.system) {
    //   // Check device's brightness
    //   final brightness = SchedulerBinding.instance.window.platformBrightness;
    //   return brightness == Brightness.dark;
    // }
    // return _themeMode == ThemeMode.dark;
    return false;  // forecfully returning light theme
  }

  // Load saved theme preference
  Future<void> _loadThemePreference() async {
    final savedTheme = _storageService.getString(_themeKey);
    
    if (savedTheme != null) {
      switch (savedTheme) {
        case 'light':
          _themeMode = ThemeMode.light;
          break;
        case 'dark':
          _themeMode = ThemeMode.dark;
          break;
        case 'system':
        default:
          _themeMode = ThemeMode.system;
          break;
      }
      _isFirstRun = false;
      notifyListeners();
    } else {
      // Default to system on first run
      _isFirstRun = true;
      await setThemeMode(ThemeMode.system);
    }
  }

  // Set theme mode and save preference
  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode && !_isFirstRun) {
      return; // No change
    }

    _themeMode = mode;
    _isFirstRun = false;
    notifyListeners();

    // Save theme preference
    String themeName;
    switch (mode) {
      case ThemeMode.light:
        themeName = 'light';
        break;
      case ThemeMode.dark:
        themeName = 'dark';
        break;
      case ThemeMode.system:
      themeName = 'system';
        break;
    }

    await _storageService.setString(_themeKey, themeName);
  }

  // Toggle between light and dark modes, keeping system mode separate
  Future<void> toggleTheme() async {
    if (_themeMode == ThemeMode.dark) {
      await setThemeMode(ThemeMode.light);
    } else {
      await setThemeMode(ThemeMode.dark);
    }
  }

  // Set system theme mode
  Future<void> useSystemTheme() async {
    await setThemeMode(ThemeMode.system);
  }
}