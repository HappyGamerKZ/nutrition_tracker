import 'package:flutter/material.dart';

class AppColors {
  static const primary = Color(0xFF4CAF50);       // Зелёный
  static const secondary = Color(0xFF81C784);     // Светло-зелёный
  static const accent = Color(0xFF00BCD4);        // Синий акцент
  static const backgroundLight = Color(0xFFF5F5F5);
  static const backgroundDark = Color(0xFF121212);
  static const cardDark = Color(0xFF1E1E1E);
  static const textDark = Colors.white;
  static const textLight = Colors.black87;
}

class AppTheme {
  static ThemeData light = ThemeData(
    brightness: Brightness.light,
    primaryColor: AppColors.primary,
    scaffoldBackgroundColor: AppColors.backgroundLight,
    fontFamily: 'NotoSans',
    colorScheme: const ColorScheme.light().copyWith(
      primary: AppColors.primary,
      secondary: AppColors.accent,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    cardTheme: const CardTheme(
      color: Colors.white,
      margin: EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      elevation: 3,
    ),
    textTheme: const TextTheme(
      bodyMedium: TextStyle(fontSize: 16, color: AppColors.textLight),
    ),
  );

  static ThemeData dark = ThemeData(
    brightness: Brightness.dark,
    primaryColor: AppColors.primary,
    scaffoldBackgroundColor: AppColors.backgroundDark,
    fontFamily: 'NotoSans',
    colorScheme: const ColorScheme.dark().copyWith(
      primary: AppColors.primary,
      secondary: AppColors.accent,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.cardDark,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    cardTheme: const CardTheme(
      color: AppColors.cardDark,
      margin: EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      elevation: 3,
    ),
    textTheme: const TextTheme(
      bodyMedium: TextStyle(fontSize: 16, color: AppColors.textDark),
    ),
  );
}
