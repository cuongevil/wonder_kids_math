import 'package:flutter/material.dart';

class SubtractionScreen extends StatelessWidget {
  const SubtractionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Phép trừ")),
      body: const Center(
        child: Text("Nội dung học Phép trừ"),
      ),
    );
  }
}
