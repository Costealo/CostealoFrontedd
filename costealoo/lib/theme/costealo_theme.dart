import 'package:flutter/material.dart';

class CostealoColors {
  static const Color primary      = Color(0xFF5F8F6B); // baby green principal
  static const Color primaryDark  = Color(0xFF335F3F);
  static const Color primaryLight = Color(0xFFE6F3E8);
  static const Color card         = Color(0xFFF7FBF7);
  static const Color cardSoft     = Color(0xFFEDF7EE);
  static const Color accent       = Color(0xFF8ECF9B);
  static const Color text         = Color(0xFF26412F);
}

class CostealoTheme {
  static ThemeData get light {
    final base = ThemeData.light();
    return base.copyWith(
      scaffoldBackgroundColor: CostealoColors.primaryLight,
      colorScheme: ColorScheme.fromSeed(
        seedColor: CostealoColors.primary,
        primary: CostealoColors.primary,
        secondary: CostealoColors.accent,
      ),
      textTheme: base.textTheme.copyWith(
        headlineLarge: const TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w800,
          color: CostealoColors.text,
        ),
        headlineMedium: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: CostealoColors.text,
        ),
        bodyMedium: const TextStyle(
          fontSize: 14,
          color: CostealoColors.text,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: CostealoColors.cardSoft,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: BorderSide.none,
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      ),
    );
  }
}
