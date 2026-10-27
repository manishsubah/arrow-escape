import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:arrow_puzzle/data/models/progress_model.dart';

/// Persists and retrieves level progress using SharedPreferences.
class ProgressService {
  static const _completedKey = 'completed_levels';
  static const _highestKey = 'highest_unlocked';
  static const _bestScoresKey = 'best_scores';
  static const _starRatingsKey = 'star_ratings';

  /// Loads progress from local storage.
  ///
  /// Stored values are untrusted (they can be corrupted or edited on rooted
  /// devices), so malformed entries are skipped instead of crashing the app.
  Future<ProgressModel> loadProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final completed = (prefs.getStringList(_completedKey) ?? [])
        .map(int.tryParse)
        .whereType<int>()
        .where((id) => id > 0)
        .toSet();
    final highest = prefs.getInt(_highestKey) ?? 1;

    return ProgressModel(
      completedLevelIds: completed,
      highestUnlockedLevel: highest < 1 ? 1 : highest,
      bestScores: _decodeIntMap(prefs.getString(_bestScoresKey)),
      starRatings: _decodeIntMap(
        prefs.getString(_starRatingsKey),
      ).map((k, v) => MapEntry(k, v.clamp(0, 3))),
    );
  }

  Map<int, int> _decodeIntMap(String? raw) {
    if (raw == null) return {};
    try {
      final decoded = json.decode(raw);
      if (decoded is! Map) return {};
      final result = <int, int>{};
      decoded.forEach((k, v) {
        final key = int.tryParse(k.toString());
        if (key != null && v is int && v >= 0) result[key] = v;
      });
      return result;
    } on FormatException {
      return {};
    }
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
    final bestScoresMap = progress.bestScores.map(
      (k, v) => MapEntry(k.toString(), v),
    );
    await prefs.setString(_bestScoresKey, json.encode(bestScoresMap));

    // Save star ratings
    final starRatingsMap = progress.starRatings.map(
      (k, v) => MapEntry(k.toString(), v),
    );
    await prefs.setString(_starRatingsKey, json.encode(starRatingsMap));
  }
}
