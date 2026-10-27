import 'package:arrow_puzzle/data/services/audio_service.dart';
import 'package:arrow_puzzle/data/services/settings_service.dart';

/// Repository for user settings with audio integration.
class SettingsRepository {
  SettingsRepository({
    required SettingsService settingsService,
    required AudioService audioService,
  }) : _settingsService = settingsService,
       _audioService = audioService;

  final SettingsService _settingsService;
  final AudioService _audioService;

  bool _hapticsEnabled = true;

  /// Last known haptics preference, readable synchronously (e.g. when a
  /// route is built). Updated by [getHapticsEnabled]/[setHapticsEnabled].
  bool get hapticsEnabled => _hapticsEnabled;

  Future<bool> getSoundEnabled() async {
    final enabled = await _settingsService.getSoundEnabled();
    _audioService.enabled = enabled;
    return enabled;
  }

  Future<void> setSoundEnabled(bool value) async {
    await _settingsService.setSoundEnabled(value);
    _audioService.enabled = value;
  }

  Future<bool> getHapticsEnabled() async {
    _hapticsEnabled = await _settingsService.getHapticsEnabled();
    return _hapticsEnabled;
  }

  Future<void> setHapticsEnabled(bool value) async {
    _hapticsEnabled = value;
    await _settingsService.setHapticsEnabled(value);
  }
}
