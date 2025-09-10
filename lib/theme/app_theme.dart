// lib/theme/app_theme.dart
import 'package:flutter/material.dart';

class AppTheme {
  // Brand color (dark green)
  static const Color seed = Color(0xFF0A6B3A);

  static ThemeData light() {
    final scheme = ColorScheme.fromSeed(
      seedColor: seed,
      brightness: Brightness.light,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      appBarTheme: const AppBarTheme(centerTitle: true),
      visualDensity: VisualDensity.adaptivePlatformDensity,
    );
  }

  static ThemeData dark() {
    final scheme = ColorScheme.fromSeed(
      seedColor: seed,
      brightness: Brightness.dark,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      appBarTheme: const AppBarTheme(centerTitle: true),
      visualDensity: VisualDensity.adaptivePlatformDensity,
    );
  }
}
