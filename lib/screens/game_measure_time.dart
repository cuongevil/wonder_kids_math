import 'dart:math';
import 'dart:ui';
import 'package:audioplayers/audioplayers.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/progress_service.dart';
import '../widgets/wow_mascot.dart';
import 'base_screen.dart';

/// ⏰ GameMeasureTimeScreen v6.0 — Fintech Gradient + Confetti 3 tầng + Glow Popup
class GameMeasureTimeScreen extends StatefulWidget {
  const GameMeasureTimeScreen({super.key});

  @override
  State<GameMeasureTimeScreen> createState() => _GameMeasureTimeScreenState();
}

class _GameMeasureTimeScreenState extends State<GameMeasureTimeScreen>
    with TickerProviderStateMixin {
  final _rand = Random();
  final AudioPlayer _player = AudioPlayer();
  late SharedPreferences _prefs;

  static const String progressKey = "game_measure_progress";
  static const String completedKey = "game_measure_completed";
  static const String levelKey = "measure_time";

  int correctCount = 0;
  bool isCompleted = false;
  bool isReviewMode = false;
  bool isMascotHappy = true;
  bool isLoading = true;

  late ConfettiController _confettiController;
  late ConfettiController _miniConfettiController;
  late AnimationController _popupController;
  late AnimationController _blinkController;

  late String question;
  late List<String> options;
  late String answer;
  late int mode; // 0 = đo độ dài, 1 = xem đồng hồ
  int? hourValue;
  int lineA = 0;
  int lineB = 0;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 2));
    _miniConfettiController = ConfettiController(duration: const Duration(seconds: 1));
    _popupController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
      lowerBound: 0.7,
      upperBound: 1.0,
    );
    _blinkController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);
    _initProgress();
  }

  Future<void> _initProgress() async {
    _prefs = await SharedPreferences.getInstance();
    correctCount = _prefs.getInt(progressKey) ?? 0;
    isCompleted = _prefs.getBool(completedKey) ?? false;
    isReviewMode = isCompleted;
    _newQuestion();
    setState(() => isLoading = false);
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _miniConfettiController.dispose();
    _popupController.dispose();
    _blinkController.dispose();
    _player.dispose();
    super.dispose();
  }

  Future<void> _play(String name) async {
    try {
      await _player.play(AssetSource('audios/$name.mp3'));
    } catch (_) {}
  }

  void _newQuestion() {
    mode = _rand.nextInt(2);
    if (mode == 0) {
      // So sánh độ dài
      lineA = _rand.nextInt(100) + 50;
      lineB = _rand.nextInt(100) + 50;
      question = "Đoạn nào dài hơn?";
      answer = lineA > lineB ? "A" : "B";
      options = ["A", "B"];
      hourValue = null;
    } else {
      // Đồng hồ
      hourValue = _rand.nextInt(12) + 1;
      question = "Kim giờ chỉ mấy giờ?";
      answer = "$hourValue giờ";
      options = [
        "$hourValue giờ",
        "${(hourValue! % 12) + 1} giờ",
        "${(hourValue! + 3) % 12 + 1} giờ",
      ]..shuffle();
    }
    setState(() {});
  }

  Future<void> _check(String opt) async {
    final correct = opt == answer;
    if (correct) {
      isMascotHappy = true;
      _miniConfettiController.play();
      await _play("correct1");

      if (!isReviewMode) {
        correctCount++;
        await _prefs.setInt(progressKey, correctCount);

        if (correctCount >= 10 && !isCompleted) {
          isCompleted = true;
          await _prefs.setBool(completedKey, true);
          await ProgressService.markLevelCompleted(levelKey);
          await Future.delayed(const Duration(milliseconds: 500));
          await _showRewardPopup();
          return;
        }
      }

      _showDialog("🎉 Chính xác!", "Giỏi quá bé ơi! 🌟", _newQuestion);
    } else {
      isMascotHappy = false;
      await _play("wrong");
      _showDialog("❌ Sai rồi", "Đáp án đúng là $answer", _newQuestion);
    }
  }

  void _showDialog(String title, String content, VoidCallback next) {
    showDialog(
      context: context,
      builder: (_) => ScaleTransition(
        scale: CurvedAnimation(parent: _popupController, curve: Curves.elasticOut),
        child: AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(title, textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold)),
          content: Text(content, textAlign: TextAlign.center),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                next();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orangeAccent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text("Tiếp tục ➡️"),
            ),
          ],
        ),
      ),
    );
  }

  /// 🌟 Popup hoàn thành lung linh gradient tím–cam
  Future<void> _showRewardPopup() async {
    await _play("victory");
    _confettiController.play();

    final size = MediaQuery.of(context).size;
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (_, __, ___) => Container(),
      transitionBuilder: (_, anim, __, ___) {
        final scale = Tween(begin: 0.8, end: 1.0)
            .animate(CurvedAnimation(parent: anim, curve: Curves.easeOutBack));

        return Transform.scale(
          scale: scale.value,
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: Dialog(
              backgroundColor: Colors.white.withOpacity(0.05),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              insetPadding: const EdgeInsets.all(24),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF5E2CED), Color(0xFFFF8B00)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.25),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedScale(
                      duration: const Duration(milliseconds: 600),
                      curve: Curves.easeOutBack,
                      scale: scale.value,
                      child: Image.asset(
                        "assets/images/mascot/mascot_10.png",
                        width: size.width * 0.4,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "Bé đã học xong phần đo lường & thời gian! ⏰",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: [
                          Shadow(color: Colors.white70, blurRadius: 8),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pop(context, true);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(25),
                          gradient: const LinearGradient(
                            colors: [Color(0xFF5E2CED), Color(0xFFFF8B00)],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Color(0xFF5E2CED).withOpacity(0.4),
                              blurRadius: 20,
                              offset: Offset(0, 8),
                            ),
                          ],
                        ),
                        child: const Text(
                          "Quay lại bản đồ",
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: Colors.orangeAccent)),
      );
    }

    return BaseScreen(
      title: "Đo lường & Thời gian",
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 🌈 Gradient nền
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFFFF1D0), Color(0xFFFFE0E8)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          // 🎊 Confetti 3 tầng
          Align(
            alignment: Alignment.center,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              emissionFrequency: 0.05,
              numberOfParticles: 25,
              gravity: 0.3,
              colors: const [
                Color(0xFF5E2CED),
                Color(0xFFFF8B00),
                Color(0xFFA58CFF),
              ],
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: ConfettiWidget(
              confettiController: _miniConfettiController,
              numberOfParticles: 10,
              gravity: 0.4,
              colors: const [
                Color(0xFFFFC300),
                Color(0xFF7E57C2),
                Color(0xFFFF80AB),
              ],
            ),
          ),

          Positioned(
            bottom: 100,
            right: 24,
            child: WowMascot.only(isHappy: isMascotHappy, scale: 0.8),
          ),

          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                question,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                  shadows: [Shadow(color: Colors.white, blurRadius: 6)],
                ),
              ),
              const SizedBox(height: 24),

              if (mode == 0) ...[
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      AnimatedBuilder(
                        animation: _blinkController,
                        builder: (_, __) => _buildLine('A', lineA, Colors.blueAccent, _blinkController.value),
                      ),
                      const SizedBox(height: 20),
                      AnimatedBuilder(
                        animation: _blinkController,
                        builder: (_, __) => _buildLine('B', lineB, Colors.greenAccent, _blinkController.value),
                      ),
                    ],
                  ),
                ),
              ] else if (hourValue != null) ...[
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: 1),
                  duration: const Duration(milliseconds: 800),
                  curve: Curves.easeOutBack,
                  builder: (_, value, __) {
                    return Transform.rotate(
                      angle: 2 * pi * (1 - value) / 10,
                      child: CustomPaint(
                        size: const Size(160, 160),
                        painter: _ClockPainter(hour: hourValue!, progress: value),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.remove, color: Colors.redAccent),
                    Text(" Kim giờ", style: TextStyle(color: Colors.redAccent)),
                    SizedBox(width: 16),
                    Icon(Icons.remove, color: Colors.lightBlueAccent),
                    Text(" Kim phút", style: TextStyle(color: Colors.lightBlueAccent)),
                  ],
                ),
              ],

              const SizedBox(height: 30),

              // 🔹 Các nút đáp án
              Wrap(
                spacing: 20,
                runSpacing: 16,
                alignment: WrapAlignment.center,
                children: options.map((opt) {
                  return ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orangeAccent,
                      padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 6,
                    ),
                    onPressed: () => _check(opt),
                    child: Text(
                      opt,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 40),
              if (!isReviewMode)
                Text("Tiến độ: $correctCount / 10",
                    style: const TextStyle(
                        color: Colors.deepPurple,
                        fontWeight: FontWeight.bold))
              else
                const Text("Chế độ ôn luyện 🌈",
                    style: TextStyle(
                        color: Colors.pinkAccent,
                        fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLine(String label, int length, Color color, double blinkValue) {
    final glow = [
      Shadow(color: Colors.white.withOpacity(0.8), blurRadius: 6 + 6 * blinkValue),
      Shadow(color: color.withOpacity(0.5), blurRadius: 10 + 8 * blinkValue),
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "$label:",
          style: TextStyle(
            fontSize: 38,
            fontWeight: FontWeight.bold,
            color: Colors.yellowAccent,
            shadows: glow,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          width: length.toDouble(),
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(5),
          ),
        ),
        const SizedBox(width: 8),
        Text("$length cm",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.deepPurple,
              shadows: glow,
            )),
      ],
    );
  }
}

