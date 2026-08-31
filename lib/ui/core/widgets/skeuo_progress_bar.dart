import 'package:flutter/material.dart';

import 'package:arrow_puzzle/ui/core/skeuo.dart';

/// A progress meter built as a carved track with a glossy candy fill.
///
/// The track is shaded dark-at-the-top so it reads as a groove cut into the
/// surface; the fill is a raised candy bar with its own sheen. The fill
/// animates whenever [value] changes, so progress arriving asynchronously
/// (loaded from storage) slides in rather than snapping.
class SkeuoProgressBar extends StatelessWidget {
  const SkeuoProgressBar({
    super.key,
    required this.value,
    this.color = Skeuo.green,
    this.height = 16,
  });

  /// Fill fraction, 0..1. Values outside the range are clamped.
  final double value;

  /// Candy color of the fill bar.
  final Color color;

  final double height;

  @override
  Widget build(BuildContext context) {
    const borderWidth = 2.0;
    final innerRadius = Radius.circular((height - borderWidth * 2) / 2);

    return Container(
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(height / 2),
        border: Border.all(color: Skeuo.cardEdge, width: borderWidth),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Skeuo.darken(Skeuo.card, 0.26), Skeuo.darken(Skeuo.card, 0.10)],
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.all(innerRadius),
        child: Align(
          alignment: Alignment.centerLeft,
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: value.clamp(0.0, 1.0)),
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeOutCubic,
            builder: (context, fraction, _) {
              // A zero-width fill would still paint its rounded caps, so hide
              // it entirely at empty.
              if (fraction <= 0) return const SizedBox.shrink();
              return FractionallySizedBox(
                widthFactor: fraction,
                heightFactor: 1,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(innerRadius),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Skeuo.faceOf(color), color],
                    ),
                  ),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(innerRadius),
                      gradient: Skeuo.gloss(alpha: 0.5, stop: 0.55),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
