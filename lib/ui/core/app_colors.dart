import 'dart:ui';

/// Colors used for arrows on the puzzle board.
/// Derived from the PRD palette.
class ArrowColors {
  ArrowColors._();

  static const List<Color> palette = [
    Color(0xFF3B82F6), // Primary Blue
    Color(0xFF06B6D4), // Accent Cyan
    Color(0xFFEF4444), // Red
    Color(0xFF22C55E), // Green
    Color(0xFFF59E0B), // Amber
  ];

  static Color fromIndex(int index) => palette[index % palette.length];
}
