import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF6B4EFF),
        primary: const Color(0xFF6B4EFF),
        secondary: const Color(0xFFFF6B6B),
        surface: Colors.white,
      ),
      textTheme: GoogleFonts.nunitoTextTheme(),
      useMaterial3: true,
    );
  }

  static TextStyle get brandingTextStyle {
    return GoogleFonts.poppins(
      fontSize: 24,
      fontWeight: FontWeight.w800,
      letterSpacing: 1.5,
    );
  }
} 