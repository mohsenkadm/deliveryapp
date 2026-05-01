import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTextStyles {
  AppTextStyles._();

  // Headings
  static TextStyle get headlineLarge => GoogleFonts.cairo(
        fontSize: 28,
        fontWeight: FontWeight.w700,
      );

  static TextStyle get headlineMedium => GoogleFonts.cairo(
        fontSize: 24,
        fontWeight: FontWeight.w700,
      );

  static TextStyle get headlineSmall => GoogleFonts.cairo(
        fontSize: 20,
        fontWeight: FontWeight.w600,
      );

  // Titles
  static TextStyle get titleLarge => GoogleFonts.cairo(
        fontSize: 18,
        fontWeight: FontWeight.w600,
      );

  static TextStyle get titleMedium => GoogleFonts.cairo(
        fontSize: 16,
        fontWeight: FontWeight.w600,
      );

  static TextStyle get titleSmall => GoogleFonts.cairo(
        fontSize: 14,
        fontWeight: FontWeight.w600,
      );

  // Body
  static TextStyle get bodyLarge => GoogleFonts.cairo(
        fontSize: 16,
        fontWeight: FontWeight.w400,
      );

  static TextStyle get bodyMedium => GoogleFonts.cairo(
        fontSize: 14,
        fontWeight: FontWeight.w400,
      );

  static TextStyle get bodySmall => GoogleFonts.cairo(
        fontSize: 12,
        fontWeight: FontWeight.w400,
      );

  // Labels
  static TextStyle get labelLarge => GoogleFonts.cairo(
        fontSize: 14,
        fontWeight: FontWeight.w500,
      );

  static TextStyle get labelSmall => GoogleFonts.cairo(
        fontSize: 11,
        fontWeight: FontWeight.w500,
      );

  // Button
  static TextStyle get button => GoogleFonts.cairo(
        fontSize: 16,
        fontWeight: FontWeight.w600,
      );
}
