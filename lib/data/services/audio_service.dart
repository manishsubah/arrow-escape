import 'package:audioplayers/audioplayers.dart';

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

  Future<void> playTap() async {
    if (!_enabled) return;
    await _player.play(AssetSource('sounds/tap.mp3'));
  }

  Future<void> playSlide() async {
    if (!_enabled) return;
    await _player.play(AssetSource('sounds/slide.mp3'));
  }

  Future<void> playComplete() async {
    if (!_enabled) return;
    await _player.play(AssetSource('sounds/complete.mp3'));
  }

  void dispose() {
    _player.dispose();
  }
}
