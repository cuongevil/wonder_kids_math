import 'dart:math';
import 'package:flutter/material.dart';

class AnimatedBackground extends StatefulWidget {
  final Widget child;
  final String currentLetter;

  const AnimatedBackground({
    super.key,
    required this.child,
    required this.currentLetter,
  });

  @override
  State<AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<Widget> _buildFallingEmojis(String letter) {
    final emojis = letterEmojis[letter] ?? ["✨", "☁️"];
    final items = <Widget>[];

    for (int i = 0; i < 16; i++) {
      final emoji = emojis[i % emojis.length];

      // đa dạng kích thước & tốc độ
      final size = [20.0, 28.0, 36.0, 44.0][_random.nextInt(4)];
      final speed = 0.5 + _random.nextDouble() * 1.5; // tốc độ rơi
      final opacityFactor = 0.4 + _random.nextDouble() * 0.6;

      final startX = _random.nextDouble() * MediaQuery.of(context).size.width;
      final delay = _random.nextDouble();
      final rotationDirection = _random.nextBool() ? 1 : -1;
      final amplitude = 20 + _random.nextDouble() * 40; // biên độ lắc ngang

      items.add(
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final value = (_controller.value + delay) % 1.0;

            // vị trí rơi
            final top = MediaQuery.of(context).size.height * value * speed - 50;
            final left = startX + amplitude * sin(value * 2 * pi);

            // xoay nhẹ khi rơi
            final rotation = value * 2 * pi * 0.05 * rotationDirection;

            return Positioned(
              top: top,
              left: left,
              child: Opacity(
                opacity: (1.0 - value) * opacityFactor,
                child: Transform.rotate(
                  angle: rotation,
                  child: Text(emoji, style: TextStyle(fontSize: size)),
                ),
              ),
            );
          },
        ),
      );
    }
    return items;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // nền gradient pastel
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFFFF1F3), Color(0xFFD1E9FF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        widget.child,
        ..._buildFallingEmojis(widget.currentLetter),
      ],
    );
  }
}

/// Emoji mapping cơ bản
final Map<String, List<String>> letterEmojis = {
  "A": ["👕", "🧥"], // Áo
  "Ă": ["🍽️", "🍚"], // Ăn
  "Â": ["🍵", "🔥"], // Ấm
  "B": ["👶", "🎈"], // Bé, Bóng
  "C": ["🐟", "🐶"], // Cá, Cún
  "D": ["🐐", "🍉"], // Dê, Dưa
  "Đ": ["🏮", "🧊"], // Đèn, Đá
  "E": ["👧", "🐦"], // Em, Én
  "Ê": ["🛏️", "🐸"], // Êm, Ếch
  "G": ["🐔", "🪵"], // Gà, Gỗ
  "H": ["🌸", "📖"], // Hoa, Học
  "I": ["➖", "🖨️"], // Ít, In
  "K": ["🍬", "🔑"], // Kẹo, Khóa
  "L": ["🍃", "🍐"], // Lá, Lê
  "M": ["👩", "🐱"], // Mẹ, Mèo
  "N": ["🎀", "👒"], // Nơ, Nón
  "O": ["🐝", "🍯"], // Ong, Mật
  "Ô": ["🚗", "☂️"], // Ô tô, Ô (dù)
  "Ơ": ["🗣️", "🏠"], // Ơi, Ở
  "P": ["🍜", "☕"], // Phở, Phin
  "Q": ["🍎", "🪭"], // Quả, Quạt
  "R": ["🐢", "🌳"], // Rùa, Rừng
  "S": ["⭐", "📚"], // Sao, Sách
  "T": ["🍤", "🍎"], // Tôm, Táo
  "U": ["👶", "🥤"], // Út, Uống
  "Ư": ["🌠", "💭"], // Ước, Ưu
  "V": ["🐘", "🌿"], // Voi, Vườn
  "X": ["🥭", "🚲"], // Xoài, Xe
  "Y": ["❤️", "💡"], // Yêu, Ý
};
