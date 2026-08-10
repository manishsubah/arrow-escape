import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// App-wide text styles using Poppins font.
class AppTextStyles {
  AppTextStyles._();

  static TextStyle get _basePoppins => GoogleFonts.poppins(
        color: const Color(0xFFF8FAFC),
      );

  static TextStyle get displayLarge =>
      _basePoppins.copyWith(fontSize: 48, fontWeight: FontWeight.w700);

  static TextStyle get displayMedium =>
      _basePoppins.copyWith(fontSize: 36, fontWeight: FontWeight.w700);

  static TextStyle get headlineLarge =>
      _basePoppins.copyWith(fontSize: 28, fontWeight: FontWeight.w600);

  static TextStyle get headlineMedium =>
      _basePoppins.copyWith(fontSize: 24, fontWeight: FontWeight.w600);

  static TextStyle get titleLarge =>
      _basePoppins.copyWith(fontSize: 20, fontWeight: FontWeight.w600);

  static TextStyle get titleMedium =>
      _basePoppins.copyWith(fontSize: 16, fontWeight: FontWeight.w500);

  static TextStyle get bodyLarge =>
      _basePoppins.copyWith(fontSize: 16, fontWeight: FontWeight.w400);

  static TextStyle get bodyMedium =>
      _basePoppins.copyWith(fontSize: 14, fontWeight: FontWeight.w400);

  static TextStyle get labelLarge =>
      _basePoppins.copyWith(fontSize: 14, fontWeight: FontWeight.w600);

  static TextStyle get labelMedium =>
      _basePoppins.copyWith(fontSize: 12, fontWeight: FontWeight.w500);
}