/// 🕒 Đồng hồ với kim xoay mượt
class _ClockPainter extends CustomPainter {
  final int hour;
  final double progress;
  _ClockPainter({required this.hour, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final paintCircle = Paint()..color = Colors.white;
    final border = Paint()
      ..color = Colors.deepPurple
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;
    canvas.drawCircle(center, radius, paintCircle);
    canvas.drawCircle(center, radius, border);

    // Số 1–12
    final tp = TextPainter(textAlign: TextAlign.center, textDirection: TextDirection.ltr);
    for (int i = 1; i <= 12; i++) {
      final angle = (i * 30) * pi / 180;
      final pos = Offset(center.dx + (radius - 20) * sin(angle), center.dy - (radius - 20) * cos(angle));
      tp.text = TextSpan(
          text: "$i",
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.deepPurple));
      tp.layout();
      tp.paint(canvas, pos - const Offset(6, 8));
    }

    // Kim giờ đỏ
    final paintHour = Paint()
      ..color = Colors.redAccent
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;
    final baseAngle = (hour % 12) * 30 * pi / 180;
    final hourAngle = baseAngle * progress;
    final hourEnd = Offset(center.dx + radius * 0.5 * sin(hourAngle),
        center.dy - radius * 0.5 * cos(hourAngle));
    canvas.drawLine(center, hourEnd, paintHour);

    // Kim phút xanh
    final paintMinute = Paint()
      ..color = Colors.lightBlueAccent
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    final minuteEnd = Offset(center.dx, center.dy - radius * 0.75);
    canvas.drawLine(center, minuteEnd, paintMinute);
    canvas.drawCircle(center, 5, Paint()..color = Colors.deepPurple);
  }

  @override
  bool shouldRepaint(covariant _ClockPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.hour != hour;
}
