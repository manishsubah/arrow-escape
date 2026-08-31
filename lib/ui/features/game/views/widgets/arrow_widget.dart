import 'dart:math' as math;
import 'package:flutter/material.dart';

import 'package:arrow_puzzle/domain/models/arrow.dart';
import 'package:arrow_puzzle/ui/core/skeuo.dart';

/// Renders a single arrow on the puzzle grid as a glossy candy block.
///
/// Each arrow is a molded plastic piece: a rounded body sitting on a darker
/// base lip, a highlight along the top, a dark molded edge and an embossed
/// white arrow glyph running along the direction it will slide. Blocks that
/// cannot move yet are drained of color so the board reads at a glance;
/// hinted blocks get a gold ring.
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
    final double width = isHorizontal ? cellSize * arrow.length : cellSize;
    final double height = isHorizontal ? cellSize : cellSize * arrow.length;

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: width,
        height: height,
        child: AnimatedScale(
          scale: isHinted ? 1.08 : (isRemovable ? 1.0 : 0.94),
          duration: const Duration(milliseconds: 300),
          child: CustomPaint(
            painter: _ArrowBlockPainter(
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

/// Paints one arrow block: shadow, base lip, glossy face, molded edge, glyph.
class _ArrowBlockPainter extends CustomPainter {
  _ArrowBlockPainter({
    required this.color,
    required this.direction,
    required this.isRemovable,
    required this.isHinted,
  });

  final Color color;
  final ArrowDirection direction;
  final bool isRemovable;
  final bool isHinted;

  /// Gap around the block as a fraction of the short edge, so neighbouring
  /// pieces don't visually fuse.
  static const _insetRatio = 0.06;

  /// Depth of the base lip under the face, as a fraction of the short edge.
  static const _lipRatio = 0.11;

  @override
  void paint(Canvas canvas, Size size) {
    final active = isRemovable || isHinted;
    final base = active ? color : Skeuo.desaturate(color, 0.60);

    final short = math.min(size.width, size.height);
    final inset = short * _insetRatio;
    final lip = short * _lipRatio;

    final body = Rect.fromLTWH(
      inset,
      inset,
      size.width - inset * 2,
      math.max(size.height - inset * 2 - lip, short * 0.3),
    );
    final cornerRadius = Radius.circular(
      math.min(body.width, body.height) * 0.28,
    );
    final bodyRR = RRect.fromRectAndRadius(body, cornerRadius);

    // 1. Contact shadow on the board.
    canvas.drawRRect(
      bodyRR.shift(Offset(0, lip * 0.8)),
      Paint()
        ..color = Colors.black.withValues(alpha: active ? 0.28 : 0.16)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, short * 0.06),
    );

    // 2. The darker base the face sits on.
    canvas.drawRRect(
      bodyRR.shift(Offset(0, lip)),
      Paint()..color = Skeuo.lipOf(base),
    );

    // 3. Face, shaded light-to-dark down the block.
    canvas.drawRRect(
      bodyRR,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Skeuo.faceOf(base), base],
        ).createShader(body),
    );

    // 4. Gloss along the top — the single strongest cue that this is plastic.
    if (active) {
      canvas.save();
      canvas.clipRRect(bodyRR);
      final glossRect = Rect.fromLTWH(
        body.left,
        body.top,
        body.width,
        body.height * 0.5,
      );
      canvas.drawRect(
        glossRect,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white.withValues(alpha: 0.50),
              Colors.white.withValues(alpha: 0.0),
            ],
          ).createShader(glossRect),
      );
      canvas.restore();
    }

    // 5. Molded outer edge.
    canvas.drawRRect(
      bodyRR,
      Paint()
        ..color = Skeuo.darken(base, 0.42).withValues(alpha: 0.7)
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(1.2, short * 0.035),
    );

    _drawGlyph(canvas, body, active);

    // 6. Hint ring, painted last so nothing overlaps it.
    if (isHinted) {
      final ring = bodyRR.inflate(inset * 0.5);
      canvas.drawRRect(
        ring,
        Paint()
          ..color = Skeuo.star.withValues(alpha: 0.45)
          ..style = PaintingStyle.stroke
          ..strokeWidth = short * 0.10
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, short * 0.07),
      );
      canvas.drawRRect(
        ring,
        Paint()
          ..color = Skeuo.star
          ..style = PaintingStyle.stroke
          ..strokeWidth = math.max(2.0, short * 0.045),
      );
    }
  }

  /// Draws the embossed arrow glyph: a shaft running the length of the block
  /// with a head at the leading tip.
  void _drawGlyph(Canvas canvas, Rect body, bool active) {
    final isHorizontal =
        direction == ArrowDirection.left || direction == ArrowDirection.right;
    // Extent along the direction of travel vs. across it.
    final len = isHorizontal ? body.width : body.height;
    final cross = isHorizontal ? body.height : body.width;

    final angle = switch (direction) {
      ArrowDirection.up => 0.0,
      ArrowDirection.right => math.pi / 2,
      ArrowDirection.down => math.pi,
      ArrowDirection.left => -math.pi / 2,
    };

    canvas.save();
    canvas.translate(body.center.dx, body.center.dy);
    canvas.rotate(angle);

    // Local space after rotation: the block runs along y, tip toward -y.
    final pad = cross * 0.16;
    final headW = cross * 0.52;
    final headH = cross * 0.38;
    final shaftW = cross * 0.18;
    final tipY = -len / 2 + pad;
    final tailY = len / 2 - pad;
    final shoulderY = math.min(tipY + headH, tailY - shaftW * 0.2);

    final path = Path()
      ..moveTo(0, tipY)
      ..lineTo(headW / 2, shoulderY)
      ..lineTo(shaftW / 2, shoulderY)
      ..lineTo(shaftW / 2, tailY)
      ..lineTo(-shaftW / 2, tailY)
      ..lineTo(-shaftW / 2, shoulderY)
      ..lineTo(-headW / 2, shoulderY)
      ..close();

    // Stroking the same path with round joins softens every corner, which is
    // what keeps the glyph reading as a molded shape rather than cut vinyl.
    final roundWidth = cross * 0.07;

    void drawShape(Color color, Offset offset) {
      final shifted = path.shift(offset);
      canvas.drawPath(shifted, Paint()..color = color);
      canvas.drawPath(
        shifted,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = roundWidth
          ..strokeJoin = StrokeJoin.round
          ..strokeCap = StrokeCap.round,
      );
    }

    // Emboss: a dark copy pushed down, then the white face on top.
    drawShape(
      Colors.black.withValues(alpha: active ? 0.20 : 0.12),
      Offset(0, cross * 0.05),
    );
    drawShape(Colors.white.withValues(alpha: active ? 0.95 : 0.55), Offset.zero);

    canvas.restore();
  }

  @override
  bool shouldRepaint(_ArrowBlockPainter oldDelegate) =>
      color != oldDelegate.color ||
      direction != oldDelegate.direction ||
      isRemovable != oldDelegate.isRemovable ||
      isHinted != oldDelegate.isHinted;
}
