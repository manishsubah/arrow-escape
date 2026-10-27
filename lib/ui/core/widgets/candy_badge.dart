import 'package:flutter/material.dart';

import 'package:arrow_puzzle/ui/core/skeuo.dart';

/// A small glossy molded chip holding an icon — the raised-surface recipe at
/// badge scale.
class CandyBadge extends StatelessWidget {
  const CandyBadge({
    super.key,
    required this.icon,
    required this.color,
    this.size = 44,
  });

  final IconData icon;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(size * 0.32);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: radius,
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Skeuo.faceOf(color), color],
        ),
        border: Border.all(color: Skeuo.lipOf(color), width: 2),
        boxShadow: Skeuo.lift(y: 4, blur: 8, alpha: 0.18),
      ),
      foregroundDecoration: BoxDecoration(
        borderRadius: radius,
        gradient: Skeuo.gloss(alpha: 0.42, stop: 0.5),
      ),
      child: Icon(
        icon,
        color: Skeuo.onCandy,
        size: size * 0.5,
        shadows: Skeuo.embossedText,
      ),
    );
  }
}
