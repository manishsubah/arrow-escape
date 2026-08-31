import 'package:flutter/material.dart';

import 'package:arrow_puzzle/domain/models/arrow.dart';
import 'package:arrow_puzzle/domain/models/game_state.dart';
import 'package:arrow_puzzle/ui/core/skeuo.dart';
import 'package:arrow_puzzle/ui/features/game/views/widgets/arrow_widget.dart';

/// Renders the puzzle board: a wooden frame around a recessed well of carved
/// cells, with the arrow blocks resting inside it.
///
/// Uses a Stack with positioned ArrowWidgets overlaid on the well. The Stack is
/// deliberately unclipped so a removed arrow slides out over the frame and off
/// the board.
class PuzzleGrid extends StatelessWidget {
  const PuzzleGrid({
    super.key,
    required this.gameState,
    required this.removableArrows,
    required this.exitingArrow,
    required this.onArrowTap,
    this.hintArrowId,
  });

  final GameState gameState;
  final List<Arrow> removableArrows;
  final Arrow? exitingArrow;
  final void Function(Arrow) onArrowTap;
  final int? hintArrowId;

  /// Wooden frame around the recessed well.
  static const _framePad = 12.0;
  static const _frameBorder = 3.0;
  static const _frameRadius = 22.0;

  /// Total space the frame takes out of the available box, plus a little
  /// breathing room so the board never touches the screen edges.
  static const _chrome = 2 * (_framePad + _frameBorder) + 8;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth;
        final maxHeight = constraints.maxHeight;

        // Calculate cell size so the framed board fits within constraints.
        final cellSize = _calculateCellSize(maxWidth, maxHeight);
        final gridWidth = cellSize * gameState.cols;
        final gridHeight = cellSize * gameState.rows;

        return Center(
          child: Container(
            padding: const EdgeInsets.all(_framePad),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(_frameRadius),
              gradient: Skeuo.woodGradient,
              border: Border.all(color: Skeuo.woodEdge, width: _frameBorder),
              boxShadow: Skeuo.lift(y: 12, blur: 26, alpha: 0.30),
            ),
            child: SizedBox(
              width: gridWidth,
              height: gridHeight,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // Recessed well with carved cells
                  _BoardWell(
                    rows: gameState.rows,
                    cols: gameState.cols,
                    cellSize: cellSize,
                  ),
                  // Arrows
                  ...gameState.remainingArrows.map((arrow) {
                    final isExiting = exitingArrow?.id == arrow.id;
                    final isRemovable =
                        removableArrows.any((a) => a.id == arrow.id);
                    final isHinted = hintArrowId == arrow.id;

                    return _AnimatedArrow(
                      key: ValueKey(arrow.id),
                      arrow: arrow,
                      cellSize: cellSize,
                      gridRows: gameState.rows,
                      gridCols: gameState.cols,
                      isExiting: isExiting,
                      isRemovable: isRemovable,
                      isHinted: isHinted,
                      onTap: () => onArrowTap(arrow),
                    );
                  }),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  double _calculateCellSize(double maxWidth, double maxHeight) {
    final horizontalCellSize = (maxWidth - _chrome) / gameState.cols;
    final verticalCellSize = (maxHeight - _chrome) / gameState.rows;
    return horizontalCellSize < verticalCellSize
        ? horizontalCellSize
        : verticalCellSize;
  }
}

/// Draws the sunken well the arrow blocks sit in, with one carved dimple per
/// cell.
class _BoardWell extends StatelessWidget {
  const _BoardWell({
    required this.rows,
    required this.cols,
    required this.cellSize,
  });

  final int rows;
  final int cols;
  final double cellSize;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(cellSize * cols, cellSize * rows),
      painter: _BoardWellPainter(rows: rows, cols: cols, cellSize: cellSize),
    );
  }
}

class _BoardWellPainter extends CustomPainter {
  _BoardWellPainter({
    required this.rows,
    required this.cols,
    required this.cellSize,
  });

  final int rows;
  final int cols;
  final double cellSize;

