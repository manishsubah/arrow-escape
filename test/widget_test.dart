import 'package:flutter_test/flutter_test.dart';

import 'package:arrow_puzzle/domain/models/arrow.dart';
import 'package:arrow_puzzle/domain/models/game_state.dart';
import 'package:arrow_puzzle/domain/use_cases/game_logic.dart';
import 'package:arrow_puzzle/ui/core/app_colors.dart';

void main() {
  group('GameLogic', () {
    const gameLogic = GameLogic();

    test('canRemoveArrow returns true when path is clear', () {
      // 3x3 grid, single arrow pointing right at (0,0)
      final arrow = Arrow(
        id: 0,
        row: 0,
        col: 0,
        direction: ArrowDirection.right,
        color: ArrowColors.palette[0],
      );
      final state = GameState.initial(rows: 3, cols: 3, arrows: [arrow]);

      expect(gameLogic.canRemoveArrow(arrow, state), isTrue);
    });

    test('canRemoveArrow returns false when path is blocked', () {
      final arrow1 = Arrow(
        id: 0,
        row: 0,
        col: 0,
        direction: ArrowDirection.right,
        color: ArrowColors.palette[0],
      );
      final arrow2 = Arrow(
        id: 1,
        row: 0,
        col: 2,
        direction: ArrowDirection.up,
        color: ArrowColors.palette[1],
      );
      final state = GameState.initial(rows: 3, cols: 3, arrows: [arrow1, arrow2]);

      // arrow1 pointing right, but arrow2 is at (0,2) blocking the path
      expect(gameLogic.canRemoveArrow(arrow1, state), isFalse);
    });

    test('removeArrow clears arrow from state', () {
      final arrow = Arrow(
        id: 0,
        row: 1,
        col: 1,
        direction: ArrowDirection.down,
        color: ArrowColors.palette[0],
      );
      final state = GameState.initial(rows: 3, cols: 3, arrows: [arrow]);
      final newState = gameLogic.removeArrow(arrow, state);

      expect(newState.remainingArrows, isEmpty);
      expect(newState.moveHistory, [0]);
      expect(newState.grid[1][1], -1);
    });

    test('isLevelComplete returns true when no arrows remain', () {
      final arrow = Arrow(
        id: 0,
        row: 0,
        col: 0,
        direction: ArrowDirection.up,
        color: ArrowColors.palette[0],
      );
      final state = GameState.initial(rows: 3, cols: 3, arrows: [arrow]);
      final afterRemoval = gameLogic.removeArrow(arrow, state);

      expect(gameLogic.isLevelComplete(afterRemoval), isTrue);
    });

    test('getRemovableArrows returns only removable arrows', () {
      // Arrow0 at (0,0) pointing right, Arrow1 at (0,2) blocking it
      // Arrow1 at (0,2) pointing up, path clear
      final arrow0 = Arrow(
        id: 0,
        row: 0,
        col: 0,
        direction: ArrowDirection.right,
        color: ArrowColors.palette[0],
      );
      final arrow1 = Arrow(
        id: 1,
        row: 0,
        col: 2,
        direction: ArrowDirection.up,
        color: ArrowColors.palette[1],
      );
      final state = GameState.initial(rows: 3, cols: 3, arrows: [arrow0, arrow1]);
      final removable = gameLogic.getRemovableArrows(state);

      expect(removable.length, 1);
      expect(removable.first.id, 1);
    });
  });
}
