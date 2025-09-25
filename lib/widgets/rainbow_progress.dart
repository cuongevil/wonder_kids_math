import 'package:flutter/material.dart';
class RainbowProgress extends StatelessWidget {
  final double progress; const RainbowProgress({super.key, required this.progress});
  @override Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal:16, vertical:8),
      child: LayoutBuilder(builder: (context, c){
        final barWidth = c.maxWidth; const starSize=20.0;
        final starX = (barWidth - starSize) * progress.clamp(0.0, 1.0);
        return Stack(alignment: Alignment.centerLeft, children:[
          Container(height:20, decoration: BoxDecoration(
            gradient: const LinearGradient(colors:[Colors.red, Colors.orange, Colors.yellow, Colors.green, Colors.blue, Colors.purple]),
            borderRadius: BorderRadius.circular(12),
          )),
          Positioned(left: starX, child: const Icon(Icons.star, size: starSize, color: Colors.white)),
        ]);
      }),
    );
  }
}
