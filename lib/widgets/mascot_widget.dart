import 'package:flutter/material.dart';
import '../models/mascot_mood.dart';
class MascotWidget extends StatelessWidget {
  final MascotMood mood; const MascotWidget({super.key, required this.mood});
  String _asset() {
    switch (mood) {
      case MascotMood.happy: return "assets/mascots/happy.png";
      case MascotMood.sad: return "assets/mascots/sad.png";
      case MascotMood.celebrate: return "assets/mascots/celebrate.png";
      case MascotMood.idle: default: return "assets/mascots/idle.png";
    }
  }
  @override Widget build(BuildContext context)=> Image.asset(_asset(), width:120, height:120);
}
