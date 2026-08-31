import 'package:arrow_puzzle/domain/models/arrow.dart';
import 'package:arrow_puzzle/domain/models/game_state.dart';

/// Core game logic for the Arrow Escape puzzle.
///
/// An arrow can be removed only when every cell between the arrow's
/// leading edge and the corresponding board edge is completely empty.
class GameLogic {
  const GameLogic();

  /// Checks whether [arrow] can be removed from the board in [state].
  ///
  /// The arrow can slide out only if every cell from the arrow's leading
  /// tip to the board edge (in its pointing direction) is empty.
  bool canRemoveArrow(Arrow arrow, GameState state) {
    final (dr, dc) = arrow.direction.delta;

    // Find the leading edge cell of the arrow (the tip).
    // For a multi-cell arrow, the tip is at position + (length-1) steps
    // in the arrow's direction.
    final tipRow = arrow.row + dr * (arrow.length - 1);
    final tipCol = arrow.col + dc * (arrow.length - 1);

    // Check every cell from one step past the tip to the board edge.
    int checkRow = tipRow + dr;
    int checkCol = tipCol + dc;

    while (checkRow >= 0 &&
        checkRow < state.rows &&
        checkCol >= 0 &&
        checkCol < state.cols) {
      if (state.grid[checkRow][checkCol] != -1) {
        return false;
      }
      checkRow += dr;
      checkCol += dc;
    }

    return true;
  }

  /// Removes [arrow] from the board, returning a new [GameState].
  ///
  /// Does not validate whether the arrow can be removed -- call
  /// [canRemoveArrow] first.
  GameState removeArrow(Arrow arrow, GameState state) {
    return state.removeArrow(arrow);
  }

  /// Whether the level is complete (no arrows remain).
  bool isLevelComplete(GameState state) {
    return state.isComplete;
  }

  /// Returns all arrows that can currently be removed.
  List<Arrow> getRemovableArrows(GameState state) {
    return state.remainingArrows
        .where((arrow) => canRemoveArrow(arrow, state))
        .toList();
  }
}
