import 'package:flutter/material.dart';

class NumbersScreen extends StatelessWidget {
  const NumbersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Số đếm 1-100")),
      body: const Center(
        child: Text("Nội dung học Số đếm"),
      ),
    );
  }
}
