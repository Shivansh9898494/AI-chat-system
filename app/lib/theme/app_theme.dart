import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  AppTheme._();

  // Primary Color Palette
  static const Color bgDark = Color(0xFF090B10);
  static const Color darkBackground = bgDark;
  static const Color bgSurface = Color(0xFF101420);
  static const Color cardBg = Color(0x1A1D273A);
  static const Color glassBorder = Color(0x3364748B);
  
  // Neon Accents
  static const Color primaryCyan = Color(0xFF00F2FE);
  static const Color cyberCyan = primaryCyan;
  static const Color primaryBlue = Color(0xFF4FACFE);
  static const Color neonPurple = Color(0xFF9D4EDD);
  static const Color neonPink = Color(0xFFFF2A85);
  static const Color accentGold = Color(0xFFFFB703);
  static const Color successGreen = Color(0xFF00F5D4);

  // Text Colors
  static const Color textPrimary = Color(0xFFF8FAFC);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color textMuted = Color(0xFF64748B);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryCyan, primaryBlue],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient neonGradient = LinearGradient(
    colors: [primaryCyan, neonPurple, neonPink],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient glassGradient = LinearGradient(
    colors: [
      Color(0x20FFFFFF),
      Color(0x08FFFFFF),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGlowGradient = LinearGradient(
    colors: [
      Color(0x3300F2FE),
      Color(0x119D4EDD),
      Color(0x05000000),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Theme Data definition
  static ThemeData get darkTheme {
    return ThemeData.dark().copyWith(
      scaffoldBackgroundColor: bgDark,
      primaryColor: primaryCyan,
      colorScheme: const ColorScheme.dark(
        primary: primaryCyan,
        secondary: neonPurple,
        surface: bgSurface,
      ),
      textTheme: GoogleFonts.outfitTextTheme().apply(
        bodyColor: textPrimary,
        displayColor: textPrimary,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
    );
  }
}
