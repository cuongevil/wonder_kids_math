import 'package:flutter/material.dart';

class MapBackground extends StatefulWidget {
  final ScrollController scrollController;
  const MapBackground({super.key, required this.scrollController});

  @override
  State<MapBackground> createState() => _MapBackgroundState();
}

class _MapBackgroundState extends State<MapBackground> {
  late bool isNight;

  @override
  void initState() {
    super.initState();
    final hour = DateTime.now().hour;
    isNight = hour >= 18 || hour < 6;

    // ⏱️ Tự động check lại mỗi phút để chuyển day ↔ night
    Future.doWhile(() async {
      await Future.delayed(const Duration(minutes: 1));
      if (!mounted) return false;
      final hourNow = DateTime.now().hour;
      final newIsNight = hourNow >= 18 || hourNow < 6;
      if (newIsNight != isNight) {
        setState(() => isNight = newIsNight);
      }
      return mounted;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(seconds: 2),
      transitionBuilder: (child, animation) => FadeTransition(
        opacity: animation,
        child: child,
      ),
      child: isNight
          ? _NightBackground(
        key: const ValueKey('night'),
        scrollController: widget.scrollController,
      )
          : _DayBackground(
        key: const ValueKey('day'),
        scrollController: widget.scrollController,
      ),
    );
  }
}

/// 🌞 Ban ngày
class _DayBackground extends StatelessWidget {
  final ScrollController scrollController;
  const _DayBackground({super.key, required this.scrollController});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Gradient trời ban ngày
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFE1F5FE), Color(0xFFFFF9C4)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),

        // Sun
        Positioned(
          top: 80,
          left: MediaQuery.of(context).size.width / 2 - 60,
          child: Image.asset('assets/images/sun.png', width: 120),
        ),

        // Mây parallax
        _ParallaxClouds(controller: scrollController),

        // Núi
        const _Mountains(isNight: false),
      ],
    );
  }
}

/// 🌙 Ban đêm
class _NightBackground extends StatelessWidget {
  final ScrollController scrollController;
  const _NightBackground({super.key, required this.scrollController});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Gradient trời ban đêm
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF0D1B2A), Color(0xFF1B263B)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),

        // Moon
        Positioned(
          top: 80,
          left: MediaQuery.of(context).size.width / 2 - 60,
          child: Image.asset('assets/images/moon.png', width: 120),
        ),

        // Stars
        Positioned(
          top: 150,
          left: MediaQuery.of(context).size.width / 3,
          child: Image.asset('assets/images/stars.png', width: 100),
        ),

        // Núi
        const _Mountains(isNight: true),
      ],
    );
  }
}

/// 🏔️ Núi
class _Mountains extends StatelessWidget {
  final bool isNight;
  const _Mountains({required this.isNight});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Stack(
      children: [
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Image.asset(
            'assets/images/mountains_layer1.png',
            fit: BoxFit.cover,
            height: size.height * 0.3,
          ),
        ),
        Positioned(
          bottom: 50,
          left: 0,
          right: 0,
          child: Image.asset(
            'assets/images/mountains_layer2.png',
            fit: BoxFit.cover,
            height: size.height * 0.25,
            color: isNight
                ? Colors.white.withOpacity(0.1)
                : Colors.black.withOpacity(0.1),
            colorBlendMode: BlendMode.darken,
          ),
        ),
      ],
    );
  }
}

/// ☁️ Mây parallax (day only)
class _ParallaxClouds extends StatelessWidget {
  final ScrollController controller;
  const _ParallaxClouds({required this.controller});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        // ✅ Fix lỗi: check hasClients trước khi đọc offset
        final offset = controller.hasClients
            ? (controller.offset * 0.3) % MediaQuery.of(context).size.width
            : 0.0;

        return Stack(
          children: [
            Positioned(
              left: -offset,
              top: 100,
              child: Image.asset(
                'assets/images/cloud.png',
                width: 200,
                opacity: const AlwaysStoppedAnimation(0.7),
              ),
            ),
            Positioned(
              left: MediaQuery.of(context).size.width - offset,
              top: 200,
              child: Image.asset(
                'assets/images/cloud.png',
                width: 150,
                opacity: const AlwaysStoppedAnimation(0.5),
              ),
            ),
            Positioned(
              left: -offset * 1.5,
              top: 350,
              child: Image.asset(
                'assets/images/cloud.png',
                width: 250,
                opacity: const AlwaysStoppedAnimation(0.6),
              ),
            ),
          ],
        );
      },
    );
  }
}
