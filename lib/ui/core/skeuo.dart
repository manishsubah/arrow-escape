import 'package:flutter/material.dart';

/// Skeuomorphic "Toy Box" design tokens — the single source of truth for color,
/// depth and elevation across the app.
///
/// A warm, tactile, kid-friendly palette that mimics real toys: candy-colored
/// glossy buttons, a wooden play board and a cozy cream background. Consumed by
/// [ChunkyButton], [SkeuoPanel], [StickerText] and the individual screens.
///
/// Every raised surface in the app is built from the same three-part recipe:
/// a [faceOf] top gradient stop, the [color] itself as the bottom stop, and a
/// [lipOf] base sitting underneath. Keeping those ratios here — rather than
/// re-deriving them per widget — is what makes the surfaces read as one
/// material.
class Skeuo {
  Skeuo._();

  // ---- Background (warm sunny playroom) ----
  static const bgTop = Color(0xFFFFF3D2); // cream
  static const bgBottom = Color(0xFFFFC97A); // warm gold

  static const backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [bgTop, bgBottom],
  );

  // ---- Text (warm, cozy) ----
  static const ink = Color(0xFF5A3921); // dark cocoa — headings
  static const inkSoft = Color(0xFF9C6B3F); // secondary text
  static const onCandy = Color(0xFFFFFFFF); // text on candy buttons

  // ---- Candy button faces ----
  static const green = Color(0xFF7ED957);
  static const blue = Color(0xFF4FC3F7);
  static const orange = Color(0xFFFFB24D);
  static const red = Color(0xFFFF7A7A);
  static const yellow = Color(0xFFFFD24D);
  static const purple = Color(0xFFB388E8);

  // ---- Semantic ----
  static const star = Color(0xFFFFC53D); // earned star / gold accents
  static const heart = Color(0xFFF2555A); // life pips
  static const danger = Color(0xFFE8484E); // failure state
  static const muted = Color(0xFFCBB79C); // grey-tan plastic: locked/disabled

  // ---- Wood play board ----
  static const woodTop = Color(0xFFC8935F);
  static const woodBottom = Color(0xFFA56B3A);
  static const woodEdge = Color(0xFF7A4A24);
  static const woodInset = Color(0xFF8A5A30); // recessed grid well

  static const woodGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [woodTop, woodBottom],
  );

  // ---- Cream card ----
  static const card = Color(0xFFFFF8EC);
  static const cardEdge = Color(0xFFE7C79A);

  /// Colors used for the arrow blocks on the puzzle board.
  ///
  /// Deliberately restricted to hues that stay legible against the mid-brown
  /// wooden board — a level's `colorIndex` is decorative grouping, so the order
  /// matters only for visual variety.
  static const arrowPalette = <Color>[blue, green, red, purple, orange];

  /// Palette color for a level's arrow `colorIndex`, wrapping if out of range.
  static Color arrowColor(int index) =>
      arrowPalette[index % arrowPalette.length];

  // ---- Depth recipe ----

  /// How much lighter the top of a raised face is than its base color.
  static const faceLift = 0.22;

  /// How much darker the base "lip" under a raised face is.
  static const lipDrop = 0.30;

  /// Top gradient stop for a raised candy face of base [c].
  static Color faceOf(Color c) => lighten(c, faceLift);

  /// The darker base a raised face of [c] appears to sit on.
  static Color lipOf(Color c) => darken(c, lipDrop);

  /// A soft drop shadow that lifts a surface off the background.
  static List<BoxShadow> lift({
    double y = 8,
    double blur = 14,
    double alpha = 0.22,
  }) => [
    BoxShadow(
      color: Colors.black.withValues(alpha: alpha),
      blurRadius: blur,
      offset: Offset(0, y),
    ),
  ];

  /// A gloss sheen gradient for the top [stop] fraction of a surface.
  static LinearGradient gloss({double alpha = 0.45, double stop = 0.5}) =>
      LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.white.withValues(alpha: alpha),
          Colors.white.withValues(alpha: 0.0),
        ],
        stops: [0.0, stop],
      );

  /// Shadow that makes light text on a candy face read as embossed.
  static const embossedText = <Shadow>[
    Shadow(color: Color(0x40000000), offset: Offset(0, 1.5), blurRadius: 2),
  ];

  /// Lighten [c] toward white by [amount] (0..1).
  static Color lighten(Color c, [double amount = 0.15]) =>
      Color.lerp(c, Colors.white, amount)!;

  /// Darken [c] toward black by [amount] (0..1).
  static Color darken(Color c, [double amount = 0.15]) =>
      Color.lerp(c, Colors.black, amount)!;

  /// Drain the color out of [c] toward the muted plastic tone — used for
  /// locked and non-interactive pieces so they read as "switched off" rather
  /// than merely transparent.
  static Color desaturate(Color c, [double amount = 0.55]) =>
      Color.lerp(c, muted, amount)!;
}
