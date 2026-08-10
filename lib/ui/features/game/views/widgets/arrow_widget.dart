import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../../../../../domain/models/arrow.dart';

/// Renders a single arrow on the puzzle grid.
///
/// Displays a colored rounded rectangle with a pointed tip in the arrow's
/// direction. Supports tap interaction and exit animation.
class ArrowWidget extends StatelessWidget {
  const ArrowWidget({
    super.key,
    required this.arrow,
    required this.cellSize,
    required this.isRemovable,
    required this.onTap,
    this.isHinted = false,
  });

  final Arrow arrow;
  final double cellSize;
  final bool isRemovable;
  final bool isHinted;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    // Determine the widget dimensions based on arrow direction and length.
    final bool isHorizontal =
        arrow.direction == ArrowDirection.left ||
        arrow.direction == ArrowDirection.right;
    final double width =
        isHorizontal ? cellSize * arrow.length : cellSize;
    final double height =
        isHorizontal ? cellSize : cellSize * arrow.length;

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: width,
        height: height,
        child: AnimatedScale(
          scale: isHinted ? 1.08 : (isRemovable ? 1.0 : 0.92),
          duration: const Duration(milliseconds: 300),
          child: CustomPaint(
            painter: _ArrowPainter(
              color: arrow.color,
              direction: arrow.direction,
              isRemovable: isRemovable,
              isHinted: isHinted,
            ),
          ),
        ),
      ),
    );
  }
}

class _ArrowPainter extends CustomPainter {
  _ArrowPainter({
    required this.color,
    required this.direction,
    required this.isRemovable,
    required this.isHinted,
  });

  final Color color;
  final ArrowDirection direction;
  final bool isRemovable;
  final bool isHinted;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = isRemovable || isHinted
          ? color
          : color.withValues(alpha: 0.5)
      ..style = PaintingStyle.fill;

    final glowPaint = Paint()
      ..color = color.withValues(alpha: isRemovable || isHinted ? 0.3 : 0.0)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(8));

    if (isHinted) {
      final hintBorderPaint = Paint()
        ..color = const Color(0xFFF59E0B)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3;
      canvas.drawRRect(rrect.inflate(3), hintBorderPaint);
      final hintGlow = Paint()
        ..color = const Color(0xFFF59E0B).withValues(alpha: 0.4)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
      canvas.drawRRect(rrect.inflate(4), hintGlow);
    }

    if (isRemovable || isHinted) {
      canvas.drawRRect(rrect.inflate(2), glowPaint);
    }

    canvas.drawRRect(rrect, paint);

    _drawArrowIndicator(canvas, size);
  }

  void _drawArrowIndicator(Canvas canvas, Size size) {
    final indicatorPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.9)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final cx = size.width / 2;
    final cy = size.height / 2;
    final arrowSize = math.min(size.width, size.height) * 0.3;

    canvas.save();
    canvas.translate(cx, cy);

    // Rotate based on direction
    double angle = switch (direction) {
      ArrowDirection.up => 0,
      ArrowDirection.right => math.pi / 2,
      ArrowDirection.down => math.pi,
      ArrowDirection.left => -math.pi / 2,
    };
    canvas.rotate(angle);

    // Draw upward-pointing arrow (then rotated)
    final path = Path()
      ..moveTo(-arrowSize * 0.5, arrowSize * 0.3)
      ..lineTo(0, -arrowSize * 0.4)
      ..lineTo(arrowSize * 0.5, arrowSize * 0.3);

    canvas.drawPath(path, indicatorPaint);

    // Draw arrow shaft
    canvas.drawLine(
      Offset(0, -arrowSize * 0.35),
      Offset(0, arrowSize * 0.4),
      indicatorPaint,
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(_ArrowPainter oldDelegate) =>
      color != oldDelegate.color ||
      direction != oldDelegate.direction ||
      isRemovable != oldDelegate.isRemovable ||
      isHinted != oldDelegate.isHinted;
}
