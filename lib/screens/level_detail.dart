import 'dart:math';
import 'dart:ui';

import 'package:audioplayers/audioplayers.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';

import '../models/level.dart';
import '../services/progress_service.dart';
import '../themes/app_theme.dart';

class LevelDetail extends StatefulWidget {
  static const routeName = '/level_detail';

  const LevelDetail({super.key});

  @override
  State<LevelDetail> createState() => _LevelDetailState();
}

class _LevelDetailState extends State<LevelDetail>
    with TickerProviderStateMixin {
  late ConfettiController _confettiController;
  late AnimationController _bounceController;
  late AnimationController _sparkleController;
  late AnimationController _glowController;
  late AnimationController _gradientController;
  late AnimationController _starController;
  final AudioPlayer _player = AudioPlayer();

  Level? _currentLevel;
  int? _levelIndex;
  List<Level> _levels = [];
  bool _argsParsed = false;

  @override
  void initState() {
    super.initState();

    _confettiController = ConfettiController(
      duration: const Duration(seconds: 3),
    );
    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
      lowerBound: 0.9,
      upperBound: 1.1,
    )..repeat(reverse: true);

    _sparkleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
      lowerBound: 0.7,
      upperBound: 1.0,
    )..repeat(reverse: true);

    _gradientController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat(reverse: true);

    _starController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();

    Future.delayed(const Duration(milliseconds: 300), () async {
      if (!mounted) return;
      _confettiController.play();
      await _player.play(AssetSource("audios/welcome.mp3"));
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_argsParsed) return;
    _argsParsed = true;
    _parseArgsAndLoad();
  }

  Future<void> _parseArgsAndLoad() async {
    final loaded = await ProgressService.loadLevels();
    _levels = loaded.isEmpty
        ? await ProgressService.ensureDefaultLevels(() => [])
        : loaded;

    final arg = ModalRoute.of(context)?.settings.arguments;
    if (arg is Level) {
      _currentLevel = arg;
      _levelIndex = arg.index;
    } else if (arg is int) {
      _levelIndex = arg;
      if (_levelIndex! >= 0 && _levelIndex! < _levels.length) {
        _currentLevel = _levels[_levelIndex!];
      }
    }

    _currentLevel ??= _levels.isNotEmpty
        ? _levels.first
        : Level(
            index: 0,
            title: 'Bắt đầu',
            type: LevelType.start,
            state: LevelState.playable,
            levelKey: 'start',
          );

    _levelIndex ??= _currentLevel?.index ?? 0;

    if (_currentLevel!.state == LevelState.locked) {
      _currentLevel!.state = LevelState.playable;
      await ProgressService.updateLevelState(
        _currentLevel!.index,
        LevelState.playable,
      );
    }

    await ProgressService.saveLevels(_levels);

    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _bounceController.dispose();
    _sparkleController.dispose();
    _confettiController.dispose();
    _glowController.dispose();
    _gradientController.dispose();
    _starController.dispose();
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isStartLevel =
        (_currentLevel?.levelKey == "start") || (_levelIndex == 0);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          _buildAnimatedBackground(),
          IgnorePointer(ignoring: true, child: _buildParallaxStars()),
          IgnorePointer(
            ignoring: true,
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [Colors.white.withOpacity(0.08), Colors.transparent],
                  radius: 0.85,
                ),
              ),
            ),
          ),
          Center(
            child: isStartLevel
                ? _buildStartScreen(context)
                : _buildNormalLevel(context),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              numberOfParticles: 25,
              gravity: 0.3,
              colors: const [
                Color(0xFF5E2CED),
                Color(0xFFA58CFF),
                Color(0xFFFF8B00),
                Colors.white,
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedBackground() {
    return AnimatedBuilder(
      animation: _gradientController,
      builder: (context, _) {
        final t = _gradientController.value;
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color.lerp(
                  const Color(0xFF5E2CED),
                  const Color(0xFFFF8B00),
                  t,
                )!,
                Color.lerp(
                  const Color(0xFF2B0C69),
                  const Color(0xFF5E2CED),
                  1 - t,
                )!,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        );
      },
    );
  }

  // 🌌 Hiệu ứng sao nền
  Widget _buildParallaxStars() {
    final size = MediaQuery.of(context).size;
    final Random rand = Random();
    final stars = List.generate(
      100,
      (_) => Offset(rand.nextDouble(), rand.nextDouble()),
    );
    return AnimatedBuilder(
      animation: _starController,
      builder: (context, _) {
        final paint = Paint()..color = Colors.white.withOpacity(0.8);
        return CustomPaint(
          painter: _StarPainter(stars, _starController.value, size, paint),
          size: size,
        );
      },
    );
  }

  Widget _buildStartScreen(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              _buildSparkle(80, 1.0, const Color(0xFFFF8B00)),
              _buildSparkle(60, -1.5, const Color(0xFF5E2CED)),
              ScaleTransition(
                scale: _bounceController,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(100),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withOpacity(0.15),
                          width: 1.5,
                        ),
                      ),
                      child: Image.asset(
                        "assets/images/mascot/mascot_10.png",
                        width: 160,
                        height: 160,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          ShaderMask(
            shaderCallback: (rect) =>
                AppTheme.primaryGradient.createShader(rect),
            child: const Text(
              "Xin chào 👋",
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            "Cùng học số và phép tính thật vui nhé!",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18, color: Colors.white70),
          ),
          const SizedBox(height: 50),
          _buildActionButton(
            label: "Bắt đầu thôi!",
            icon: Icons.play_arrow_rounded,
            color: AppTheme.tpPurple,
            onPressed: () async {
              _confettiController.play();
              await _player.play(AssetSource("audios/crown.mp3"));
              await Future.delayed(const Duration(milliseconds: 600));
              await ProgressService.markLevelCompleted("start");
              if (!mounted) return;
              Navigator.pop(context, true);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNormalLevel(BuildContext context) {
    final level = _currentLevel;
    if (level == null) return const SizedBox();
    final isCompleted = level.state == LevelState.completed;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ShaderMask(
            shaderCallback: (rect) =>
                AppTheme.primaryGradient.createShader(rect),
            child: Text(
              level.title,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            isCompleted
                ? "Bạn đã hoàn thành màn này 🎉"
                : "Chưa có nội dung game cụ thể.\nBạn có thể hoàn thành thủ công.",
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16, color: Colors.white70),
          ),
          const SizedBox(height: 30),
          _buildActionButton(
            label: isCompleted ? "Quay lại bản đồ" : "Hoàn thành Level",
            icon: isCompleted ? Icons.check_circle : Icons.flag_rounded,
            color: isCompleted ? Colors.grey : AppTheme.tpOrange,
            onPressed: () async {
              if (isCompleted) {
                Navigator.pop(context, true);
                return;
              }
              _confettiController.play();
              await _player.play(AssetSource("audios/crown.mp3"));
              await Future.delayed(const Duration(milliseconds: 500));
              await ProgressService.markLevelCompleted(level.levelKey!);
              if (!mounted) return;
              Navigator.pop(context, true);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return AnimatedBuilder(
      animation: _glowController,
      builder: (context, child) {
        final glow = _glowController.value;
        return Container(
          decoration: BoxDecoration(
            gradient: AppTheme.primaryGradient,
            borderRadius: BorderRadius.circular(40),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.4 * glow),
                blurRadius: 25 * glow,
              ),
              BoxShadow(
                color: AppTheme.tpOrange.withOpacity(0.3 * glow),
                blurRadius: 20 * glow,
              ),
            ],
          ),
          child: ElevatedButton.icon(
            icon: Icon(icon, color: Colors.white, size: 26),
            label: Text(
              label,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              minimumSize: const Size(220, 60),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(40),
              ),
            ),
            onPressed: onPressed,
          ),
        );
      },
    );
  }

  Widget _buildSparkle(double radius, double speed, Color color) {
    return AnimatedBuilder(
      animation: _sparkleController,
      builder: (context, child) {
        final angle = _sparkleController.value * 2 * pi * speed;
        final dx = cos(angle) * radius;
        final dy = sin(angle) * radius;
        return Transform.translate(
          offset: Offset(dx, dy),
          child: Icon(Icons.star, color: color.withOpacity(0.8), size: 16),
        );
      },
    );
  }
}

class _StarPainter extends CustomPainter {
  final List<Offset> stars;
  final double progress;
  final Size size;
  final Paint paintObj;

  _StarPainter(this.stars, this.progress, this.size, this.paintObj);

  @override
  void paint(Canvas canvas, Size _) {
    for (final s in stars) {
      final dx =
          (s.dx * size.width + sin(progress * 2 * pi + s.dy * 5) * 10) %
          size.width;
      final dy =
          (s.dy * size.height + cos(progress * 2 * pi + s.dx * 5) * 10) %
          size.height;
      canvas.drawCircle(Offset(dx, dy), 1.3, paintObj);
    }
  }

  @override
  bool shouldRepaint(_) => true;
}
