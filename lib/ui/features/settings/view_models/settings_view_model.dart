import 'package:flutter/material.dart';

import 'package:arrow_puzzle/data/repositories/settings_repository.dart';

/// Manages settings state (sound, haptics).
class SettingsViewModel extends ChangeNotifier {
  SettingsViewModel({required SettingsRepository settingsRepository})
      : _settingsRepository = settingsRepository;

  final SettingsRepository _settingsRepository;

  bool _soundEnabled = true;
  bool get soundEnabled => _soundEnabled;

  bool _hapticsEnabled = true;
  bool get hapticsEnabled => _hapticsEnabled;

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  /// Loads settings from storage.
  Future<void> load() async {
    _isLoading = true;
    notifyListeners();

    try {
      _soundEnabled = await _settingsRepository.getSoundEnabled();
      _hapticsEnabled = await _settingsRepository.getHapticsEnabled();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Toggles sound on/off.
  Future<void> toggleSound() async {
    _soundEnabled = !_soundEnabled;
    notifyListeners();
    await _settingsRepository.setSoundEnabled(_soundEnabled);
  }

  /// Toggles haptic feedback on/off.
  Future<void> toggleHaptics() async {
    _hapticsEnabled = !_hapticsEnabled;
    notifyListeners();
    await _settingsRepository.setHapticsEnabled(_hapticsEnabled);
  }
}
