
class ProgressModel {
  const ProgressModel({
    required this.completedLevelIds,
    required this.highestUnlockedLevel,
    this.bestScores = const {},
    this.starRatings = const {},
  });

  final Set<int> completedLevelIds;
  final int highestUnlockedLevel;
  final Map<int, int> bestScores;
  final Map<int, int> starRatings;

  bool isCompleted(int levelId) => completedLevelIds.contains(levelId);
  bool isUnlocked(int levelId) => levelId <= highestUnlockedLevel;
  int getStars(int levelId) => starRatings[levelId] ?? 0;
  int getBestScore(int levelId) => bestScores[levelId] ?? 0;
  int get totalStars => starRatings.values.fold(0, (sum, stars) => sum + stars);
  int get completedCount => completedLevelIds.length;

  ProgressModel completeLevel(int levelId, {int? steps, int? stars}) {
    final newCompleted = {...completedLevelIds, levelId};
    final newHighest = levelId >= highestUnlockedLevel
        ? levelId + 1
        : highestUnlockedLevel;

    final newBestScores = Map<int, int>.from(bestScores);
    if (steps != null) {
      final currentBest = bestScores[levelId];
      if (currentBest == null || steps < currentBest) {
        newBestScores[levelId] = steps;
      }
    }

    final newStarRatings = Map<int, int>.from(starRatings);
    if (stars != null) {
      final currentStars = starRatings[levelId] ?? 0;
      if (stars > currentStars) {
        newStarRatings[levelId] = stars;
      }
    }

    return ProgressModel(
      completedLevelIds: newCompleted,
      highestUnlockedLevel: newHighest,
      bestScores: newBestScores,
      starRatings: newStarRatings,
    );
  }
}
