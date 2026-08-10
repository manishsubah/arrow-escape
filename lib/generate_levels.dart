// Level generator script for Arrow Escape.
// Run with: dart run lib/generate_levels.dart
// Generates assets/data/levels.json with 100 solvable levels.

import 'dart:convert';
import 'dart:io';
import 'dart:math';

void main() {
  final levels = <Map<String, dynamic>>[];
  final random = Random(42); // Fixed seed for reproducibility

  for (int levelId = 1; levelId <= 100; levelId++) {
    final level = _generateLevel(levelId, random);
    levels.add(level);
  }

  final file = File('assets/data/levels.json');
  file.parent.createSync(recursive: true);
  file.writeAsStringSync(
    const JsonEncoder.withIndent('  ').convert(levels),
  );
  // ignore: avoid_print
  print('Generated ${levels.length} levels to ${file.path}');
}

Map<String, dynamic> _generateLevel(int levelId, Random random) {
  // Grid size ramps with difficulty
  int rows, cols;
  if (levelId <= 20) {
    rows = 3 + (levelId > 10 ? 1 : 0);
    cols = 3 + (levelId > 10 ? 1 : 0);
  } else if (levelId <= 50) {
    rows = 4 + (levelId > 35 ? 1 : 0);
    cols = 4 + (levelId > 35 ? 1 : 0);
  } else if (levelId <= 80) {
    rows = 5 + (levelId > 65 ? 1 : 0);
    cols = 5 + (levelId > 65 ? 1 : 0);
  } else {
    rows = 6 + (levelId > 90 ? 1 : 0);
    cols = 6 + (levelId > 90 ? 1 : 0);
  }

  // Number of arrows scales with level
  int numArrows;
  if (levelId <= 10) {
    numArrows = 2 + (levelId ~/ 4);
  } else if (levelId <= 30) {
    numArrows = 3 + (levelId ~/ 8);
  } else if (levelId <= 60) {
    numArrows = 4 + (levelId ~/ 12);
  } else {
    numArrows = 5 + (levelId ~/ 15);
  }
  numArrows = numArrows.clamp(2, 12);

  // Generate a solvable level by placing arrows in reverse solution order.
  // We start with an empty grid and place arrows one by one, ensuring each
  // can exit when it's its turn to be removed.
  final arrows = <Map<String, dynamic>>[];
  final solution = <int>[];
  final grid = List.generate(rows, (_) => List.filled(cols, -1));
  final directions = ['up', 'down', 'left', 'right'];

  // Place arrows in the order they'll be LAST to be removed (reverse solution).
  // Arrow placed first = removed last. Arrow placed last = removed first.
  int arrowId = 0;
  int attempts = 0;
  final maxAttempts = 500;

  while (arrows.length < numArrows && attempts < maxAttempts) {
    attempts++;
    final dir = directions[random.nextInt(4)];
    final length = 1; // Keep it simple with 1-cell arrows for reliability
    final row = random.nextInt(rows);
    final col = random.nextInt(cols);

    // Check cell is free
    if (grid[row][col] != -1) continue;

    // Check that the arrow CAN exit (path to edge is clear of arrows placed BEFORE it).
    // Arrows placed before this one will be removed AFTER it, so they block.
    // But since we're building the solution, we need the arrow to be removable
    // when all subsequently-placed arrows have already been removed.
    // So we check: path from arrow to edge is clear in the CURRENT grid state.
    if (!_canExit(row, col, dir, grid, rows, cols)) continue;

    final id = arrowId++;
    grid[row][col] = id;
    arrows.add({
      'id': id,
      'row': row,
      'col': col,
      'direction': dir,
      'length': length,
      'colorIndex': id % 5,
    });
    // This arrow will be the NEXT one removed after all subsequently-placed arrows.
    solution.insert(0, id);
  }

  // If we couldn't place enough arrows, pad with what we have
  return {
    'id': levelId,
    'rows': rows,
    'cols': cols,
    'arrows': arrows,
    'solution': solution,
  };
}

bool _canExit(int row, int col, String direction, List<List<int>> grid, int rows, int cols) {
  int dr = 0, dc = 0;
  switch (direction) {
    case 'up':    dr = -1; break;
    case 'down':  dr = 1;  break;
    case 'left':  dc = -1; break;
    case 'right': dc = 1;  break;
  }

  int r = row + dr;
  int c = col + dc;

  while (r >= 0 && r < rows && c >= 0 && c < cols) {
    if (grid[r][c] != -1) return false;
    r += dr;
    c += dc;
  }
  return true;
}
