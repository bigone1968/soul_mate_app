import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  static const Color primary = Color(0xFF1A0A14);
  static const Color secondary = Color(0xFF0A050E);
  static const Color accent = Color(0xFFC0392B);
  static const Color accentLight = Color(0xFFE74C3C);
  static const Color background = Color(0xFF0A050E);
  static const Color surface = Color(0xFF1A1525);
  static const Color textPrimary = Color(0xFFF5E6D3);
  static const Color textSecondary = Color(0xFF8A7A6B);
  static const Color textMuted = Color(0xFF5A4A3B);

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      colorScheme: ColorScheme.dark(
        primary: accent,
        secondary: accentLight,
        surface: surface,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Color(0xFF0D0508),
        selectedItemColor: accent,
        unselectedItemColor: textSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 20,
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(color: textPrimary, fontWeight: FontWeight.bold),
        headlineMedium: TextStyle(color: textPrimary, fontWeight: FontWeight.bold),
        bodyLarge: TextStyle(color: textPrimary),
        bodyMedium: TextStyle(color: textSecondary),
      ),
      dialogTheme: const DialogThemeData(
        backgroundColor: background,
      ),
    );
  }
}