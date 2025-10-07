import 'dart:math';
import 'package:flutter/material.dart';

/// 🧸 Widget linh vật dễ thương để cổ vũ bé.
/// Có 2 cảm xúc: vui (isHappy = true) và buồn (isHappy = false).
/// Hỗ trợ 2 chế độ:
/// 1️⃣ Có bong bóng lời nói: dùng constructor mặc định.
/// 2️⃣ Chỉ mascot: dùng WowMascot.only().
///
/// Ví dụ:
/// WowMascot(isHappy: true, message: "Bé giỏi quá!")
/// WowMascot.only(isHappy: false)

class WowMascot extends StatefulWidget {
  final bool isHappy;
  final String? message;
  final double scale;
  final bool animate;
  final bool showMessage;

  const WowMascot({
    super.key,
    required this.isHappy,
    required this.message,
    this.scale = 1.0,
    this.animate = true,
    this.showMessage = true,
  });

  /// 🧸 Dùng khi chỉ muốn hiển thị mascot (không có lời nói)
  const WowMascot.only({
    super.key,
    required this.isHappy,
    this.scale = 1.0,
    this.animate = true,
  })  : message = null,
        showMessage = false;

  @override
  State<WowMascot> createState() => _WowMascotState();
}

class _WowMascotState extends State<WowMascot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    if (widget.animate) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// 🖼️ Trả về đường dẫn ảnh mascot tương ứng cảm xúc
  String get _mascotAsset =>
      widget.isHappy ? 'assets/images/mascot/mascot_happy.png' : 'assets/images/mascot/mascot_sad.png';

  /// 🌈 Màu nền pastel tương ứng
  Color get _backgroundColor =>
      widget.isHappy ? Colors.pinkAccent.shade100 : Colors.blueAccent.shade100;

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: Tween(begin: 0.95, end: 1.05).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
      ),
      child: Transform.translate(
        offset: Offset(0, sin(_controller.value * pi * 2) * 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 🌈 Vòng tròn pastel + mascot
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _backgroundColor.withOpacity(0.6),
                boxShadow: [
                  BoxShadow(
                    color: _backgroundColor.withOpacity(0.4),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Image.asset(
                _mascotAsset,
                width: 80 * widget.scale,
                height: 80 * widget.scale,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.image_not_supported_outlined,
                  size: 40,
                  color: Colors.grey,
                ),
              ),
            ),

            // 🗨️ Bong bóng lời nói (tùy chọn)
            if (widget.showMessage && widget.message != null) ...[
              const SizedBox(height: 8),
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                margin: const EdgeInsets.only(top: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                      color: Colors.purpleAccent.withOpacity(0.4)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.purpleAccent.withOpacity(0.2),
                      blurRadius: 8,
                      spreadRadius: 2,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  widget.message!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16 * widget.scale,
                    color: Colors.deepPurple,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
