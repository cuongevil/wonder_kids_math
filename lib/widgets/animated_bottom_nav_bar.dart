import 'package:flutter/material.dart';
import '../themes/app_theme.dart';

/// 💫 AnimatedBottomNavBar — phiên bản 2025 đồng bộ AppShell Fintech
/// ✅ Hiệu ứng gradient tím–cam
/// ✅ Icon scale khi chọn
/// ✅ Nền mờ glass + bóng mềm
class AnimatedBottomNavBar extends StatefulWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  // Danh sách icon (nếu không truyền, dùng mặc định 4 tab)
  final List<IconData>? icons;

  // Cho phép tùy chỉnh gradient nền
  final Gradient? backgroundGradient;

  // Cho phép bật hiệu ứng glow
  final bool activeIconGlow;

  const AnimatedBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.icons,
    this.backgroundGradient,
    this.activeIconGlow = true,
  });

  @override
  State<AnimatedBottomNavBar> createState() => AnimatedBottomNavBarState();
}

class AnimatedBottomNavBarState extends State<AnimatedBottomNavBar>
    with SingleTickerProviderStateMixin {
  bool _visible = true;

  void show() => setState(() => _visible = true);
  void hide() => setState(() => _visible = false);

  @override
  Widget build(BuildContext context) {
    final icons = widget.icons ??
        const [
          Icons.map_rounded,
          Icons.emoji_events_rounded,
          Icons.person_rounded,
          Icons.settings_rounded,
        ];

    return AnimatedSlide(
      duration: const Duration(milliseconds: 400),
      offset: _visible ? Offset.zero : const Offset(0, 2),
      curve: Curves.easeOutCubic,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 300),
        opacity: _visible ? 1 : 0,
        curve: Curves.easeOut,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            gradient: widget.backgroundGradient ??
                const LinearGradient(
                  colors: [Color(0xFF5E2CED), Color(0xFFFF8B00)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.25),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(icons.length, (index) {
              final isActive = widget.currentIndex == index;
              return GestureDetector(
                onTap: () => widget.onTap(index),
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 1, end: isActive ? 1.25 : 1),
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOutBack,
                  builder: (_, scale, child) {
                    return Transform.scale(
                      scale: scale,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: widget.activeIconGlow && isActive
                              ? [
                            BoxShadow(
                              color: Colors.white.withOpacity(0.7),
                              blurRadius: 10,
                              spreadRadius: 2,
                            ),
                          ]
                              : [],
                        ),
                        child: ShaderMask(
                          shaderCallback: (rect) =>
                              AppTheme.primaryGradient.createShader(rect),
                          blendMode: BlendMode.srcIn,
                          child: Icon(
                            icons[index],
                            size: isActive ? 30 : 24,
                            color:
                            isActive ? Colors.white : Colors.white70,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
