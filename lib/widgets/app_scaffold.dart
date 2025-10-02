import 'package:flutter/material.dart';
import '../models/level.dart';

class AppScaffold extends StatefulWidget {
  final String title;
  final Widget body;
  final List<Widget>? actions;
  final Widget? floatingActionButton;
  final Widget? bottomNavigationBar;

  /// levels hiện tại (truyền từ màn MapScreen)
  final List<Level>? levels;
  final Function(List<Level>)? onLevelsChanged;

  const AppScaffold({
    super.key,
    required this.title,
    required this.body,
    this.actions,
    this.floatingActionButton,
    this.bottomNavigationBar,
    this.levels,
    this.onLevelsChanged,
  });

  @override
  State<AppScaffold> createState() => _AppScaffoldState();
}

class _AppScaffoldState extends State<AppScaffold> {
  void _goHome(BuildContext context) {
    Navigator.pushNamedAndRemoveUntil(context, "/", (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    final hour = DateTime.now().hour;
    final isNight = hour >= 18 || hour < 6;

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        elevation: 0,
        title: Text(
          widget.title,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            shadows: [Shadow(color: Colors.black26, blurRadius: 4)],
          ),
        ),
        actions: widget.actions,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isNight
                  ? [const Color(0xFF0D47A1), const Color(0xFF1A237E)]
                  : [const Color(0xFF81D4FA), const Color(0xFFF48FB1)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: widget.body,
      floatingActionButton: widget.floatingActionButton,

      /// 🔹 Bottom bar gọn lại (64px) + icon nhỏ hơn
      bottomNavigationBar: widget.bottomNavigationBar ??
          BottomAppBar(
            color: Colors.white,
            elevation: 8,
            child: SizedBox(
              height: 64,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildKidIconButton(
                    context: context,
                    color: Colors.deepPurpleAccent,
                    icon: Icons.home,
                    tooltip: "Trang chủ",
                    onTap: () => _goHome(context),
                  ),
                  _buildKidIconButton(
                    context: context,
                    color: Colors.pinkAccent,
                    icon: Icons.person,
                    tooltip: "Thành tích",
                    onTap: () => Navigator.pushNamed(context, "/profile"),
                  ),
                  _buildKidIconButton(
                    context: context,
                    color: Colors.orangeAccent,
                    icon: Icons.leaderboard,
                    tooltip: "Bảng xếp hạng",
                    onTap: () => Navigator.pushNamed(context, "/leaderboard"),
                  ),
                  _buildKidIconButton(
                    context: context,
                    color: Colors.lightBlueAccent,
                    icon: Icons.collections,
                    tooltip: "Bộ sưu tập huy hiệu",
                    onTap: () => Navigator.pushNamed(context, "/badges"),
                  ),
                ],
              ),
            ),
          ),
    );
  }

  /// 🔹 Nút pastel tròn + icon nhỏ (48x48, size 26)
  Widget _buildKidIconButton({
    required BuildContext context,
    required Color color,
    required IconData icon,
    required String tooltip,
    required VoidCallback onTap,
  }) {
    return Tooltip(
      message: tooltip,
      decoration: BoxDecoration(
        color: color.withOpacity(0.9),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.5),
            blurRadius: 6,
            spreadRadius: 1,
          )
        ],
      ),
      textStyle: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
      ),
      preferBelow: false,
      verticalOffset: 40,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedScale(
          scale: 1.0,
          duration: const Duration(milliseconds: 150),
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withOpacity(0.9),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.5),
                  blurRadius: 8,
                  spreadRadius: 2,
                )
              ],
            ),
            child: Icon(icon, size: 26, color: Colors.white),
          ),
        ),
      ),
    );
  }
}
