import 'package:flutter/material.dart';

import '../../../../../domain/models/arrow.dart';
import '../../../../../domain/models/game_state.dart';
import 'arrow_widget.dart';

/// Renders the puzzle grid with arrows.
///
/// Uses a Stack with positioned ArrowWidgets overlaid on a grid background.
/// Arrows animate out in their direction when removed.
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

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth;
        final maxHeight = constraints.maxHeight;

        // Calculate cell size to fit the grid within constraints.
        final cellSize = _calculateCellSize(maxWidth, maxHeight);
        final gridWidth = cellSize * gameState.cols;
        final gridHeight = cellSize * gameState.rows;

        return Center(
          child: SizedBox(
            width: gridWidth,
            height: gridHeight,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // Grid background
                _GridBackground(
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
        );
      },
    );
  }

  double _calculateCellSize(double maxWidth, double maxHeight) {
    final horizontalCellSize = (maxWidth - 32) / gameState.cols;
    final verticalCellSize = (maxHeight - 32) / gameState.rows;
    return horizontalCellSize < verticalCellSize
        ? horizontalCellSize
        : verticalCellSize;
  }
}

/// Draws the grid lines and cell backgrounds.
class _GridBackground extends StatelessWidget {
  const _GridBackground({
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
      painter: _GridPainter(rows: rows, cols: cols, cellSize: cellSize),
    );
  }
}

class _GridPainter extends CustomPainter {
  _GridPainter({
    required this.rows,
    required this.cols,
    required this.cellSize,
  });

  final int rows;
  final int cols;
  final double cellSize;

  @override
  void paint(Canvas canvas, Size size) {
    // Cell background
    final cellPaint = Paint()
      ..color = const Color(0xFF1E293B).withValues(alpha: 0.6);

    final borderPaint = Paint()
      ..color = const Color(0xFF64748B).withValues(alpha: 0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        final rect = Rect.fromLTWH(
          c * cellSize,
          r * cellSize,
          cellSize,
          cellSize,
        );
        final rrect = RRect.fromRectAndRadius(rect.deflate(1), const Radius.circular(4));
        canvas.drawRRect(rrect, cellPaint);
        canvas.drawRRect(rrect, borderPaint);
      }
    }
  }

  @override
  bool shouldRepaint(_GridPainter oldDelegate) =>
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
