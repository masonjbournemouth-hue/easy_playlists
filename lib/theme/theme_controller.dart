// lib/theme/theme_controller.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum ThemeChoice { system, light, dark }

class ThemeController extends ChangeNotifier {
  static const _key = 'theme_choice';
  ThemeChoice _choice = ThemeChoice.system;

  ThemeChoice get choice => _choice;

  ThemeMode get themeMode {
    switch (_choice) {
      case ThemeChoice.light:
        return ThemeMode.light;
      case ThemeChoice.dark:
        return ThemeMode.dark;
      case ThemeChoice.system:
      default:
        return ThemeMode.system;
    }
  }

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final idx = prefs.getInt(_key);
    if (idx != null && idx >= 0 && idx < ThemeChoice.values.length) {
      _choice = ThemeChoice.values[idx];
      notifyListeners();
    }
  }

  Future<void> setChoice(ThemeChoice value) async {
    _choice = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_key, value.index);
  }
}
