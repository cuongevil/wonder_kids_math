import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/vn_letter.dart';
import '../models/mascot_mood.dart';
import '../widgets/game_base.dart';
import '../widgets/mascot_widget.dart';
import '../widgets/score_board.dart';
import '../widgets/rainbow_progress.dart';
import '../widgets/confetti_overlay.dart';
import '../services/audio_service.dart';
import '../mixins/game_level_mixin.dart';

class GameFill extends StatefulWidget {
  const GameFill({super.key});

  @override
  State<GameFill> createState() => _GameFillState();
}

class _GameFillState extends GameBaseState<GameFill>
    with TickerProviderStateMixin, GameLevelMixin {
  @override
  String get gameId => "game3";

  @override
  String get title => "Điền chữ";

  List<VnLetter> letters = [];
  VnLetter? answerLetter;       // chữ cái được chọn để lấy 'word'
  String? sampleWord;           // từ có nghĩa (lấy từ answerLetter.word)
  List<String> displayed = [];  // từ sau khi che 1 ký tự
  List<VnLetter> options = [];  // 4 lựa chọn

  VnLetter? wrongChoice;

  // Ký tự đã CHUẨN HÓA cần điền (ví dụ 'ó' -> 'O', 'ớ' -> 'Ơ', 'ấ' -> 'Â')
  String? _missingNormalized;   // so sánh đáp án bằng biến này

  late AnimationController _progressController;

  // ==== Helpers: chuẩn hoá ký tự về bảng 29 chữ cái ====
  static final Map<String, String> _vnMap = {
    // a
    'a':'A','á':'A','à':'A','ả':'A','ã':'A','ạ':'A',
    'ă':'Ă','ắ':'Ă','ằ':'Ă','ẳ':'Ă','ẵ':'Ă','ặ':'Ă',
    'â':'Â','ấ':'Â','ầ':'Â','ẩ':'Â','ẫ':'Â','ậ':'Â',
    // e
    'e':'E','é':'E','è':'E','ẻ':'E','ẽ':'E','ẹ':'E',
    'ê':'Ê','ế':'Ê','ề':'Ê','ể':'Ê','ễ':'Ê','ệ':'Ê',
    // i
    'i':'I','í':'I','ì':'I','ỉ':'I','ĩ':'I','ị':'I',
    // o
    'o':'O','ó':'O','ò':'O','ỏ':'O','õ':'O','ọ':'O',
    'ô':'Ô','ố':'Ô','ồ':'Ô','ổ':'Ô','ỗ':'Ô','ộ':'Ô',
    'ơ':'Ơ','ớ':'Ơ','ờ':'Ơ','ở':'Ơ','ỡ':'Ơ','ợ':'Ơ',
    // u
    'u':'U','ú':'U','ù':'U','ủ':'U','ũ':'U','ụ':'U',
    'ư':'Ư','ứ':'Ư','ừ':'Ư','ử':'Ư','ữ':'Ư','ự':'Ư',
    // y
    'y':'Y','ý':'Y','ỳ':'Y','ỷ':'Y','ỹ':'Y','ỵ':'Y',
    // d
    'd':'D','đ':'Đ',
    // vốn dĩ chữ cái hoa không dấu thanh cũng hợp lệ
    'ă':'Ă','â':'Â','ê':'Ê','ô':'Ô','ơ':'Ơ','ư':'Ư',
    // uppercase direct map
    'A':'A','Ă':'Ă','Â':'Â','E':'E','Ê':'Ê','I':'I','O':'O','Ô':'Ô','Ơ':'Ơ','U':'U','Ư':'Ư','Y':'Y','D':'D','Đ':'Đ',
  };

  String? _normalizeVN(String ch) {
    if (ch.trim().isEmpty) return null;
    final lower = ch.toLowerCase();
    return _vnMap[lower] ?? _vnMap[ch] ?? null;
  }

  @override
  void initState() {
    super.initState();
    initLevelMixin();
    _loadLetters();
    _progressController =
    AnimationController(vsync: this, duration: const Duration(seconds: 2))
      ..repeat();
  }

  @override
  void dispose() {
    disposeLevelMixin();
    _progressController.dispose();
    super.dispose();
  }

  Future<void> _loadLetters() async {
    final String response =
    await rootBundle.loadString('assets/configs/letters.json');
    final List<dynamic> data = json.decode(response);

    setState(() {
      letters = data.map((e) => VnLetter.fromJson(e)).toList();
      _nextRound();
    });
  }

  void _nextRound() {
    if (round >= maxRound) {
      showLevelComplete(
        title: "✨ Xuất sắc!",
        subtitle: "Bạn đã điền chữ chính xác 🤩",
        onNextRound: _nextRound,
      );
      return;
    }

    final random = Random();

    // 1) Chọn VnLetter có word hợp lệ (>=2)
    VnLetter candidate;
    do {
      candidate = letters[random.nextInt(letters.length)];
    } while (candidate.word == null || candidate.word!.trim().length < 2);

    answerLetter = candidate;
    final word = answerLetter!.word!.trim();

    // 2) Xác định các vị trí có thể che (chỉ những ký tự map được sang 29 chữ)
    final chars = word.split('');
    final eligibleIdx = <int>[];
    for (int i = 0; i < chars.length; i++) {
      final n = _normalizeVN(chars[i]);
      if (n != null) {
        // n là 1 trong A Ă Â E Ê I O Ô Ơ U Ư Y D Đ
        eligibleIdx.add(i);
      }
    }

    if (eligibleIdx.isEmpty) {
      // fallback: nếu từ này không có ký tự hợp lệ (hiếm), chọn round khác
      _nextRound();
      return;
    }

    // 3) Chọn random 1 vị trí để che và chuẩn hoá ký tự ẩn
    final idx = eligibleIdx[random.nextInt(eligibleIdx.length)];
    final missingChar = chars[idx];               // có thể là 'ó', 'ắ', ...
    final normalized = _normalizeVN(missingChar); // ví dụ 'ó' -> 'O'
    _missingNormalized = normalized;              // dùng để check đáp án

    // 4) Tạo chữ hiển thị có '_'
    chars[idx] = "_";
    displayed = chars;
    sampleWord = word;

    // 5) Tạo options: 1 đúng (normalized) + 3 nhiễu khác
    final allCharsSet = letters.map((l) => l.char.toUpperCase()).toSet();
    VnLetter correct;
    if (_missingNormalized != null &&
        allCharsSet.contains(_missingNormalized)) {
      correct = letters.firstWhere(
            (l) => l.char.toUpperCase() == _missingNormalized,
      );
    } else {
      // phòng ngừa: nếu vì lý do gì không tìm thấy, tạo tạm
      correct = VnLetter(
        key: _missingNormalized ?? 'X',
        char: _missingNormalized ?? 'X',
        word: '',
        imagePath: '',
        gameImagePath: '',
        audioPath: '',
      );
    }

    final distractors = <VnLetter>[];
    final shuffled = [...letters]..shuffle();
    final used = <String>{correct.char.toUpperCase()};
    for (final l in shuffled) {
      final up = l.char.toUpperCase();
      if (used.contains(up)) continue;
      distractors.add(l);
      used.add(up);
      if (distractors.length == 3) break;
    }

    options = [correct, ...distractors]..shuffle();

    wrongChoice = null;
    mascotMood = MascotMood.idle;
    setState(() {});
  }

  void _checkAnswer(VnLetter chosen) async {
    final isCorrect = _missingNormalized != null &&
        chosen.char.toUpperCase() == _missingNormalized;

    await onAnswer(isCorrect);

    setState(() {
      increaseScore(isCorrect);
      if (!isCorrect) wrongChoice = chosen;
    });

    if (isCorrect) {
      confettiController.play();
      AudioService.play("correct.mp3");
      Future.delayed(const Duration(milliseconds: 900), () {
        if (!mounted) return;
        setState(() {
          round++;
          _nextRound();
        });
      });
    } else {
      AudioService.play("wrong.mp3");
      Future.delayed(const Duration(milliseconds: 600), () {
        if (!mounted) return;
        setState(() => wrongChoice = null);
      });
    }
  }

  @override
  Widget buildGame(BuildContext context) {
    final progress = overallProgress();

    if (answerLetter == null || sampleWord == null || _missingNormalized == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.pink.shade50, Colors.blue.shade50],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Stack(
        children: [
          Column(
            children: [
              RainbowProgress(progress: progress, controller: _progressController),
              ScoreBoard(
                streak: streak,
                maxStreak: maxStreak,
                totalCorrect: totalCorrect,
              ),
              const SizedBox(height: 12),
              const Text("Điền chữ cái còn thiếu",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
              const SizedBox(height: 24),

              // từ hiển thị với chỗ trống
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: displayed
                    .map((c) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Text(
                    c,
                    style: TextStyle(
                      fontSize: 42,
                      fontWeight: FontWeight.bold,
                      color: c == "_" ? Colors.pink : Colors.black87,
                    ),
                  ),
                ))
                    .toList(),
              ),

              const SizedBox(height: 32),

              // lựa chọn
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: options.map((l) {
                  final isWrong = wrongChoice == l;
                  return GestureDetector(
                    onTap: () => _checkAnswer(l),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      width: 76,
                      height: 76,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isWrong ? Colors.red.shade200 : Colors.blue.shade100,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: const [
                          BoxShadow(
                              color: Colors.black26,
                              blurRadius: 4,
                              offset: Offset(2, 2))
                        ],
                      ),
                      child: Text(
                        l.char,
                        style: const TextStyle(
                            fontSize: 32, fontWeight: FontWeight.bold),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 120),
            ],
          ),
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: Center(child: MascotWidget(mood: mascotMood)),
          ),
          ConfettiOverlay(controller: confettiController),
        ],
      ),
    );
  }

  // onReset riêng cho GameFill (không gọi super vì lớp cha là abstract)
  @override
  void onReset() {
    setState(() {
      // reset biến chung
      round = 0;
      level = 1;
      streak = 0;
      maxStreak = 0;
      totalCorrect = 0;
      mascotMood = MascotMood.idle;

      // reset biến riêng
      answerLetter = null;
      sampleWord = null;
      displayed = [];
      options = [];
      wrongChoice = null;
      _missingNormalized = null;
    });
    _loadLetters();
  }
}