  @override
  void paint(Canvas canvas, Size size) {
    final wellRR = RRect.fromRectAndRadius(
      Offset.zero & size,
      const Radius.circular(10),
    );

    canvas.drawRRect(wellRR, Paint()..color = Skeuo.woodInset);

    // Inset shadow: a thick blurred stroke clipped to the well only bleeds
    // inward, which is how you fake an inner shadow on a canvas.
    canvas.save();
    canvas.clipRRect(wellRR);
    canvas.drawRRect(
      wellRR.deflate(2),
      Paint()
        ..color = Colors.black.withValues(alpha: 0.32)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 9
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
    );
    canvas.restore();

    _paintCells(canvas);
  }

  void _paintCells(Canvas canvas) {
    final dimpleInset = cellSize * 0.07;
    final dimpleRadius = Radius.circular(cellSize * 0.18);
    final topShade = Skeuo.darken(Skeuo.woodInset, 0.24);
    final bottomShade = Skeuo.darken(Skeuo.woodInset, 0.02);
    final catchLight = Skeuo.lighten(
      Skeuo.woodInset,
      0.22,
    ).withValues(alpha: 0.45);
    final rimShade = Colors.black.withValues(alpha: 0.28);

    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        final rect = Rect.fromLTWH(
          c * cellSize,
          r * cellSize,
          cellSize,
          cellSize,
        ).deflate(dimpleInset);
        final rrect = RRect.fromRectAndRadius(rect, dimpleRadius);

        // Dark at the top, light at the bottom reads as a scooped hollow.
        canvas.drawRRect(
          rrect,
          Paint()
            ..shader = LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [topShade, bottomShade],
            ).createShader(rect),
        );

        // Clipping the two offset strokes keeps each one on a single inner
        // edge: shadow under the top rim, light along the bottom rim.
        canvas.save();
        canvas.clipRRect(rrect);
        canvas.drawRRect(
          rrect.shift(const Offset(0, 1.5)),
          Paint()
            ..color = rimShade
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.8,
        );
        canvas.drawRRect(
          rrect.shift(const Offset(0, -1.5)),
          Paint()
            ..color = catchLight
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.6,
        );
        canvas.restore();
      }
    }
  }

  @override
  bool shouldRepaint(_BoardWellPainter oldDelegate) =>
      rows != oldDelegate.rows ||
      cols != oldDelegate.cols ||
      cellSize != oldDelegate.cellSize;
}

/// Wraps an ArrowWidget with exit animation.
class _AnimatedArrow extends StatefulWidget {
  const _AnimatedArrow({
    super.key,
    required this.arrow,
    required this.cellSize,
    required this.gridRows,
    required this.gridCols,
    required this.isExiting,
    required this.isRemovable,
    required this.isHinted,
    required this.onTap,
  });

  final Arrow arrow;
  final double cellSize;
  final int gridRows;
  final int gridCols;
  final bool isExiting;
  final bool isRemovable;
  final bool isHinted;
  final VoidCallback onTap;

  @override
  State<_AnimatedArrow> createState() => _AnimatedArrowState();
}

class _AnimatedArrowState extends State<_AnimatedArrow>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 350),
      vsync: this,
    );
    _setupAnimations();
  }

  void _setupAnimations() {
    final (dr, dc) = widget.arrow.direction.delta;
    // Calculate how far the arrow needs to slide to exit the board.
    final gridWidth = widget.cellSize * widget.gridCols;
    final gridHeight = widget.cellSize * widget.gridRows;
    final exitOffset = Offset(
      dc * gridWidth,
      dr * gridHeight,
    );

    _slideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: exitOffset,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInCubic,
    ));

    _fadeAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.6, 1.0),
      ),
    );
  }

  @override
  void didUpdateWidget(_AnimatedArrow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isExiting && !oldWidget.isExiting) {
      _setupAnimations();
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final left = widget.arrow.col * widget.cellSize;
    final top = widget.arrow.row * widget.cellSize;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Positioned(
          left: left + _slideAnimation.value.dx,
          top: top + _slideAnimation.value.dy,
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: ArrowWidget(
              arrow: widget.arrow,
              cellSize: widget.cellSize,
              isRemovable: widget.isRemovable,
              isHinted: widget.isHinted,
              onTap: widget.onTap,
            ),
          ),
        );
      },
    );
  }
}
