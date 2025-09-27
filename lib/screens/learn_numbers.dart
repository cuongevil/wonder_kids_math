import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:confetti/confetti.dart';

class LearnNumbersScreen extends StatefulWidget {
  const LearnNumbersScreen({super.key});

  @override
  State<LearnNumbersScreen> createState() => _LearnNumbersScreenState();
}

class _LearnNumbersScreenState extends State<LearnNumbersScreen>
    with TickerProviderStateMixin {
  List<dynamic> numbers = [];
  int currentIndex = 0;
  int starCount = 0; // ⭐ đếm số sao
  final AudioPlayer _player = AudioPlayer();
  late ConfettiController _confettiController;

  final GlobalKey _speakerKey = GlobalKey(); // để lấy vị trí nút loa

  @override
  void initState() {
    super.initState();
    _loadNumbers();
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 2));
  }

  @override
  void dispose() {
    _player.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  Future<void> _loadNumbers() async {
    final String response =
    await rootBundle.loadString('assets/configs/numbers.json');
    final data = await json.decode(response);
    setState(() {
      numbers = data["numbers"];
    });
  }

  void _next() {
    if (currentIndex < numbers.length - 1) {
      setState(() => currentIndex++);
    } else {
      _confettiController.play();
    }
  }

  void _prev() {
    if (currentIndex > 0) {
      setState(() => currentIndex--);
    }
  }

  Future<void> _playAudio(int value) async {
    try {
      await _player.stop();
      await _player.play(
        AssetSource('audios/numbers/$value.mp3'),
      );

      // ⭐ trigger hiệu ứng star bay
      _spawnFlyingStar();

      // 🎉 confetti nhẹ
      if (_confettiController.state != ConfettiControllerState.playing) {
        _confettiController.play();
      }
    } catch (e) {
      debugPrint("❌ Lỗi phát audio: $e");
    }
  }

  void _spawnFlyingStar() {
    final overlay = Overlay.of(context);
    if (overlay == null) return;

    // Lấy vị trí nút loa
    final RenderBox renderBox =
    _speakerKey.currentContext!.findRenderObject() as RenderBox;
    final startOffset = renderBox.localToGlobal(Offset.zero);

    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (context) {
        return _FlyingStar(
          start: startOffset,
          end: const Offset(320, 40), // Góc trên phải gần bộ đếm sao
          vsync: this,
          onFinish: () {
            entry.remove();
            setState(() {
              starCount++; // ⭐ tăng đếm khi bay xong
            });
          },
        );
      },
    );

    overlay.insert(entry);
  }

  @override
  Widget build(BuildContext context) {
    if (numbers.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    final number = numbers[currentIndex];
    final progress = (currentIndex + 1) / numbers.length;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFDEBEB), Color(0xFFE3FDFD)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 🌈 Progress bar
                Padding(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 20,
                      valueColor:
                      const AlwaysStoppedAnimation<Color>(Colors.red),
                      backgroundColor: Colors.grey.shade200,
                    ),
                  ),
                ),

                // 🔢 Số
                AnimatedScale(
                  scale: 1.2,
                  duration: const Duration(milliseconds: 600),
                  curve: Curves.elasticOut,
                  child: Text(
                    number["value"].toString(),
                    style: const TextStyle(
                      fontSize: 120,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // 🐻 Mascot số
                Image.asset(
                  number["image"],
                  width: 180,
                  height: 180,
                ),
                const SizedBox(height: 20),

                // 📝 Tên số
                Text(
                  number["label"],
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 40),

                // 🎮 Điều khiển
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, size: 40),
                      onPressed: _prev,
                    ),
                    GestureDetector(
                      key: _speakerKey,
                      onTap: () => _playAudio(number["value"]),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.pink.shade100,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.pink.withOpacity(0.5),
                              blurRadius: 10,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: const Icon(Icons.volume_up,
                            size: 40, color: Colors.deepPurple),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.arrow_forward, size: 40),
                      onPressed: _next,
                    ),
                  ],
                ),
              ],
            ),

            // 🎉 Confetti
            ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              colors: const [
                Colors.red,
                Colors.blue,
                Colors.green,
                Colors.orange,
                Colors.purple,
              ],
            ),

            // ⭐ Bộ đếm sao góc trên phải
            Positioned(
              top: 40,
              right: 70,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.yellow.shade100,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.yellow.shade700.withOpacity(0.4),
                      blurRadius: 6,
                      offset: const Offset(2, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(Icons.star,
                        color: Colors.yellow.shade700, size: 28),
                    const SizedBox(width: 6),
                    Text(
                      "$starCount",
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 🔙 Back
            Positioned(
              top: 40,
              left: 16,
              child: _AnimatedCircleButton(
                icon: Icons.arrow_back,
                bgColor: Colors.pink.shade100,
                iconColor: Colors.deepPurple,
                onTap: () => Navigator.pop(context),
              ),
            ),

            // 🏠 Home
            Positioned(
              top: 40,
              right: 16,
              child: _AnimatedCircleButton(
                icon: Icons.home,
                bgColor: Colors.blue.shade100,
                iconColor: Colors.deepPurple,
                onTap: () {
                  Navigator.popUntil(context, (route) => route.isFirst);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ⭐ Widget star bay
class _FlyingStar extends StatefulWidget {
  final Offset start;
  final Offset end;
  final VoidCallback onFinish;
  final TickerProvider vsync;

  const _FlyingStar({
    required this.start,
    required this.end,
    required this.onFinish,
    required this.vsync,
  });

  @override
  State<_FlyingStar> createState() => _FlyingStarState();
}

class _FlyingStarState extends State<_FlyingStar> {
  late AnimationController _controller;
  late Animation<Offset> _position;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: widget.vsync, duration: const Duration(seconds: 1));
    _position = Tween<Offset>(
      begin: widget.start,
      end: widget.end,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _controller.forward().whenComplete(widget.onFinish);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _position,
      builder: (context, child) {
        return Positioned(
          left: _position.value.dx,
          top: _position.value.dy,
          child: Icon(Icons.star, color: Colors.yellow.shade600, size: 32),
        );
      },
    );
  }
}

/// 🔘 Nút tròn có animation scale
class _AnimatedCircleButton extends StatefulWidget {
  final IconData icon;
  final Color bgColor;
  final Color iconColor;
  final VoidCallback onTap;

  const _AnimatedCircleButton({
    required this.icon,
    required this.bgColor,
    required this.iconColor,
    required this.onTap,
  });

  @override
  State<_AnimatedCircleButton> createState() => _AnimatedCircleButtonState();
}

class _AnimatedCircleButtonState extends State<_AnimatedCircleButton> {
  double _scale = 1.0;

  void _onTapDown(_) => setState(() => _scale = 0.85);
  void _onTapUp(_) {
    setState(() => _scale = 1.0);
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: () => setState(() => _scale = 1.0),
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOutBack,
        child: Container(
          decoration: BoxDecoration(
            color: widget.bgColor,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 6,
                offset: const Offset(2, 2),
              ),
            ],
          ),
          padding: const EdgeInsets.all(12),
          child: Icon(
            widget.icon,
            size: 28,
            color: widget.iconColor,
          ),
        ),
      ),
    );
  }
}
