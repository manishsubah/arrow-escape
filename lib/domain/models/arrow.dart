import 'dart:ui';

/// Direction an arrow points and can move toward.
enum ArrowDirection {
  up,
  down,
  left,
  right;

  /// Returns the row/col delta for one step in this direction.
  (int dr, int dc) get delta => switch (this) {
    ArrowDirection.up => (-1, 0),
    ArrowDirection.down => (1, 0),
    ArrowDirection.left => (0, -1),
    ArrowDirection.right => (0, 1),
  };

  /// Returns the rotation angle in radians for rendering.
  double get rotationAngle => switch (this) {
    ArrowDirection.up => 0.0,
    ArrowDirection.down => 3.14159,
    ArrowDirection.left => -1.5708,
    ArrowDirection.right => 1.5708,
  };
}

/// Represents a single arrow on the puzzle grid.
class Arrow {
  const Arrow({
    required this.id,
    required this.row,
    required this.col,
    required this.direction,
    this.length = 1,
    required this.color,
  });

  /// Unique identifier within a level.
  final int id;

  /// Top-left row of this arrow on the grid (0-indexed).
  final int row;

  /// Top-left column of this arrow on the grid (0-indexed).
  final int col;

  /// Direction the arrow points (and will slide toward).
  final ArrowDirection direction;

  /// Number of grid cells this arrow occupies along its direction.
  final int length;

  /// Display color of the arrow.
  final Color color;

  /// Returns all grid cells (row, col) occupied by this arrow.
  List<(int, int)> get occupiedCells {
    final (dr, dc) = direction.delta;
    return List.generate(length, (i) => (row + dr * i, col + dc * i));
  }

  Arrow copyWith({
    int? id,
    int? row,
    int? col,
    ArrowDirection? direction,
    int? length,
    Color? color,
  }) {
    return Arrow(
      id: id ?? this.id,
      row: row ?? this.row,
      col: col ?? this.col,
      direction: direction ?? this.direction,
      length: length ?? this.length,
      color: color ?? this.color,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Arrow && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'Arrow(id: $id, pos: ($row,$col), dir: $direction, len: $length)';
}
