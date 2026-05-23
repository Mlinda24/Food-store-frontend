import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Main Brand Reds
  static const Color primaryRed = Color(0xFFFF2E2E);
  static const Color brightAccentRed = Color(0xFFFF3B3B);
  static const Color deepCrimson = Color(0xFFB11226);
  static const Color darkRedBase = Color(0xFF7A0C18);

  // Background Colors
  static const Color mainBackground = Color(0xFF0F0A0A);
  static const Color secondaryBackground = Color(0xFF1A0D0D);
  static const Color cardBackground = Color(0xFF2A0F0F);
  static const Color elevatedPanel = Color(0xFF331313);

  // Text Colors
  static const Color primaryText = Color(0xFFFFFFFF);
  static const Color secondaryText = Color(0xFFC9C9C9);
  static const Color mutedText = Color(0xFF8A8A8A);

  // Light Theme Colors
  static const Color lightBackground = Color(0xFFFFFFFF);
  static const Color lightPrimaryText = Color(0xFF1A0D0D);
  static const Color lightSecondaryText = Color(0xFF666666);
  static const Color lightMutedText = Color(0xFF999999);
  static const Color lightSurface = Color(0xFFF5F5F5);
  static const Color lightCard = Color(0xFFFFFFFF);

  // Dark Theme Colors
  static const Color darkBackground = Color(0xFF0F0A0A);
  static const Color darkPrimaryText = Color(0xFFFFFFFF);
  static const Color darkSecondaryText = Color(0xFFC9C9C9);
  static const Color darkMutedText = Color(0xFF8A8A8A);
  static const Color darkSurface = Color(0xFF2A0F0F);
  static const Color darkCard = Color(0xFF2A0F0F);

  // Status Colors
  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFF97316);
  static const Color error = Color(0xFFEF4444);

  // Accent Colors
  static const Color yellow = Color(0xFFFACC15);
  static const Color orange = Color(0xFFFB923C);
  static const Color teal = Color(0xFF14B8A6);

  // Legacy color names for backward compatibility
  static const Color primaryColor = primaryRed;
  static const Color secondaryColor = brightAccentRed;
  static const Color successColor = success;
  static const Color warningColor = warning;
  static const Color errorColor = error;

  // Gradients
  static const LinearGradient primaryButtonGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryRed, deepCrimson],
  );

  static const LinearGradient cardGlowGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF2A0F0F), Color(0xFF1A0D0D)],
  );

  static const LinearGradient backgroundGlowGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [mainBackground, secondaryBackground],
  );

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: primaryRed,
    colorScheme: const ColorScheme.light(
      primary: primaryRed,
      secondary: brightAccentRed,
      surface: Colors.white,
      error: error,
    ),
    fontFamily: GoogleFonts.poppins().fontFamily,
    scaffoldBackgroundColor: Colors.white,
    appBarTheme: const AppBarTheme(
      elevation: 0,
      centerTitle: true,
      backgroundColor: Colors.white,
      foregroundColor: Color(0xFF1A0D0D),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryRed,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 48),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
    cardTheme: const CardThemeData(
      elevation: 2,
      shape: RoundedRectangleBorder(
        side: BorderSide.none,
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
      clipBehavior: Clip.antiAlias,
    ),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: primaryRed,
    colorScheme: const ColorScheme.dark(
      primary: primaryRed,
      secondary: brightAccentRed,
      surface: cardBackground,
      background: mainBackground,
      error: error,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: primaryText,
      onBackground: primaryText,
      onError: Colors.white,
    ),
    fontFamily: GoogleFonts.poppins().fontFamily,
    scaffoldBackgroundColor: mainBackground,
    appBarTheme: const AppBarTheme(
      elevation: 0,
      centerTitle: true,
      backgroundColor: mainBackground,
      foregroundColor: primaryText,
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: primaryText,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryRed,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 48),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 0,
      ),
    ),
    cardTheme: const CardThemeData(
      elevation: 0,
      color: cardBackground,
      shape: RoundedRectangleBorder(
        side: BorderSide.none,
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
      clipBehavior: Clip.antiAlias,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: secondaryBackground,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primaryRed, width: 2),
      ),
      hintStyle: const TextStyle(color: mutedText),
      labelStyle: const TextStyle(color: secondaryText),
    ),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
          color: primaryText, fontSize: 32, fontWeight: FontWeight.bold),
      headlineMedium: TextStyle(
          color: primaryText, fontSize: 28, fontWeight: FontWeight.bold),
      headlineSmall: TextStyle(
          color: primaryText, fontSize: 24, fontWeight: FontWeight.bold),
      titleLarge: TextStyle(
          color: primaryText, fontSize: 20, fontWeight: FontWeight.w600),
      titleMedium: TextStyle(
          color: primaryText, fontSize: 18, fontWeight: FontWeight.w600),
      titleSmall: TextStyle(
          color: primaryText, fontSize: 16, fontWeight: FontWeight.w600),
      bodyLarge: TextStyle(color: secondaryText, fontSize: 16),
      bodyMedium: TextStyle(color: secondaryText, fontSize: 14),
      bodySmall: TextStyle(color: mutedText, fontSize: 12),
      labelLarge: TextStyle(
          color: primaryText, fontSize: 14, fontWeight: FontWeight.w500),
    ),
  );
}
