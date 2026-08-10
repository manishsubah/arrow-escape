import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/level_model.dart';

/// Loads and parses level data from the bundled JSON asset.
class LevelService {
  List<LevelModel>? _cachedLevels;

  /// Loads all levels from assets/data/levels.json.
  Future<List<LevelModel>> loadLevels() async {
    if (_cachedLevels != null) return _cachedLevels!;

    final jsonString = await rootBundle.loadString('assets/data/levels.json');
    final jsonList = json.decode(jsonString) as List<dynamic>;
    _cachedLevels = jsonList
        .map((j) => LevelModel.fromJson(j as Map<String, dynamic>))
        .toList();
    return _cachedLevels!;
  }

  /// Loads a single level by its ID (1-based).
  Future<LevelModel> loadLevel(int levelId) async {
    final levels = await loadLevels();
    return levels.firstWhere((l) => l.id == levelId);
  }
}
