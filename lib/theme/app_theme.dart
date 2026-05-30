import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  static const Color _bgColor = Color(0xFF0D0A14);
  static const Color _accentColor = Color(0xFFC0392B);
  static const Color _secondaryColor = Color(0xFFE74C3C);

  static ThemeData theme() {
    final colorScheme = ColorScheme.dark(
      primary: _accentColor,
      secondary: _secondaryColor,
      surface: _bgColor,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: const Color(0xFFF5E6D3),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: _bgColor,
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          color: Color(0xFFF5E6D3),
          fontSize: 57,
          fontWeight: FontWeight.w300,
        ),
        displayMedium: TextStyle(
          color: Color(0xFFF5E6D3),
          fontSize: 45,
          fontWeight: FontWeight.w400,
        ),
        displaySmall: TextStyle(
          color: Color(0xFFF5E6D3),
          fontSize: 36,
          fontWeight: FontWeight.w400,
        ),
        headlineLarge: TextStyle(
          color: Color(0xFFF5E6D3),
          fontSize: 32,
          fontWeight: FontWeight.w600,
        ),
        headlineMedium: TextStyle(
          color: Color(0xFFF5E6D3),
          fontSize: 28,
          fontWeight: FontWeight.w500,
        ),
        headlineSmall: TextStyle(
          color: Color(0xFFF5E6D3),
          fontSize: 24,
          fontWeight: FontWeight.w500,
        ),
        titleLarge: TextStyle(
          color: Color(0xFFF5E6D3),
          fontSize: 22,
          fontWeight: FontWeight.w500,
        ),
        titleMedium: TextStyle(
          color: Color(0xFFE8D5C4),
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        titleSmall: TextStyle(
          color: Color(0xFFE8D5C4),
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        bodyLarge: TextStyle(
          color: Color(0xFFE8D5C4),
          fontSize: 16,
          fontWeight: FontWeight.w400,
        ),
        bodyMedium: TextStyle(
          color: Color(0xFFD4C4B5),
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
        bodySmall: TextStyle(
          color: Color(0xFFD4C4B5),
          fontSize: 12,
          fontWeight: FontWeight.w400,
        ),
        labelLarge: TextStyle(
          color: Color(0xFFF5E6D3),
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        labelMedium: TextStyle(
          color: Color(0xFFD4C4B5),
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        labelSmall: TextStyle(
          color: Color(0xFFD4C4B5),
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: _bgColor,
        foregroundColor: Color(0xFFF5E6D3),
        elevation: 0,
        centerTitle: true,
      ),
      cardTheme: CardThemeData(
        color: const Color(0xFF1A1525),
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _accentColor,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF1A1525),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _accentColor, width: 1.5),
        ),
        labelStyle: const TextStyle(color: Color(0xFFD4C4B5)),
        hintStyle: const TextStyle(color: Color(0xFF8A7A6B)),
      ),
      dividerTheme: const DividerThemeData(
        color: Color(0xFF2A2035),
        thickness: 1,
      ),
    );
  }
}