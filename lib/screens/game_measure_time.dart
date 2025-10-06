import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/progress_service.dart';
import '../widgets/wow_mascot.dart';
import 'base_screen.dart';

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
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 1),
    );
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
    if (isCompleted) isReviewMode = true;
    _newQuestion();
    setState(() => isLoading = false);
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _popupController.dispose();
    _blinkController.dispose();
    _player.dispose();
    super.dispose();
  }

  Future<void> _play(String name) async {
    await _player.play(AssetSource('audios/$name.mp3'));
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
      // Đồng hồ giờ đúng
      hourValue = _rand.nextInt(12) + 1;
      question = "Kim giờ chỉ mấy giờ?";
      answer = "$hourValue giờ";
      options = [
        "$hourValue giờ",
        "${(hourValue! % 12) + 1} giờ",
        "${(hourValue! + 3) % 12 + 1} giờ",
      ];
      options.shuffle();
    }
    setState(() {});
  }

  Future<void> _check(String opt) async {
    final correct = opt == answer;
    if (correct) {
      isMascotHappy = true;
      _confettiController.play();
      await _play("correct1");

      if (!isReviewMode) {
        correctCount++;
        await _prefs.setInt(progressKey, correctCount);

        if (correctCount >= 10 && !isCompleted) {
          isCompleted = true;
          await _prefs.setBool(completedKey, true);
          await ProgressService.markLevelCompleted(levelKey);

          await Future.delayed(const Duration(milliseconds: 600));
          _showRewardDialog();
          return;
        }
      }

      _showDialog(
        title: "🎉 Chính xác!",
        content: "Giỏi quá bé ơi! 🌟",
        next: _newQuestion,
      );
    } else {
      isMascotHappy = false;
      await _play("wrong");
      _showDialog(
        title: "❌ Sai rồi",
        content: "Đáp án đúng là $answer",
        next: _newQuestion,
      );
    }
  }

  void _showDialog({
    required String title,
    required String content,
    required VoidCallback next,
  }) {
    showDialog(
      context: context,
      builder: (_) => ScaleTransition(
        scale: CurvedAnimation(
          parent: _popupController,
          curve: Curves.elasticOut,
        ),
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(title, textAlign: TextAlign.center),
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
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text("Tiếp tục ➡️"),
            ),
          ],
        ),
      ),
    );
  }

  void _showRewardDialog() async {
    await _play("victory");
    _confettiController.play();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => ScaleTransition(
        scale: CurvedAnimation(
          parent: _popupController,
          curve: Curves.easeOutBack,
        ),
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            "🏆 Bé giỏi quá!",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
          ),
          content: const Text(
            "Bé đã học xong phần đo lường & thời gian! ⏰",
            textAlign: TextAlign.center,
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context, true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text("Hoàn thành 🌟"),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: Colors.orangeAccent),
        ),
      );
    }

    return BaseScreen(
      title: "Đo lường & Thời gian",
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              numberOfParticles: 30,
              colors: const [
                Colors.orange,
                Colors.amber,
                Colors.pink,
                Colors.purple,
              ],
            ),
          ),
          Positioned(
            bottom: 100,
            right: 24,
            child: WowMascot(isHappy: isMascotHappy),
          ),

          // 🧩 Nội dung chính
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 🟡 Câu hỏi luôn hiển thị rõ ràng
              Text(
                question,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.deepPurple,
                  shadows: isDark
                      ? [
                          const Shadow(color: Colors.white70, blurRadius: 8),
                          const Shadow(
                            color: Colors.orangeAccent,
                            blurRadius: 12,
                          ),
                        ]
                      : null,
                ),
              ),
              const SizedBox(height: 24),

              // 🎨 Nếu là câu về độ dài
              if (mode == 0)
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      AnimatedBuilder(
                        animation: _blinkController,
                        builder: (context, _) => _buildLine(
                          'A',
                          lineA,
                          Colors.blueAccent,
                          _blinkController.value,
                        ),
                      ),
                      const SizedBox(height: 20),
                      AnimatedBuilder(
                        animation: _blinkController,
                        builder: (context, _) => _buildLine(
                          'B',
                          lineB,
                          Colors.greenAccent,
                          _blinkController.value,
                        ),
                      ),
                    ],
                  ),
                ),

              // 🕒 Nếu là câu về đồng hồ
              if (mode == 1 && hourValue != null) ...[
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: 1),
                  duration: const Duration(milliseconds: 800),
                  curve: Curves.easeOutBack,
                  builder: (context, value, _) {
                    return Transform.rotate(
                      angle: 2 * pi * (1 - value) / 10,
                      child: CustomPaint(
                        size: const Size(160, 160),
                        painter: _ClockPainter(
                          hour: hourValue!,
                          progress: value,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.remove, color: Colors.redAccent, size: 28),
                    Text(
                      " Kim giờ",
                      style: TextStyle(fontSize: 18, color: Colors.redAccent),
                    ),
                    SizedBox(width: 20),
                    Icon(Icons.remove, color: Colors.lightBlueAccent, size: 28),
                    Text(
                      " Kim phút",
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.lightBlueAccent,
                      ),
                    ),
                  ],
                ),
              ],

              const SizedBox(height: 30),

              // Các nút đáp án
              LayoutBuilder(
                builder: (context, constraints) {
                  const spacing = 20.0;
                  const columns = 2;
                  final btnWidth =
                      (constraints.maxWidth - (columns - 1) * spacing) /
                      columns;

                  return Wrap(
                    spacing: spacing,
                    runSpacing: 16,
                    alignment: WrapAlignment.center,
                    children: options.map((opt) {
                      return SizedBox(
                        width: btnWidth,
                        height: 56,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orangeAccent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
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
                        ),
                      );
                    }).toList(),
                  );
                },
              ),

              const SizedBox(height: 40),

              if (!isReviewMode)
                Text(
                  "Tiến độ: $correctCount / 10",
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.deepPurple,
                    fontWeight: FontWeight.bold,
                  ),
                )
              else
                const Text(
                  "Chế độ ôn luyện 🌈",
                  style: TextStyle(
                    color: Colors.pinkAccent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLine(String label, int length, Color color, double blinkValue) {
    final glow = [
      Shadow(
        color: Colors.white.withOpacity(0.7 + 0.3 * blinkValue),
        blurRadius: 8 + 6 * blinkValue,
      ),
      Shadow(
        color: Colors.yellowAccent.withOpacity(0.5 + 0.4 * blinkValue),
        blurRadius: 12 + 10 * blinkValue,
      ),
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
        Text(
          "$length cm",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
            shadows: glow,
          ),
        ),
      ],
    );
  }
}

