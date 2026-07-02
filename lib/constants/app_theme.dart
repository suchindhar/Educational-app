// lib/constants/app_theme.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Scholar Gold palette - warm, not dark
  static const Color primary = Color(0xFFFEF9F3);      // Cream background
  static const Color secondary = Color(0xFF1E3A5F);    // Deep navy
  static const Color accent = Color(0xFFE07A5F);       // Terracotta
  static const Color gold = Color(0xFFD4A574);         // Soft gold
  static const Color success = Color(0xFF81B29A);      // Sage green
  static const Color warning = Color(0xFFF2CC8F);      // Warm amber
  static const Color error = Color(0xFFE63946);        // Clear red

  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color cardCream = Color(0xFFFDF6E9);
  static const Color textDark = Color(0xFF2D3436);
  static const Color textMedium = Color(0xFF636E72);
  static const Color textLight = Color(0xFFB2BEC3);

  // Unit colors - muted, warm
  static const List<Color> unitColors = [
    Color(0xFF6B9080), // Sage
    Color(0xFFBC6C25), // Bronze
    Color(0xFF606C38), // Olive
    Color(0xFF9C6644), // Coffee
    Color(0xFF7F5539), // Cinnamon
    Color(0xFF4A6FA5), // Steel blue
  ];

  // Kahoot-style answer colors
  static const Color answerRed    = Color(0xFFE21B3C);
  static const Color answerBlue   = Color(0xFF1368CE);
  static const Color answerYellow = Color(0xFFD89E00);
  static const Color answerGreen  = Color(0xFF26890C);
}

class AppTheme {
  static ThemeData get light {
    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.primary,
      primaryColor: AppColors.secondary,
      colorScheme: const ColorScheme.light(
        primary: AppColors.secondary,
        secondary: AppColors.accent,
        surface: AppColors.cardLight,
        background: AppColors.primary,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: AppColors.textDark,
      ),
      textTheme: GoogleFonts.plusJakartaSansTextTheme(
        ThemeData.light().textTheme,
      ).apply(
        bodyColor: AppColors.textDark,
        displayColor: AppColors.textDark,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.primary,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.secondary),
        titleTextStyle: TextStyle(
          color: AppColors.secondary,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.cardLight,
        elevation: 4,
        shadowColor: Colors.black12,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.secondary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.cardLight,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE8E8E8)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.secondary, width: 2),
        ),
      ),
    );
  }
}
