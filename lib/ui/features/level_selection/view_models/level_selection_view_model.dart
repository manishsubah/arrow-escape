import 'package:flutter/material.dart';

import '../../../../data/repositories/level_repository.dart';
import '../../../../data/models/progress_model.dart';

/// Manages level list state and progress data.
class LevelSelectionViewModel extends ChangeNotifier {
  LevelSelectionViewModel({required LevelRepository levelRepository})
      : _levelRepository = levelRepository;

  final LevelRepository _levelRepository;

  int _totalLevels = 100;
  int get totalLevels => _totalLevels;

  ProgressModel? _progress;
  bool _isLoading = true;
  bool get isLoading => _isLoading;

  /// Loads progress data.
  Future<void> load() async {
    _isLoading = true;
    notifyListeners();

    try {
      _progress = await _levelRepository.refreshProgress();
      final levels = await _levelRepository.getAllLevels();
      _totalLevels = levels.length;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  int get completedCount => _progress?.completedCount ?? 0;

  int get totalStars => _progress?.totalStars ?? 0;

  double get completionPercent =>
      _totalLevels == 0 ? 0 : (completedCount / _totalLevels) * 100;

  int getStars(int levelId) => _progress?.getStars(levelId) ?? 0;

  /// Whether the level with [levelId] is unlocked.
  bool isUnlocked(int levelId) {
    return _progress?.isUnlocked(levelId) ?? (levelId == 1);
  }

  /// Whether the level with [levelId] has been completed.
  bool isCompleted(int levelId) {
    return _progress?.isCompleted(levelId) ?? false;
  }
}
