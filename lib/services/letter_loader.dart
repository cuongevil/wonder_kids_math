import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import '../models/vn_letter.dart';

class LetterLoader {
  static const String _jsonPath = 'assets/configs/letters.json';

  /// Đọc JSON, map ra VnLetter và gắn sẵn image/audio path theo key
  static Future<List<VnLetter>> load() async {
    final raw = await rootBundle.loadString(_jsonPath);
    final List<dynamic> data = jsonDecode(raw);

    final letters = data.map((e) {
      final key = e['key'] as String; // ví dụ A_breve
      final char = e['char'] as String;
      final word = (e['word'] as String?)?.trim();
      return VnLetter(
        key: char,
        char: char,
        word: (word == null || word.isEmpty) ? null : word,
        imagePath: 'assets/images/letters/$key.png',
        audioPath: 'audio/letters/$key.mp3',
      );
    }).toList();

    return letters;
  }
}
