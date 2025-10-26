import 'dart:math';
import 'dart:ui';
import 'package:audioplayers/audioplayers.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/progress_service.dart';

/// ⏰ GameMeasureTimeScreen v9.3 — Fintech Gradient + Glow + Confetti + Auto Reset
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
  bool isReviewMode = false; // auto false vì đã auto reset, vẫn giữ cho đồng bộ
  bool isLoading = true;
  bool isAnswered = false;

  // UI state
  String? resultText;
  Color? resultColor;

  // Confetti & animations
  late ConfettiController _confettiMain;
  late ConfettiController _confettiMini;
  late AnimationController _popupController;
  late AnimationController _blinkController;
  late AnimationController _gradientController;
  late AnimationController _glowController;

  // Question state
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
    _confettiMain = ConfettiController(duration: const Duration(seconds: 2));
    _confettiMini = ConfettiController(duration: const Duration(seconds: 1));
    _popupController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
      lowerBound: 0.7,
      upperBound: 1.0,
    );
    _blinkController = AnimationController(vsync: this, duration: const Duration(seconds: 1))
      ..repeat(reverse: true);
    _gradientController =
    AnimationController(vsync: this, duration: const Duration(seconds: 8))
      ..repeat(reverse: true);
    _glowController =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 600));

    _initProgress();
  }

  Future<void> _initProgress() async {
    _prefs = await SharedPreferences.getInstance();
    correctCount = _prefs.getInt(progressKey) ?? 0;
    isCompleted = _prefs.getBool(completedKey) ?? false;

    // ✅ Tự reset nếu đã hoàn thành ở lần trước để vào là chơi lại ngay
    if (isCompleted) {
      correctCount = 0;
      isCompleted = false;
      await _prefs.setInt(progressKey, 0);
      await _prefs.setBool(completedKey, false);
    }

    _newQuestion();
    setState(() => isLoading = false);
  }

  @override
  void dispose() {
    _confettiMain.dispose();
    _confettiMini.dispose();
    _popupController.dispose();
    _blinkController.dispose();
    _gradientController.dispose();
    _glowController.dispose();
    _player.dispose();
    super.dispose();
  }

  Future<void> _play(String name) async {
    try {
      await _player.play(AssetSource('audios/$name.mp3'));
    } catch (_) {}
  }

  void _newQuestion() {
    // Reset UI state
    isAnswered = false;
    resultText = null;
    resultColor = null;

    mode = _rand.nextInt(2);
    if (mode == 0) {
      // So sánh độ dài
      lineA = _rand.nextInt(100) + 50; // 50–149
      lineB = _rand.nextInt(100) + 50;
      question = "Đoạn nào dài hơn?";
      if (lineA == lineB) {
        // tránh trường hợp bằng nhau làm khó trẻ, random lại nhẹ
        lineB = lineA + (_rand.nextBool() ? 5 : -5).clamp(-20, 20);
        if (lineB < 30) lineB = 30;
      }
      answer = lineA > lineB ? "A" : "B";
      options = ["A", "B"];
      hourValue = null;
    } else {
      // Đồng hồ (kim phút cố định ở 12h cho dễ nhận biết)
      hourValue = _rand.nextInt(12) + 1; // 1..12
      question = "Kim giờ chỉ mấy giờ?";
      answer = "$hourValue giờ";
      options = [
        "$hourValue giờ",
        "${(hourValue! % 12) + 1} giờ",
        "${((hourValue! + 3) - 1) % 12 + 1} giờ",
      ]..shuffle();
    }
    setState(() {});
  }

  Future<void> _check(String opt) async {
    if (isAnswered) return;
    isAnswered = true;
    HapticFeedback.selectionClick();

    final correct = opt == answer;

    if (correct) {
      await _play("correct1");
      _confettiMini.play();
      _glowController.forward(from: 0);
      setState(() {
        resultText = "🎉 Chính xác rồi!";
        resultColor = const Color(0xFF5E2CED);
      });

      // tiến độ
      correctCount++;
      await _prefs.setInt(progressKey, correctCount);

      if (correctCount >= 10 && !isCompleted) {
        isCompleted = true;
        await _prefs.setBool(completedKey, true);
        await Future.delayed(const Duration(milliseconds: 600));
        await _onCompleted();
        return;
      }
    } else {
      await _play("wrong");
      _glowController.forward(from: 0);
      setState(() {
        resultText = "❌ Sai rồi — Đáp án đúng là $answer";
        resultColor = Colors.redAccent;
      });
    }

    // next
    await Future.delayed(const Duration(milliseconds: 1500));
    _newQuestion();
  }

  Future<void> _onCompleted() async {
    _confettiMain.play();
    await _play("victory");
    await ProgressService.markLevelCompleted(levelKey);

    // ✅ reset để lần sau vào chơi lại
    await _prefs.setInt(progressKey, 0);
    await _prefs.setBool(completedKey, false);

    _showRewardPopup();
  }

  void _showRewardPopup() {
    final size = MediaQuery.of(context).size;
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: '',
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (_, __, ___) => const SizedBox.shrink(),
      transitionBuilder: (_, anim, __, ___) {
        final scale = Tween<double>(begin: 0.8, end: 1.0)
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
                    Image.asset(
                      "assets/images/mascot/mascot_10.png",
                      width: size.width * 0.4,
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "Bé đã học xong phần đo lường & thời gian! ⏰",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: [Shadow(color: Colors.white70, blurRadius: 8)],
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
                              color: const Color(0xFF5E2CED).withOpacity(0.4),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: const Text(
                          "Quay lại bản đồ",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
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

  // ---------- UI ----------

  Widget _animatedBackground() {
    return AnimatedBuilder(
      animation: _gradientController,
      builder: (context, _) {
        final t = _gradientController.value;
        final colors = [
          Color.lerp(const Color(0xFF5E2CED), const Color(0xFFFF8B00), t)!,
          Color.lerp(const Color(0xFFA58CFF), const Color(0xFF5E2CED), 1 - t)!,
        ];
        return ShaderMask(
          shaderCallback: (r) => LinearGradient(
            colors: colors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ).createShader(r),
          blendMode: BlendMode.srcATop,
          child: Container(color: Colors.white),
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

    final size = MediaQuery.of(context).size;
    final glow = _glowController.value;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white.withOpacity(0.05),
        centerTitle: true,
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: Container(color: Colors.white.withOpacity(0.05)),
          ),
        ),
        title: ShaderMask(
          shaderCallback: (r) =>
              const LinearGradient(colors: [Color(0xFF5E2CED), Color(0xFFFF8B00)]).createShader(r),
          blendMode: BlendMode.srcATop,
          child: const Text(
            "Đo lường & Thời gian",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: Colors.white),
          ),
        ),
      ),
      body: Stack(
        alignment: Alignment.center,
        children: [
          _animatedBackground(),
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
            child: Container(color: Colors.white.withOpacity(0.08)),
          ),

          // Confetti
          ConfettiWidget(
            confettiController: _confettiMain,
            blastDirectionality: BlastDirectionality.explosive,
            numberOfParticles: 25,
            gravity: 0.3,
            colors: const [Color(0xFF5E2CED), Color(0xFFFF8B00), Color(0xFFA58CFF)],
          ),
          ConfettiWidget(
            confettiController: _confettiMini,
            blastDirectionality: BlastDirectionality.explosive,
            numberOfParticles: 10,
            gravity: 0.4,
            colors: const [Color(0xFFFFC300), Color(0xFF7E57C2), Color(0xFFFF80AB)],
          ),

          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.only(top: size.height * 0.15, bottom: 80),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Card câu hỏi (glow on correct/wrong)
                AnimatedContainer(
                  duration: const Duration(milliseconds: 400),
                  padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 22),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    gradient: const LinearGradient(
                      colors: [Color(0xFF5E2CED), Color(0xFFFF8B00)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white.withOpacity(glow * 0.6),
                        blurRadius: 28 * glow,
                        spreadRadius: 10 * glow,
                      ),
                    ],
                  ),
                  child: Text(
                    question,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Inline result
                if (resultText != null)
                  AnimatedOpacity(
                    opacity: 1,
                    duration: const Duration(milliseconds: 300),
                    child: Text(
                      resultText!,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: resultColor,
                      ),
                    ),
                  ),
                const SizedBox(height: 24),

                // Nội dung minh họa theo mode
                if (mode == 0) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    child: Column(
                      children: [
                        AnimatedBuilder(
                          animation: _blinkController,
                          builder: (_, __) =>
                              _buildLine('A', lineA, Colors.blueAccent, _blinkController.value),
                        ),
                        const SizedBox(height: 20),
                        AnimatedBuilder(
                          animation: _blinkController,
                          builder: (_, __) =>
                              _buildLine('B', lineB, Colors.greenAccent, _blinkController.value),
                        ),
                      ],
                    ),
                  ),
                ] else ...[
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: 1),
                    duration: const Duration(milliseconds: 800),
                    curve: Curves.easeOutBack,
                    builder: (_, value, __) {
                      return Transform.rotate(
                        angle: 2 * pi * (1 - value) / 10,
                        child: CustomPaint(
                          size: const Size(180, 180),
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

                // Nút đáp án
                Wrap(
                  spacing: 18,
                  runSpacing: 14,
                  alignment: WrapAlignment.center,
                  children: options.map((opt) {
                    return GestureDetector(
                      onTap: () => _check(opt),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(18),
                          gradient: const LinearGradient(
                            colors: [Color(0xFF5E2CED), Color(0xFFFF8B00)],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF5E2CED).withOpacity(0.28 + glow * 0.22),
                              blurRadius: 12 + 8 * glow,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
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
                ),

                const SizedBox(height: 40),

                // Tiến độ
                Column(
                  children: [
                    Container(
                      width: size.width * 0.6,
                      height: 16,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: AnimatedFractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        duration: const Duration(milliseconds: 400),
                        widthFactor: (correctCount / 10).clamp(0.0, 1.0),
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFFFC300), Color(0xFFFF8B00)],
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Tiến độ: $correctCount / 10",
                      style: const TextStyle(
                        color: Color(0xFF5E2CED),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLine(String label, int length, Color color, double blink) {
    final glow = [
      Shadow(color: Colors.white.withOpacity(0.8), blurRadius: 6 + 6 * blink),
      Shadow(color: color.withOpacity(0.5), blurRadius: 10 + 8 * blink),
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "$label:",
          style: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.w900,
            color: Colors.yellowAccent,
            shadows: glow,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          width: length.toDouble().clamp(40, 260),
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
            color: Colors.deepPurple,
            shadows: glow,
          ),
        ),
      ],
    );
  }
}

/// 🕒 Đồng hồ với kim xoay mượt (kim phút cố định 12)
class _ClockPainter extends CustomPainter {
  final int hour;
  final double progress;
  _ClockPainter({required this.hour, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final bg = Paint()..color = Colors.white;
    final border = Paint()
      ..color = Colors.deepPurple
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;

    canvas.drawCircle(center, radius, bg);
    canvas.drawCircle(center, radius, border);

    // Số 1–12
    final tp = TextPainter(textAlign: TextAlign.center, textDirection: TextDirection.ltr);
    for (int i = 1; i <= 12; i++) {
      final angle = (i * 30) * pi / 180;
      final pos = Offset(
        center.dx + (radius - 20) * sin(angle),
        center.dy - (radius - 20) * cos(angle),
      );
      tp.text = const TextSpan(
        text: "",
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.deepPurple),
      );
      // Vẽ số
      final numTp = TextPainter(
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
        text: TextSpan(
          text: "$i",
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.deepPurple),
        ),
      )..layout();
      numTp.paint(canvas, pos - const Offset(6, 8));
    }

    // Kim giờ (đỏ)
    final paintHour = Paint()
      ..color = Colors.redAccent
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;

    // Tiến động từ 0 -> góc mục tiêu (cho animation mượt)
    final targetHourAngle = (hour % 12) * 30 * pi / 180;
    final hourAngle = targetHourAngle * progress;
    final hourEnd = Offset(
      center.dx + radius * 0.5 * sin(hourAngle),
      center.dy - radius * 0.5 * cos(hourAngle),
    );
    canvas.drawLine(center, hourEnd, paintHour);

    // Kim phút (xanh) đứng ở 12h
    final paintMinute = Paint()
      ..color = Colors.lightBlueAccent
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    final minuteEnd = Offset(center.dx, center.dy - radius * 0.75);
    canvas.drawLine(center, minuteEnd, paintMinute);

    // Tâm
    canvas.drawCircle(center, 5, Paint()..color = Colors.deepPurple);
  }

  @override
  bool shouldRepaint(covariant _ClockPainter old) =>
      old.progress != progress || old.hour != hour;
}
