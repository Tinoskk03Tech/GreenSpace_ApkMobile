import 'package:flutter/material.dart';

class AppColors {
  static const Color primaryGreen = Color(0xFF2D7A3A);
  static const Color primaryGreenDark = Color(0xFF1B5E20);
  static const Color primaryGreenLight = Color(0xFF4CAF50);
  static const Color backgroundGreen = Color(0xFFD8EDD0);
  static const Color lightGreen = Color(0xFFE8F5E9);
  static const Color cardGreen = Color(0xFFC8E6C9);

  static const Color brown = Color(0xFF6D4C1F);
  static const Color brownDark = Color(0xFF4E3414);
  static const Color brownLight = Color(0xFF8D6E63);

  static const Color white = Color(0xFFFFFFFF);
  static const Color offWhite = Color(0xFFF5F5F5);
  static const Color textDark = Color(0xFF1A2E1A);
  static const Color textMedium = Color(0xFF4A6A4A);
  static const Color textLight = Color(0xFF7A9A7A);
  static const Color divider = Color(0xFFB8D8B8);

  static const Color statusNew = Color(0xFF2196F3);
  static const Color statusPending = Color(0xFFFF9800);
  static const Color statusVerified = Color(0xFF4CAF50);
  static const Color statusRejected = Color(0xFFF44336);

  static const Color pink = Color(0xFFF8D7D7);
}

class AppTheme {
  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primaryGreen,
        secondary: AppColors.brown,
        surface: AppColors.white,
        background: AppColors.backgroundGreen,
      ),
      scaffoldBackgroundColor: AppColors.backgroundGreen,
      fontFamily: 'sans-serif',
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.backgroundGreen,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(color: AppColors.textDark),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.primaryGreen, width: 1.5),
        ),
        hintStyle: const TextStyle(color: AppColors.textLight, fontSize: 14),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.brown,
          foregroundColor: AppColors.white,
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, letterSpacing: 0.5),
        ),
      ),
    );
  }
}
