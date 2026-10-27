import 'package:flutter/material.dart';

import 'package:arrow_puzzle/data/repositories/settings_repository.dart';
import 'package:arrow_puzzle/data/services/ad_service.dart';

/// Manages settings state (sound, haptics, ad privacy choices).
class SettingsViewModel extends ChangeNotifier {
  SettingsViewModel({
    required SettingsRepository settingsRepository,
    required AdService adService,
  }) : _settingsRepository = settingsRepository,
       _adService = adService;

  final SettingsRepository _settingsRepository;
  final AdService _adService;

  bool _soundEnabled = true;
  bool get soundEnabled => _soundEnabled;

  bool _hapticsEnabled = true;
  bool get hapticsEnabled => _hapticsEnabled;

  /// Whether to show the "Privacy Choices" entry (ad consent applies).
  bool _privacyOptionsRequired = false;
  bool get privacyOptionsRequired => _privacyOptionsRequired;

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  /// Loads settings from storage.
  Future<void> load() async {
    _isLoading = true;
    notifyListeners();

    try {
      _soundEnabled = await _settingsRepository.getSoundEnabled();
      _hapticsEnabled = await _settingsRepository.getHapticsEnabled();
      _privacyOptionsRequired = await _adService.isPrivacyOptionsRequired();
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

  /// Opens the ad consent form so the user can change their choices.
  Future<void> openPrivacyChoices() => _adService.showPrivacyOptionsForm();
}
