import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/progress_model.dart';

/// Persists and retrieves level progress using SharedPreferences.
class ProgressService {
  static const _completedKey = 'completed_levels';
  static const _highestKey = 'highest_unlocked';
  static const _bestScoresKey = 'best_scores';
  static const _starRatingsKey = 'star_ratings';

  /// Loads progress from local storage.
  Future<ProgressModel> loadProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final completedList = prefs.getStringList(_completedKey) ?? [];
    final highest = prefs.getInt(_highestKey) ?? 1;

    // Load best scores map
    final bestScoresJson = prefs.getString(_bestScoresKey);
    Map<int, int> bestScores = {};
    if (bestScoresJson != null) {
      final decoded = json.decode(bestScoresJson) as Map<String, dynamic>;
      bestScores = decoded.map((k, v) => MapEntry(int.parse(k), v as int));
    }

    // Load star ratings map
    final starRatingsJson = prefs.getString(_starRatingsKey);
    Map<int, int> starRatings = {};
    if (starRatingsJson != null) {
      final decoded = json.decode(starRatingsJson) as Map<String, dynamic>;
      starRatings = decoded.map((k, v) => MapEntry(int.parse(k), v as int));
    }

    return ProgressModel(
      completedLevelIds: completedList.map(int.parse).toSet(),
      highestUnlockedLevel: highest,
      bestScores: bestScores,
      starRatings: starRatings,
    );
  }

  /// Saves progress to local storage.
  Future<void> saveProgress(ProgressModel progress) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _completedKey,
      progress.completedLevelIds.map((id) => id.toString()).toList(),
    );
    await prefs.setInt(_highestKey, progress.highestUnlockedLevel);

    // Save best scores
    final bestScoresMap =
        progress.bestScores.map((k, v) => MapEntry(k.toString(), v));
    await prefs.setString(_bestScoresKey, json.encode(bestScoresMap));

    // Save star ratings
    final starRatingsMap =
        progress.starRatings.map((k, v) => MapEntry(k.toString(), v));
    await prefs.setString(_starRatingsKey, json.encode(starRatingsMap));
  }
}
