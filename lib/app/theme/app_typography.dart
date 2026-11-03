import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTypography {
  AppTypography._();

  static TextStyle _baseStyle({
    required double fontSize,
    required FontWeight fontWeight,
    Color color = AppColors.textPrimary,
    double? height,
    double? letterSpacing,
  }) {
    try {
      return GoogleFonts.manrope(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
        height: height,
        letterSpacing: letterSpacing,
      );
    } catch (_) {
      return TextStyle(
        fontFamily: 'sans-serif',
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
        height: height,
        letterSpacing: letterSpacing,
      );
    }
  }

  // Display: 34-40px Bold
  static TextStyle get display => _baseStyle(
        fontSize: 36,
        fontWeight: FontWeight.w700,
        height: 1.15,
        letterSpacing: -0.5,
      );

  // Big Counter / Numbers: 48-64px Bold (Tabular numbers)
  static TextStyle get counterBig => _baseStyle(
        fontSize: 56,
        fontWeight: FontWeight.w800,
        height: 1.1,
        letterSpacing: -1.0,
      );

  // H1: 28px Bold
  static TextStyle get h1 => _baseStyle(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        height: 1.2,
        letterSpacing: -0.3,
      );

  // H2: 22px SemiBold
  static TextStyle get h2 => _baseStyle(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        height: 1.25,
      );

  // H3: 18px SemiBold
  static TextStyle get h3 => _baseStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        height: 1.3,
      );

  // Body: 15px Regular
  static TextStyle get body => _baseStyle(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        height: 1.45,
      );

  // Body Medium: 15px Medium
  static TextStyle get bodyMedium => _baseStyle(
        fontSize: 15,
        fontWeight: FontWeight.w500,
        height: 1.45,
      );

  // Body Bold: 15px Bold
  static TextStyle get bodyBold => _baseStyle(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        height: 1.45,
      );

  // Caption: 12-13px Medium
  static TextStyle get caption => _baseStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: AppColors.textSecondary,
        height: 1.35,
        letterSpacing: 0.2,
      );

  // Button label: 15px SemiBold
  static TextStyle get button => _baseStyle(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.2,
      );
}
