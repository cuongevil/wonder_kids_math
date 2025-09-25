import 'package:flutter/material.dart';
import 'screens/start_screen.dart';

void main() {
  runApp(const WonderKidsMathApp());
}

class WonderKidsMathApp extends StatelessWidget {
  const WonderKidsMathApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Wonder Kids Math',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const StartScreen(),
    );
  }
}
