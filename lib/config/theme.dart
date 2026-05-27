import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // ==================== MAIN BRAND REDS ====================
  static const Color primaryRed = Color(0xFFFF2E2E);
  static const Color brightAccentRed = Color(0xFFFF3B3B);
  static const Color deepCrimson = Color(0xFFB11226);
  static const Color darkRedBase = Color(0xFF7A0C18);
  
  // ==================== DARK THEME COLORS ====================
  static const Color darkBackground = Color(0xFF0F0A0A);
  static const Color darkSecondaryBackground = Color(0xFF1A0D0D);
  static const Color darkCardBackground = Color(0xFF2A0F0F);
  static const Color darkPrimaryText = Color(0xFFFFFFFF);
  static const Color darkSecondaryText = Color(0xFFC9C9C9);
  static const Color darkMutedText = Color(0xFF8A8A8A);
  
  // ==================== LIGHT THEME COLORS ====================
  static const Color lightBackground = Color(0xFFF5F5F5);
  static const Color lightSecondaryBackground = Color(0xFFFAFAFA);
  static const Color lightCardBackground = Color(0xFFFFFFFF);
  static const Color lightPrimaryText = Color(0xFF212121);
  static const Color lightSecondaryText = Color(0xFF757575);
  static const Color lightMutedText = Color(0xFFBDBDBD);
  
  // ==================== STATUS COLORS ====================
  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFF97316);
  static const Color error = Color(0xFFEF4444);
  static const Color yellow = Color(0xFFFACC15);
  static const Color orange = Color(0xFFFB923C);
  static const Color teal = Color(0xFF14B8A6);
  
  // ==================== LEGACY/ALIAS COLORS (for backward compatibility) ====================
  static const Color mainBackground = darkBackground;
  static const Color secondaryBackground = darkSecondaryBackground;
  static const Color cardBackground = darkCardBackground;
  static const Color primaryText = darkPrimaryText;
  static const Color secondaryText = darkSecondaryText;
  static const Color mutedText = darkMutedText;
  static const Color elevatedPanel = Color(0xFF331313);
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
  
  static const LinearGradient darkCardGlowGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [darkCardBackground, darkRedBase],
  );
  
  static const LinearGradient lightCardGlowGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [lightCardBackground, lightSecondaryBackground],
  );
  
  static const LinearGradient backgroundGlowGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [darkBackground, darkSecondaryBackground],
  );
  
  // ==================== LIGHT THEME ====================
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: primaryRed,
    primarySwatch: Colors.red,
    colorScheme: const ColorScheme.light(
      primary: primaryRed,
      secondary: brightAccentRed,
      surface: lightCardBackground,
      error: error,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: lightPrimaryText,
      onError: Colors.white,
    ),
    fontFamily: GoogleFonts.poppins().fontFamily,
    scaffoldBackgroundColor: lightBackground,
    appBarTheme: const AppBarTheme(
      elevation: 0,
      centerTitle: false,
      backgroundColor: lightBackground,
      foregroundColor: lightPrimaryText,
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: lightPrimaryText,
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
      color: lightCardBackground,
      shape: RoundedRectangleBorder(
        side: BorderSide.none,
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
      clipBehavior: Clip.antiAlias,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: lightSecondaryBackground,
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
      hintStyle: const TextStyle(color: lightMutedText),
      labelStyle: const TextStyle(color: lightSecondaryText),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(color: lightPrimaryText, fontSize: 32, fontWeight: FontWeight.bold),
      headlineMedium: TextStyle(color: lightPrimaryText, fontSize: 28, fontWeight: FontWeight.bold),
      headlineSmall: TextStyle(color: lightPrimaryText, fontSize: 24, fontWeight: FontWeight.bold),
      titleLarge: TextStyle(color: lightPrimaryText, fontSize: 20, fontWeight: FontWeight.w600),
      titleMedium: TextStyle(color: lightPrimaryText, fontSize: 18, fontWeight: FontWeight.w600),
      titleSmall: TextStyle(color: lightPrimaryText, fontSize: 16, fontWeight: FontWeight.w600),
      bodyLarge: TextStyle(color: lightSecondaryText, fontSize: 16),
      bodyMedium: TextStyle(color: lightSecondaryText, fontSize: 14),
      bodySmall: TextStyle(color: lightMutedText, fontSize: 12),
      labelLarge: TextStyle(color: lightPrimaryText, fontSize: 14, fontWeight: FontWeight.w500),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: lightCardBackground,
      selectedItemColor: primaryRed,
      unselectedItemColor: lightMutedText,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    ),
    dividerTheme: const DividerThemeData(
      color: deepCrimson,
      thickness: 0.5,
      space: 1,
    ),
    dialogTheme: const DialogThemeData(
      backgroundColor: lightCardBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(20)),
      ),
      elevation: 0,
    ),
    snackBarTheme: const SnackBarThemeData(
      backgroundColor: lightCardBackground,
      contentTextStyle: TextStyle(color: lightPrimaryText),
      behavior: SnackBarBehavior.floating,
    ),
  );
  
  // ==================== DARK THEME ====================
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: primaryRed,
    primarySwatch: Colors.red,
    colorScheme: const ColorScheme.dark(
      primary: primaryRed,
      secondary: brightAccentRed,
      surface: darkCardBackground,
      error: error,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: darkPrimaryText,
      onError: Colors.white,
    ),
    fontFamily: GoogleFonts.poppins().fontFamily,
    scaffoldBackgroundColor: darkBackground,
    appBarTheme: const AppBarTheme(
      elevation: 0,
      centerTitle: false,
      backgroundColor: darkBackground,
      foregroundColor: darkPrimaryText,
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: darkPrimaryText,
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
      color: darkCardBackground,
      shape: RoundedRectangleBorder(
        side: BorderSide.none,
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
      clipBehavior: Clip.antiAlias,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: darkSecondaryBackground,
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
      hintStyle: const TextStyle(color: darkMutedText),
      labelStyle: const TextStyle(color: darkSecondaryText),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(color: darkPrimaryText, fontSize: 32, fontWeight: FontWeight.bold),
      headlineMedium: TextStyle(color: darkPrimaryText, fontSize: 28, fontWeight: FontWeight.bold),
      headlineSmall: TextStyle(color: darkPrimaryText, fontSize: 24, fontWeight: FontWeight.bold),
      titleLarge: TextStyle(color: darkPrimaryText, fontSize: 20, fontWeight: FontWeight.w600),
      titleMedium: TextStyle(color: darkPrimaryText, fontSize: 18, fontWeight: FontWeight.w600),
      titleSmall: TextStyle(color: darkPrimaryText, fontSize: 16, fontWeight: FontWeight.w600),
      bodyLarge: TextStyle(color: darkSecondaryText, fontSize: 16),
      bodyMedium: TextStyle(color: darkSecondaryText, fontSize: 14),
      bodySmall: TextStyle(color: darkMutedText, fontSize: 12),
      labelLarge: TextStyle(color: darkPrimaryText, fontSize: 14, fontWeight: FontWeight.w500),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: darkCardBackground,
      selectedItemColor: primaryRed,
      unselectedItemColor: darkMutedText,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    ),
    dividerTheme: const DividerThemeData(
      color: deepCrimson,
      thickness: 0.5,
      space: 1,
    ),
    dialogTheme: const DialogThemeData(
      backgroundColor: darkCardBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(20)),
      ),
      elevation: 0,
    ),
    snackBarTheme: const SnackBarThemeData(
      backgroundColor: darkCardBackground,
      contentTextStyle: TextStyle(color: darkPrimaryText),
      behavior: SnackBarBehavior.floating,
    ),
  );
  
  // ==================== HELPER METHODS ====================
  static LinearGradient getCardGlowGradient(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (isDark) {
      return darkCardGlowGradient;
    } else {
      return lightCardGlowGradient;
    }
  }
  
  // Legacy gradient for backward compatibility
  static const LinearGradient cardGlowGradient = darkCardGlowGradient;
}