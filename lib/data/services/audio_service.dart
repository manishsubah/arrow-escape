import 'package:audioplayers/audioplayers.dart';

/// Manages sound effects for the game.
class AudioService {
  final AudioPlayer _player = AudioPlayer();
  bool _enabled = true;

  bool get isEnabled => _enabled;

  set enabled(bool value) {
    _enabled = value;
    if (!value) {
      _player.stop();
    }
  }

  /// Plays the tap sound effect.
  Future<void> playTap() async {
    if (!_enabled) return;
    await _player.play(AssetSource('sounds/tap.mp3'));
  }

  /// Plays the arrow slide-out sound effect.
  Future<void> playSlide() async {
    if (!_enabled) return;
    await _player.play(AssetSource('sounds/slide.mp3'));
  }

  /// Plays the level-complete celebration sound.
  Future<void> playComplete() async {
    if (!_enabled) return;
    await _player.play(AssetSource('sounds/complete.mp3'));
  }

  /// Releases audio resources.
  void dispose() {
    _player.dispose();
  }
}
