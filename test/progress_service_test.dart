import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:arrow_puzzle/data/models/progress_model.dart';
import 'package:arrow_puzzle/data/services/progress_service.dart';

void main() {
  group('ProgressService', () {
    test('round-trips saved progress', () async {
      SharedPreferences.setMockInitialValues({});
      final service = ProgressService();
      const progress = ProgressModel(
        completedLevelIds: {1, 2},
        highestUnlockedLevel: 3,
        bestScores: {1: 4, 2: 6},
        starRatings: {1: 3, 2: 2},
      );

      await service.saveProgress(progress);
      final loaded = await service.loadProgress();

      expect(loaded.completedLevelIds, {1, 2});
      expect(loaded.highestUnlockedLevel, 3);
      expect(loaded.bestScores, {1: 4, 2: 6});
      expect(loaded.starRatings, {1: 3, 2: 2});
    });

    test('ignores corrupted or tampered values instead of throwing', () async {
      SharedPreferences.setMockInitialValues({
        'completed_levels': ['1', 'abc', '-5'],
        'highest_unlocked': -10,
        'best_scores': '{not json',
        'star_ratings': '{"1": 99, "x": 2, "2": "3"}',
      });

      final loaded = await ProgressService().loadProgress();

      expect(loaded.completedLevelIds, {1});
      expect(loaded.highestUnlockedLevel, 1);
      expect(loaded.bestScores, isEmpty);
      expect(loaded.starRatings, {1: 3});
    });
  });
}
