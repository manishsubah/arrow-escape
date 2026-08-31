import 'package:flutter/material.dart';

import 'package:arrow_puzzle/ui/core/skeuo.dart';

/// Headline text drawn as a die-cut sticker: a thick light outline behind a
/// solid fill, so titles read as a physical decal laid on the surface.
///
/// The outline is painted as a stroked copy of the same text under the fill.
/// Both copies share one [TextStyle] so they lay out identically and the
/// [Stack] takes the size of the glyphs.
class StickerText extends StatelessWidget {
  const StickerText(
    this.text, {
    super.key,
    this.style,
    this.color = Skeuo.ink,
    this.outlineColor = Colors.white,
    this.outlineWidth = 6,
    this.textAlign,
    this.dropShadow = true,
  });

  final String text;

  /// Base style; falls back to the theme's `headlineMedium`.
  final TextStyle? style;

  /// Fill color of the glyphs.
  final Color color;

  /// Color of the sticker's die-cut edge.
  final Color outlineColor;

  /// Thickness of the outline in logical pixels.
  final double outlineWidth;

  final TextAlign? textAlign;

  /// Whether the outline casts a soft shadow, lifting the decal off the page.
  final bool dropShadow;

  @override
  Widget build(BuildContext context) {
    final base = (style ?? Theme.of(context).textTheme.headlineMedium)
        ?.copyWith(fontWeight: FontWeight.w700);

    return Stack(
      children: [
        Text(
          text,
          textAlign: textAlign,
          style: base?.copyWith(
            foreground: Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = outlineWidth
              ..strokeJoin = StrokeJoin.round
              ..color = outlineColor,
            shadows: dropShadow
                ? const [
                    Shadow(
                      color: Color(0x33000000),
                      offset: Offset(0, 3),
                      blurRadius: 4,
                    ),
                  ]
                : null,
          ),
        ),
        Text(
          text,
          textAlign: textAlign,
          style: base?.copyWith(color: color),
        ),
      ],
    );
  }
}