/// 🎨 Đồng hồ có kim giờ xoay nhẹ khi xuất hiện
class _ClockPainter extends CustomPainter {
  final int hour;
  final double progress;

  _ClockPainter({required this.hour, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final paintCircle = Paint()..color = Colors.white;
    final paintBorder = Paint()
      ..color = Colors.deepPurple
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;
    canvas.drawCircle(center, radius, paintCircle);
    canvas.drawCircle(center, radius, paintBorder);

    // Vẽ số quanh mặt
    final textPainter = TextPainter(
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );
    for (int i = 1; i <= 12; i++) {
      final angle = (i * 30) * pi / 180;
      final offset = Offset(
        center.dx + (radius - 20) * sin(angle),
        center.dy - (radius - 20) * cos(angle),
      );
      textPainter.text = TextSpan(
        text: "$i",
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.deepPurple,
        ),
      );
      textPainter.layout();
      textPainter.paint(canvas, offset - const Offset(6, 8));
    }

    // Kim giờ đỏ to
    final paintHour = Paint()
      ..color = Colors.redAccent
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;
    final baseHourAngle = (hour % 12) * 30 * pi / 180;
    final hourAngle = baseHourAngle * progress;
    final hourLength = radius * 0.5;
    final hourEnd = Offset(
      center.dx + hourLength * sin(hourAngle),
      center.dy - hourLength * cos(hourAngle),
    );
    canvas.drawLine(center, hourEnd, paintHour);
    canvas.drawCircle(hourEnd, 6, Paint()..color = Colors.redAccent);

    // Kim phút xanh (luôn chỉ 12)
    final paintMinute = Paint()
      ..color = Colors.lightBlueAccent
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    final minuteLength = radius * 0.75;
    final minuteEnd = Offset(center.dx, center.dy - minuteLength);
    canvas.drawLine(center, minuteEnd, paintMinute);
    canvas.drawCircle(minuteEnd, 4, Paint()..color = Colors.lightBlueAccent);

    canvas.drawCircle(center, 5, Paint()..color = Colors.deepPurple);
  }

  @override
  bool shouldRepaint(covariant _ClockPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.hour != hour;
}
