import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// App theme matching the PRD color palette.
///
/// Colors from PRD:
///   Primary:    #3B82F6
///   Secondary:  #64748B
///   Accent:     #06B6D4
///   Background: #0F172A
///   Surface:    #1E293B
///   Text:       #F8FAFC
class AppTheme {
  AppTheme._();

  static const _primary = Color(0xFF3B82F6);
  static const _secondary = Color(0xFF64748B);
  static const _accent = Color(0xFF06B6D4);
  static const _background = Color(0xFF0F172A);
  static const _surface = Color(0xFF1E293B);
  static const _textColor = Color(0xFFF8FAFC);

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: _background,
      colorScheme: const ColorScheme.dark(
        primary: _primary,
        secondary: _secondary,
        tertiary: _accent,
        surface: _surface,
        onSurface: _textColor,
        onPrimary: _textColor,
        onSecondary: _textColor,
      ),
      textTheme: GoogleFonts.poppinsTextTheme(
        const TextTheme(
          displayLarge: TextStyle(color: _textColor),
          displayMedium: TextStyle(color: _textColor),
          headlineLarge: TextStyle(color: _textColor),
          headlineMedium: TextStyle(color: _textColor),
          titleLarge: TextStyle(color: _textColor),
          titleMedium: TextStyle(color: _textColor),
          bodyLarge: TextStyle(color: _textColor),
          bodyMedium: TextStyle(color: _textColor),
          labelLarge: TextStyle(color: _textColor),
          labelMedium: TextStyle(color: _textColor),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: _surface,
        foregroundColor: _textColor,
        elevation: 0,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _primary,
          foregroundColor: _textColor,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: _textColor,
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return _accent;
          return _secondary;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return _accent.withValues(alpha: 0.4);
          }
          return _secondary.withValues(alpha: 0.3);
        }),
      ),
      cardTheme: CardThemeData(
        color: _surface,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
