import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Main Brand Reds
  static const Color primaryRed = Color(0xFFFF2E2E);
  static const Color brightAccentRed = Color(0xFFFF3B3B);
  static const Color deepCrimson = Color(0xFFB11226);
  static const Color darkRedBase = Color(0xFF7A0C18);
  
  // Status Colors
  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFF97316);
  static const Color error = Color(0xFFEF4444);
  
  // Accent Colors
  static const Color yellow = Color(0xFFFACC15);
  static const Color orange = Color(0xFFFB923C);
  static const Color teal = Color(0xFF14B8A6);
  
  // Light Theme Colors
  static const Color lightBackground = Color(0xFFF8F9FA);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightPrimaryText = Color(0xFF1A1A2E);
  static const Color lightSecondaryText = Color(0xFF6B7280);
  static const Color lightMutedText = Color(0xFF9CA3AF);
  static const Color lightElevatedPanel = Color(0xFFFAFAFA);
  
  // Dark Theme Colors
  static const Color darkBackground = Color(0xFF0F0A0A);
  static const Color darkSurface = Color(0xFF1A0D0D);
  static const Color darkCard = Color(0xFF2A0F0F);
  static const Color darkPrimaryText = Color(0xFFFFFFFF);
  static const Color darkSecondaryText = Color(0xFFC9C9C9);
  static const Color darkMutedText = Color(0xFF8A8A8A);
  static const Color darkElevatedPanel = Color(0xFF331313);
  
  // Legacy colors for backward compatibility
  static const Color mainBackground = darkBackground;
  static const Color secondaryBackground = darkSurface;
  static const Color cardBackground = darkCard;
  static const Color elevatedPanel = darkElevatedPanel;
  static const Color primaryText = darkPrimaryText;
  static const Color secondaryText = darkSecondaryText;
  static const Color mutedText = darkMutedText;
  
  // Gradients
  static const LinearGradient primaryButtonGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryRed, deepCrimson],
  );
  
  static LinearGradient cardGlowGradient(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (isDark) {
      return const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [darkCard, darkRedBase],
      );
    } else {
      return const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [lightCard, lightCard],
      );
    }
  }
  
  // ==================== LIGHT THEME ====================
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: primaryRed,
    fontFamily: GoogleFonts.poppins().fontFamily,
    colorScheme: const ColorScheme.light(
      primary: primaryRed,
      secondary: brightAccentRed,
      surface: lightSurface,
      background: lightBackground,
      error: error,
    ),
    scaffoldBackgroundColor: lightBackground,
    appBarTheme: const AppBarTheme(
      elevation: 0,
      centerTitle: true,
      backgroundColor: lightSurface,
      foregroundColor: lightPrimaryText,
      titleTextStyle: TextStyle(
        fontSize: 18,
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
      ),
    ),
    cardTheme: const CardThemeData(
      elevation: 2,
      color: lightCard,
      shape: RoundedRectangleBorder(
        side: BorderSide.none,
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
      clipBehavior: Clip.antiAlias,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: lightBackground,
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
      hintStyle: const TextStyle(color: lightMutedText),
      labelStyle: const TextStyle(color: lightSecondaryText),
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
      backgroundColor: lightCard,
      selectedItemColor: primaryRed,
      unselectedItemColor: lightMutedText,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    ),
  );
  
  // ==================== DARK THEME ====================
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: primaryRed,
    fontFamily: GoogleFonts.poppins().fontFamily,
    colorScheme: const ColorScheme.dark(
      primary: primaryRed,
      secondary: brightAccentRed,
      surface: darkSurface,
      background: darkBackground,
      error: error,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: darkPrimaryText,
      onBackground: darkPrimaryText,
      onError: Colors.white,
    ),
    scaffoldBackgroundColor: darkBackground,
    appBarTheme: const AppBarTheme(
      elevation: 0,
      centerTitle: true,
      backgroundColor: darkBackground,
      foregroundColor: darkPrimaryText,
      titleTextStyle: TextStyle(
        fontSize: 18,
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
    cardTheme: const CardThemeData(
      elevation: 0,
      color: darkCard,
      shape: RoundedRectangleBorder(
        side: BorderSide.none,
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
      clipBehavior: Clip.antiAlias,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: darkSurface,
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
      hintStyle: const TextStyle(color: darkMutedText),
      labelStyle: const TextStyle(color: darkSecondaryText),
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
      backgroundColor: darkCard,
      selectedItemColor: primaryRed,
      unselectedItemColor: darkMutedText,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    ),
  );
  
  // ==================== DEFAULT THEME ====================
  static ThemeData get defaultTheme => darkTheme;
  
  // Helper methods for dynamic theming
  static Color getBackgroundColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? darkBackground : lightBackground;
  }
  
  static Color getPrimaryTextColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? darkPrimaryText : lightPrimaryText;
  }
  
  static Color getSecondaryTextColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? darkSecondaryText : lightSecondaryText;
  }
  
  static Color getMutedTextColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? darkMutedText : lightMutedText;
  }
  
  static Color getCardColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? darkCard : lightCard;
  }
  
  static Color getSurfaceColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? darkSurface : lightSurface;
  }
  
  static Color getElevatedPanelColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? darkElevatedPanel : lightElevatedPanel;
  }
  
  static LinearGradient getCardGlowGradient(BuildContext context) {
    return cardGlowGradient(context);
  }
  
  static LinearGradient getPrimaryButtonGradient() {
    return primaryButtonGradient;
  }
}