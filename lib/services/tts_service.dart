import 'package:flutter_tts/flutter_tts.dart';


class TtsService {
  final FlutterTts _tts = FlutterTts();
  bool _inited = false;


  Future<void> init() async {
    if (_inited) return;
    await _tts.setLanguage('vi-VN');
    await _tts.setSpeechRate(0.4); // chậm, phù hợp cho bé
    await _tts.setPitch(1.0);
    _inited = true;
  }


  Future<void> speak(String text) async {
    await init();
    await _tts.stop();
    await _tts.speak(text);
  }


  Future<void> dispose() async {
    await _tts.stop();
  }
}