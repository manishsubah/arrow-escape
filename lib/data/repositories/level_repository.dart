import '../../domain/models/arrow.dart';
import '../../domain/models/level.dart';
import '../../ui/core/app_colors.dart';
import '../models/level_model.dart';
import '../models/progress_model.dart';
import '../services/level_service.dart';
import '../services/progress_service.dart';

/// Single source of truth for level data and user progress.
class LevelRepository {
  LevelRepository({
    required LevelService levelService,
    required ProgressService progressService,
  })  : _levelService = levelService,
        _progressService = progressService;

  final LevelService _levelService;
  final ProgressService _progressService;

  ProgressModel? _progress;

  /// Loads user progress from storage.
  Future<ProgressModel> getProgress() async {
    _progress ??= await _progressService.loadProgress();
    return _progress!;
  }

  /// Forces a reload of progress from storage (e.g., after returning from game).
  Future<ProgressModel> refreshProgress() async {
    _progress = await _progressService.loadProgress();
    return _progress!;
  }

  /// Loads all levels as domain models.
  Future<List<Level>> getAllLevels() async {
    final models = await _levelService.loadLevels();
    return models.map(_toDomain).toList();
  }

  /// Loads a single level by ID.
  Future<Level> getLevel(int levelId) async {
    final model = await _levelService.loadLevel(levelId);
    return _toDomain(model);
  }

  /// Marks a level as completed with step count.
  /// Calculates stars: 3 = perfect (steps == solution length),
  /// 2 = near-perfect (steps <= solution + 2), 1 = completed.
  /// Returns a record with (stars, bestScore, isNewBest).
  Future<({int stars, int bestScore, bool isNewBest})> completeLevel(
    int levelId,
    int steps,
  ) async {
    final level = await getLevel(levelId);
    final solutionLength = level.solution.length;

    // Calculate stars
    int stars;
    if (steps <= solutionLength) {
      stars = 3;
    } else if (steps <= solutionLength + 2) {
      stars = 2;
    } else {
      stars = 1;
    }

    final progress = await getProgress();
    final previousBest = progress.getBestScore(levelId);
    final isNewBest = previousBest == 0 || steps < previousBest;

    _progress = progress.completeLevel(levelId, steps: steps, stars: stars);
    await _progressService.saveProgress(_progress!);

    final bestScore = _progress!.getBestScore(levelId);

    return (stars: stars, bestScore: bestScore, isNewBest: isNewBest);
  }

  /// Whether a level is unlocked.
  Future<bool> isLevelUnlocked(int levelId) async {
    final progress = await getProgress();
    return progress.isUnlocked(levelId);
  }

  /// Whether a level has been completed.
  Future<bool> isLevelCompleted(int levelId) async {
    final progress = await getProgress();
    return progress.isCompleted(levelId);
  }

  Level _toDomain(LevelModel model) {
    return Level(
      id: model.id,
      rows: model.rows,
      cols: model.cols,
      arrows: model.arrows.map(_arrowToDomain).toList(),
      solution: model.solution,
    );
  }

  Arrow _arrowToDomain(ArrowModel model) {
    return Arrow(
      id: model.id,
      row: model.row,
      col: model.col,
      direction: ArrowDirection.values.byName(model.direction),
      length: model.length,
      color: ArrowColors.fromIndex(model.colorIndex),
    );
  }
}
