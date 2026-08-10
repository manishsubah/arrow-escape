import 'arrow.dart';

/// Represents a single puzzle level.
class Level {
  const Level({
    required this.id,
    required this.rows,
    required this.cols,
    required this.arrows,
    required this.solution,
  });

  /// Level number (1-based).
  final int id;

  /// Number of rows in the grid.
  final int rows;

  /// Number of columns in the grid.
  final int cols;

  /// All arrows on the board at the start.
  final List<Arrow> arrows;

  /// Ordered list of arrow IDs representing the solution.
  final List<int> solution;

  @override
  String toString() => 'Level(id: $id, grid: ${rows}x$cols, arrows: ${arrows.length})';
}
