import 'package:flutter/material.dart';

import 'package:arrow_puzzle/ui/core/skeuo.dart';

/// A raised, beveled panel — the skeuomorphic surface for cards and boards.
///
/// Simulates a physical molded panel: a thick colored edge, a soft outer drop
/// shadow for lift, a top highlight and a bottom shading gradient so it reads
/// as a rounded, tactile object rather than a flat rectangle.
class SkeuoPanel extends StatelessWidget {
  const SkeuoPanel({
    super.key,
    required this.child,
    this.color = Skeuo.card,
    this.edgeColor = Skeuo.cardEdge,
    this.radius = 24,
    this.padding = const EdgeInsets.all(20),
    this.width,
    this.height,
    this.recessed = false,
    this.onTap,
  });

  final Widget child;
  final Color color;
  final Color edgeColor;
  final double radius;
  final EdgeInsetsGeometry padding;
  final double? width;
  final double? height;

  /// When true, renders as a sunken well (for insets and tracks) instead of a
  /// raised panel — inverted shading and an inset shadow feel.
  final bool recessed;

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(radius);
    final panel = Container(
      width: width,
      height: height,
      padding: padding,
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: recessed
              ? [Skeuo.darken(color, 0.10), color]
              : [Skeuo.lighten(color, 0.10), color],
        ),
        border: Border.all(color: edgeColor, width: 2.5),
        boxShadow: recessed ? null : Skeuo.lift(y: 10, blur: 20, alpha: 0.20),
      ),
      // Recessed surfaces catch shadow at the top instead of light, which is
      // what sells the inversion.
      foregroundDecoration: BoxDecoration(
        borderRadius: borderRadius,
        gradient: recessed
            ? LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.18),
                  Colors.black.withValues(alpha: 0.0),
                ],
                stops: const [0.0, 0.35],
              )
            : Skeuo.gloss(alpha: 0.35, stop: 0.35),
      ),
      child: child,
    );

    if (onTap == null) return panel;
    return GestureDetector(onTap: onTap, child: panel);
  }
}
