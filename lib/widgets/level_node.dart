import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/level.dart';
import '../themes/app_theme.dart';

class LevelNode extends StatefulWidget {
  final Level level;
  final VoidCallback onTap;
  final bool isCenter;
  final bool isNight;

  const LevelNode({
    super.key,
    required this.level,
    required this.onTap,
    required this.isCenter,
    required this.isNight,
  });

  @override
  State<LevelNode> createState() => _LevelNodeState();
}

class _LevelNodeState extends State<LevelNode> with TickerProviderStateMixin {
  late final AnimationController _sparkleController;
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnim;

  bool _isVisible = true;

  @override
  void initState() {
    super.initState();

    // ✨ Sparkle animation quanh node
    _sparkleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();

    // 💓 Pulse animation (scale nhẹ)
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);

    // ✅ FIX: dùng Tween để giữ giá trị scale trong khoảng [0.95–1.05]
    _pulseAnim = Tween(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _sparkleController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  /// ✨ Hiệu ứng sparkle xoay quanh node
  Widget _buildSparkle(double radius, double speed, double size, Color color) {
    return AnimatedBuilder(
      animation: _sparkleController,
      builder: (context, child) {
        final angle = _sparkleController.value * 2 * pi * speed;
        final dx = cos(angle) * radius;
        final dy = sin(angle) * radius;
        return Transform.translate(
          offset: Offset(dx, dy),
          child: Icon(Icons.star_rounded, size: size, color: color),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLocked = widget.level.state == LevelState.locked;

    // 🌈 Gradient fintech chuẩn TPBank
    final gradient = isLocked
        ? const LinearGradient(colors: [Colors.grey, Colors.black26])
        : AppTheme.primaryGradient;

    Color glowColor;
    IconData icon;
    switch (widget.level.state) {
      case LevelState.completed:
        glowColor = Colors.greenAccent;
        icon = Icons.check_circle_rounded;
        break;
      case LevelState.playable:
        glowColor = AppTheme.tpOrange;
        icon = Icons.play_arrow_rounded;
        break;
      default:
        glowColor = Colors.grey;
        icon = Icons.lock_rounded;
        break;
    }

    return NotificationListener<ScrollNotification>(
      onNotification: (scroll) {
        // 🧠 Khi node không còn visible trên màn hình, tạm dừng animation
        final visible =
            scroll.metrics.pixels <= scroll.metrics.maxScrollExtent &&
                scroll.metrics.pixels >= scroll.metrics.minScrollExtent;
        if (_isVisible != visible) {
          setState(() => _isVisible = visible);
          if (visible) {
            _sparkleController.repeat();
            _pulseController.repeat(reverse: true);
          } else {
            _sparkleController.stop();
            _pulseController.stop();
          }
        }
        return false;
      },
      child: GestureDetector(
        onTap: isLocked
            ? null
            : () {
          HapticFeedback.lightImpact();
          widget.onTap();
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ScaleTransition(
              scale: widget.isCenter ? _pulseAnim : const AlwaysStoppedAnimation(1),
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: gradient,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.tpPurple.withOpacity(0.4),
                      blurRadius: widget.isCenter ? 40 : 20,
                      spreadRadius: widget.isCenter ? 8 : 3,
                    ),
                    BoxShadow(
                      color: AppTheme.tpOrange.withOpacity(0.3),
                      blurRadius: widget.isCenter ? 30 : 15,
                      spreadRadius: widget.isCenter ? 5 : 2,
                    ),
                  ],
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    if (!isLocked && _isVisible) ...[
                      _buildSparkle(55, 1.0, 8, Colors.white.withOpacity(0.7)),
                      _buildSparkle(75, -1.2, 10, Colors.yellowAccent.withOpacity(0.8)),
                      _buildSparkle(90, 0.8, 12, Colors.orangeAccent.withOpacity(0.6)),
                    ],
                    Container(
                      width: 88,
                      height: 88,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.07),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.25),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.white.withOpacity(0.15),
                            blurRadius: 12,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Icon(icon, color: Colors.white, size: 42),
                    ),
                    Positioned(
                      bottom: 10,
                      right: 10,
                      child: Icon(
                        widget.level.state == LevelState.locked
                            ? Icons.lock_rounded
                            : Icons.star_rounded,
                        color: widget.level.state == LevelState.locked
                            ? Colors.white24
                            : Colors.yellowAccent,
                        size: 22,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            AnimatedOpacity(
              opacity: widget.isCenter ? 1 : 0.7,
              duration: const Duration(milliseconds: 400),
              child: Text(
                widget.level.title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  fontSize: widget.isCenter ? 18 : 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      color: glowColor.withOpacity(0.8),
                      blurRadius: 10,
                    ),
                    const Shadow(
                      color: Colors.black54,
                      blurRadius: 4,
                      offset: Offset(1, 1),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
