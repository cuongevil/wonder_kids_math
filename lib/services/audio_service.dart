import 'package:audioplayers/audioplayers.dart';

class AudioService {
  static final AudioPlayer _player = AudioPlayer();

  /// Phát file audio từ assets/audio/
  static Future<void> play(String file) async {
    try {
      await _player.stop();
      await _player.play(AssetSource("$file"));
    } catch (_) {}
  }

  static Future<void> stop() async {
    try {
      await _player.stop();
    } catch (_) {}
  }

  static Future<void> dispose() async {
    try {
      await _player.dispose();
    } catch (_) {}
  }
}
