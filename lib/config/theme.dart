import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // ==================== MAIN BRAND REDS ====================
  static const Color primaryRed = Color(0xFFFF2E2E);      // Primary Red
  static const Color brightAccentRed = Color(0xFFFF3B3B); // Bright Accent Red
  static const Color deepCrimson = Color(0xFFB11226);     // Deep Crimson
  static const Color darkRedBase = Color(0xFF7A0C18);     // Dark Red Base
  
  // ==================== BACKGROUND COLORS ====================
  static const Color mainBackground = Color(0xFF0F0A0A);     // Main Background
  static const Color secondaryBackground = Color(0xFF1A0D0D); // Secondary Background
  static const Color cardBackground = Color(0xFF2A0F0F);      // Card Background
  static const Color elevatedPanel = Color(0xFF331313);      // Elevated Panel
  
  // ==================== TEXT COLORS ====================
  static const Color primaryText = Color(0xFFFFFFFF);        // Primary Text
  static const Color secondaryText = Color(0xFFC9C9C9);      // Secondary Text
  static const Color mutedText = Color(0xFF8A8A8A);          // Muted Text
  
  // ==================== STATUS COLORS ====================
  static const Color success = Color(0xFF22C55E);             // Success Green
  static const Color warning = Color(0xFFF97316);             // Warning Orange
  static const Color error = Color(0xFFEF4444);               // Error Red
  
  // ==================== ACCENT COLORS ====================
  static const Color yellow = Color(0xFFFACC15);              // Yellow
  static const Color orange = Color(0xFFFB923C);              // Orange
  static const Color teal = Color(0xFF14B8A6);                // Teal
  
  // ==================== LEGACY/ALIAS COLORS ====================
  static const Color primaryColor = primaryRed;
  static const Color secondaryColor = brightAccentRed;
  static const Color successColor = success;
  static const Color warningColor = warning;
  static const Color errorColor = error;
  
  // ==================== GRADIENTS ====================
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryRed, deepCrimson],
  );
  
  static const LinearGradient primaryButtonGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryRed, deepCrimson],
  );
  
  static const LinearGradient cardGlowGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [cardBackground, darkRedBase],
  );
  
  static const LinearGradient backgroundGlowGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [mainBackground, secondaryBackground],
  );
  
  // ==================== LIGHT THEME ====================
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
    scaffoldBackgroundColor: mainBackground,
    appBarTheme: const AppBarTheme(
      elevation: 0,
      centerTitle: true,
      backgroundColor: Colors.white,
      foregroundColor: mainBackground,
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: mainBackground,
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
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
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
    ),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(color: mainBackground, fontSize: 32, fontWeight: FontWeight.bold),
      headlineMedium: TextStyle(color: mainBackground, fontSize: 28, fontWeight: FontWeight.bold),
      headlineSmall: TextStyle(color: mainBackground, fontSize: 24, fontWeight: FontWeight.bold),
      titleLarge: TextStyle(color: mainBackground, fontSize: 20, fontWeight: FontWeight.w600),
      titleMedium: TextStyle(color: mainBackground, fontSize: 18, fontWeight: FontWeight.w600),
      titleSmall: TextStyle(color: mainBackground, fontSize: 16, fontWeight: FontWeight.w600),
      bodyLarge: TextStyle(color: secondaryText, fontSize: 16),
      bodyMedium: TextStyle(color: secondaryText, fontSize: 14),
      bodySmall: TextStyle(color: mutedText, fontSize: 12),
      labelLarge: TextStyle(color: mainBackground, fontSize: 14, fontWeight: FontWeight.w500),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: cardBackground,
      selectedItemColor: primaryRed,
      unselectedItemColor: mutedText,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    ),
  );
  
  // ==================== DARK THEME (Main Theme for Driver App) ====================
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
      centerTitle: false,
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
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primaryRed,
        side: const BorderSide(color: primaryRed),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
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
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: error, width: 1),
      ),
      hintStyle: const TextStyle(color: mutedText),
      labelStyle: const TextStyle(color: secondaryText),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(color: primaryText, fontSize: 32, fontWeight: FontWeight.bold),
      headlineMedium: TextStyle(color: primaryText, fontSize: 28, fontWeight: FontWeight.bold),
      headlineSmall: TextStyle(color: primaryText, fontSize: 24, fontWeight: FontWeight.bold),
      titleLarge: TextStyle(color: primaryText, fontSize: 20, fontWeight: FontWeight.w600),
      titleMedium: TextStyle(color: primaryText, fontSize: 18, fontWeight: FontWeight.w600),
      titleSmall: TextStyle(color: primaryText, fontSize: 16, fontWeight: FontWeight.w600),
      bodyLarge: TextStyle(color: secondaryText, fontSize: 16),
      bodyMedium: TextStyle(color: secondaryText, fontSize: 14),
      bodySmall: TextStyle(color: mutedText, fontSize: 12),
      labelLarge: TextStyle(color: primaryText, fontSize: 14, fontWeight: FontWeight.w500),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: cardBackground,
      selectedItemColor: primaryRed,
      unselectedItemColor: mutedText,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    ),
    dividerTheme: const DividerThemeData(
      color: deepCrimson,
      thickness: 0.5,
      space: 1,
    ),
    // FIXED: Changed DialogTheme to DialogThemeData
    dialogTheme: const DialogThemeData(
      backgroundColor: cardBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(20)),
      ),
      elevation: 0,
    ),
    snackBarTheme: const SnackBarThemeData(
      backgroundColor: cardBackground,
      contentTextStyle: TextStyle(color: primaryText),
      behavior: SnackBarBehavior.floating,
    ),
  );
  
  // ==================== DEFAULT THEME ====================
  static ThemeData get defaultTheme => darkTheme;
}