import 'package:shared_preferences/shared_preferences.dart';

/// Persists user settings (sound, haptics, accepted terms version).
class SettingsService {
  static const _soundKey = 'sound_enabled';
  static const _hapticsKey = 'haptics_enabled';
  static const _termsVersionKey = 'terms_accepted_version';

  Future<bool> getSoundEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_soundKey) ?? true;
  }

  Future<void> setSoundEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_soundKey, value);
  }

  Future<bool> getHapticsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_hapticsKey) ?? true;
  }

  Future<void> setHapticsEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_hapticsKey, value);
  }

  /// Version of the Terms the user last accepted, or 0 if never.
  Future<int> getAcceptedTermsVersion() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_termsVersionKey) ?? 0;
  }

  Future<void> setAcceptedTermsVersion(int version) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_termsVersionKey, version);
  }
}
