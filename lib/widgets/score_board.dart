import 'package:flutter/material.dart';
class ScoreBoard extends StatelessWidget {
  final int totalCorrect; final int streak;
  const ScoreBoard({super.key, required this.totalCorrect, required this.streak});
  @override Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceAround,
    children: [_item("👑", totalCorrect), _item("⭐", streak)],
  );
  Widget _item(String icon, int v)=> Row(children:[Text(icon, style: const TextStyle(fontSize:28)), const SizedBox(width:6), Text("$v", style: const TextStyle(fontSize:24, fontWeight: FontWeight.bold))]);
}
