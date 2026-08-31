import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:arrow_puzzle/ui/core/skeuo.dart';

/// App theme — a warm, tactile, kid-friendly skeuomorphic look.
///
/// Uses the chunky rounded Fredoka typeface, a cozy cream/gold palette and
/// dark cocoa ink so the interface feels like a physical toy set.
class AppTheme {
  AppTheme._();

  static ThemeData get theme {
    final base = ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: Skeuo.bgTop,
      colorScheme: const ColorScheme.light(
        primary: Skeuo.green,
        secondary: Skeuo.orange,
        tertiary: Skeuo.blue,
        surface: Skeuo.card,
        onSurface: Skeuo.ink,
        onPrimary: Skeuo.onCandy,
      ),
      useMaterial3: true,
    );

    return base.copyWith(
      textTheme: GoogleFonts.fredokaTextTheme(base.textTheme).apply(
        bodyColor: Skeuo.ink,
        displayColor: Skeuo.ink,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: Skeuo.ink,
        elevation: 0,
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(foregroundColor: Skeuo.ink),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return Colors.white;
          return const Color(0xFFFFF3D2);
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return Skeuo.green;
          return Skeuo.inkSoft.withValues(alpha: 0.4);
        }),
        trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
      ),
    );
  }
}
