import 'arrow.dart';

/// Immutable snapshot of the current game board state.
class GameState {
  const GameState({
    required this.rows,
    required this.cols,
    required this.remainingArrows,
    required this.moveHistory,
    required this.grid,
  });

  /// Grid dimensions.
  final int rows;
  final int cols;

  /// Arrows still on the board.
  final List<Arrow> remainingArrows;

  /// Ordered list of arrow IDs removed so far.
  final List<int> moveHistory;

  /// 2D grid: each cell holds the arrow ID occupying it, or -1 if empty.
  final List<List<int>> grid;

  /// Whether the level is complete (all arrows removed).
  bool get isComplete => remainingArrows.isEmpty;

  /// Number of moves made so far.
  int get moveCount => moveHistory.length;

  /// Creates the initial game state from a list of arrows.
  factory GameState.initial({
    required int rows,
    required int cols,
    required List<Arrow> arrows,
  }) {
    final grid = List.generate(rows, (_) => List.filled(cols, -1));
    for (final arrow in arrows) {
      for (final (r, c) in arrow.occupiedCells) {
        grid[r][c] = arrow.id;
      }
    }
    return GameState(
      rows: rows,
      cols: cols,
      remainingArrows: List.unmodifiable(arrows),
      moveHistory: const [],
      grid: grid,
    );
  }

  /// Returns a new GameState with the given arrow removed.
  GameState removeArrow(Arrow arrow) {
    final newGrid = List.generate(rows, (r) => List<int>.from(grid[r]));
    for (final (r, c) in arrow.occupiedCells) {
      newGrid[r][c] = -1;
    }
    return GameState(
      rows: rows,
      cols: cols,
      remainingArrows:
          List.unmodifiable(remainingArrows.where((a) => a.id != arrow.id)),
      moveHistory: List.unmodifiable([...moveHistory, arrow.id]),
      grid: newGrid,
    );
  }

  @override
  String toString() =>
      'GameState(remaining: ${remainingArrows.length}, moves: $moveCount)';
}
