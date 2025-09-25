import 'package:flutter/material.dart';

class LearnNumbers extends StatelessWidget {
  LearnNumbers({super.key});

  final List<int> numbers = List.generate(100, (i) => i + 1);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Học số 1-100")),
      body: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 5,
          childAspectRatio: 1,
        ),
        itemCount: numbers.length,
        itemBuilder: (context, index) {
          final n = numbers[index];
          return Card(
            margin: const EdgeInsets.all(8),
            child: Center(
              child: Text(
                "$n",
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
            ),
          );
        },
      ),
    );
  }
}
