import 'package:flutter/material.dart';

class FptColors {
  // FPT Brand Colors
  static const Color orange = Color(0xFFF37021); // FPT Primary Orange
  static const Color orangeLight = Color(0xFFFF8B3D);
  static const Color orangeDark = Color(0xFFD65809);
  
  static const Color blue = Color(0xFF0054A6); // FPT Corporate Blue
  static const Color navy = Color(0xFF0B192C); // Modern Dark Navy
  static const Color darkCard = Color(0xFF152238);
  static const Color lightBg = Color(0xFFF8FAFC);
  static const Color white = Color(0xFFFFFFFF);
  
  // Status & Betting Colors (Polymarket Style)
  static const Color yesGreen = Color(0xFF10B981); // Polymarket YES / Profit
  static const Color yesGreenBg = Color(0xFFE6F4EA);
  static const Color noRed = Color(0xFFEF4444); // Polymarket NO / Loss
  static const Color noRedBg = Color(0xFFFEE2E2);
  
  // Candy Theme Colors
  static const Color candyGold = Color(0xFFF59E0B);
  static const Color candyPink = Color(0xFFEC4899);
  static const Color candyPurple = Color(0xFF8B5CF6);
  
  // Neutrals
  static const Color gray50 = Color(0xFFF9FAFB);
  static const Color gray100 = Color(0xFFF3F4F6);
  static const Color gray200 = Color(0xFFE5E7EB);
  static const Color gray400 = Color(0xFF9CA3AF);
  static const Color gray600 = Color(0xFF4B5563);
  static const Color gray800 = Color(0xFF1F2937);
  static const Color textDark = Color(0xFF0F172A);
  static const Color textMuted = Color(0xFF64748B);
}

class FptTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: FptColors.lightBg,
      primaryColor: FptColors.orange,
      colorScheme: ColorScheme.fromSeed(
        seedColor: FptColors.orange,
        primary: FptColors.orange,
        secondary: FptColors.blue,
        surface: FptColors.white,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: FptColors.white,
        foregroundColor: FptColors.textDark,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: FptColors.textDark,
        ),
      ),
      cardTheme: CardThemeData(
        color: FptColors.white,
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFFE2E8F0), width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: FptColors.orange,
          foregroundColor: FptColors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: FptColors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: FptColors.gray200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: FptColors.gray200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: FptColors.orange, width: 2),
        ),
        labelStyle: const TextStyle(color: FptColors.gray600),
      ),
    );
  }
}
