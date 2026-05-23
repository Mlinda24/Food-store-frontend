import 'package:flutter/material.dart';

class AppTheme {
  static const LinearGradient cardGlow = LinearGradient(
    colors: [Colors.white, Color(0xFFF5F5F5)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient primaryButton = LinearGradient(
    colors: [Color(0xFFFF6B6B), Color(0xFFFF8E53)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
