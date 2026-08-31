import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:arrow_puzzle/data/repositories/level_repository.dart';
import 'package:arrow_puzzle/data/services/audio_service.dart';
import 'package:arrow_puzzle/domain/models/arrow.dart';
import 'package:arrow_puzzle/domain/models/game_state.dart';
import 'package:arrow_puzzle/domain/models/level.dart';
import 'package:arrow_puzzle/domain/use_cases/game_logic.dart';

/// Manages the active game state for a single level.
class GameViewModel extends ChangeNotifier {
  GameViewModel({
    required LevelRepository levelRepository,
    required AudioService audioService,
    required int levelId,
    bool hapticsEnabled = true,
  })  : _levelRepository = levelRepository,
        _audioService = audioService,
        _levelId = levelId,
        _hapticsEnabled = hapticsEnabled;

  final LevelRepository _levelRepository;
  final AudioService _audioService;
  final int _levelId;
  final bool _hapticsEnabled;
  final GameLogic _gameLogic = const GameLogic();

  Level? _level;
  Level? get level => _level;

  GameState? _gameState;
  GameState? get gameState => _gameState;

  /// History stack for undo support.
  final List<GameState> _stateHistory = [];

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  bool _isAnimating = false;
  bool get isAnimating => _isAnimating;

  /// The arrow currently being animated out (null if none).
  Arrow? _exitingArrow;
  Arrow? get exitingArrow => _exitingArrow;

  bool get canUndo => _stateHistory.isNotEmpty;

  int get levelId => _levelId;

  // --- Hearts system ---
  static const int maxHearts = 3;
  int _hearts = maxHearts;
  int get hearts => _hearts;
  bool get isGameOver => _hearts <= 0;

  /// Total arrows at the start of the level.
  int get totalArrows => _level?.arrows.length ?? 0;

  /// Arrows remaining on the board.
  int get remainingArrows => _gameState?.remainingArrows.length ?? 0;

  // --- Level completion result ---
  int? _stars;
  int? get stars => _stars;
  int? _bestScore;
  int? get bestScore => _bestScore;
  bool _isNewBest = false;
  bool get isNewBest => _isNewBest;

  /// Loads the level and initializes the game state.
  Future<void> load() async {
    _isLoading = true;
    notifyListeners();

    try {
      _level = await _levelRepository.getLevel(_levelId);
      _resetState();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Attempts to remove [arrow] from the board.
  /// Returns true if the arrow was successfully tapped.
  Future<bool> tapArrow(Arrow arrow) async {
    if (_gameState == null || _isAnimating || isGameOver) return false;

    if (!_gameLogic.canRemoveArrow(arrow, _gameState!)) {
      // Wrong tap -- lose a heart
      _hearts--;
      if (_hapticsEnabled) {
        HapticFeedback.heavyImpact();
      }
      _audioService.playTap();
      notifyListeners();
      return false;
    }

    // Valid tap -- trigger exit animation
    if (_hapticsEnabled) {
      HapticFeedback.mediumImpact();
    }
    _audioService.playSlide();

    _isAnimating = true;
    _exitingArrow = arrow;
    notifyListeners();

    // Wait for exit animation to complete
    await Future.delayed(const Duration(milliseconds: 400));

    // Update state
    _stateHistory.add(_gameState!);
    _gameState = _gameLogic.removeArrow(arrow, _gameState!);
    _exitingArrow = null;
    _isAnimating = false;
    notifyListeners();

    // Check for level completion
    if (_gameLogic.isLevelComplete(_gameState!)) {
      _audioService.playComplete();
      final steps = _gameState!.moveCount;
      final result = await _levelRepository.completeLevel(_levelId, steps);
      _stars = result.stars;
      _bestScore = result.bestScore;
      _isNewBest = result.isNewBest;
      notifyListeners();
    }

    return true;
  }

  /// Undoes the last move.
  void undo() {
    if (_stateHistory.isEmpty || _isAnimating) return;
    _gameState = _stateHistory.removeLast();
    notifyListeners();
  }

  /// Restarts the current level (resets hearts too).
  void restart() {
    if (_isAnimating) return;
    _stateHistory.clear();
    _hearts = maxHearts;
    _stars = null;
    _bestScore = null;
    _isNewBest = false;
    _resetState();
    notifyListeners();
  }

  /// Shows which arrow should be removed next (hint).
  /// Returns the arrow ID of the next correct move, or null.
  Arrow? getHintArrow() {
    if (_gameState == null || _level == null) return null;
    final movesMade = _gameState!.moveCount;
    if (movesMade >= _level!.solution.length) return null;
    final nextArrowId = _level!.solution[movesMade];
    try {
      return _gameState!.remainingArrows.firstWhere((a) => a.id == nextArrowId);
    } catch (_) {
      return null;
    }
  }

  /// Returns which arrows are currently removable.
  List<Arrow> get removableArrows {
    if (_gameState == null) return [];
    return _gameLogic.getRemovableArrows(_gameState!);
  }

  void _resetState() {
    if (_level == null) return;
    _gameState = GameState.initial(
      rows: _level!.rows,
      cols: _level!.cols,
      arrows: _level!.arrows,
    );
  }
}
