import 'package:flutter/material.dart';

/// Bảng màu pastel gradient cho 29 chữ cái tiếng Việt
class LetterColors {
  static LinearGradient getGradient(String char) {
    switch (char.toUpperCase()) {
      case "A":
        return _gradient(Colors.pink.shade100, Colors.pink.shade200);
      case "Ă":
        return _gradient(Colors.lightBlue.shade100, Colors.lightBlue.shade200);
      case "Â":
        return _gradient(Colors.orange.shade100, Colors.orange.shade200);
      case "B":
        return _gradient(Colors.yellow.shade100, Colors.yellow.shade200);
      case "C":
        return _gradient(Colors.green.shade100, Colors.green.shade200);
      case "D":
        return _gradient(Colors.purple.shade100, Colors.purple.shade200);
      case "Đ":
        return _gradient(Colors.red.shade100, Colors.red.shade200);
      case "E":
        return _gradient(Colors.teal.shade100, Colors.teal.shade200);
      case "Ê":
        return _gradient(Colors.indigo.shade100, Colors.indigo.shade200);
      case "G":
        return _gradient(Colors.cyan.shade100, Colors.cyan.shade200);
      case "H":
        return _gradient(Colors.lime.shade100, Colors.lime.shade200);
      case "I":
        return _gradient(Colors.deepOrange.shade100, Colors.deepOrange.shade200);
      case "K":
        return _gradient(Colors.blue.shade100, Colors.blue.shade200);
      case "L":
        return _gradient(Colors.amber.shade100, Colors.amber.shade200);
      case "M":
        return _gradient(Colors.lightGreen.shade100, Colors.lightGreen.shade200);
      case "N":
        return _gradient(Colors.deepPurple.shade100, Colors.deepPurple.shade200);
      case "O":
        return _gradient(Colors.brown.shade100, Colors.brown.shade200);
      case "Ô":
        return _gradient(Colors.pink.shade200, Colors.pink.shade300);
      case "Ơ":
        return _gradient(Colors.blueGrey.shade100, Colors.blueGrey.shade200);
      case "P":
        return _gradient(Colors.yellow.shade200, Colors.yellow.shade300);
      case "Q":
        return _gradient(Colors.green.shade200, Colors.green.shade300);
      case "R":
        return _gradient(Colors.purple.shade200, Colors.purple.shade300);
      case "S":
        return _gradient(Colors.orange.shade200, Colors.orange.shade300);
      case "T":
        return _gradient(Colors.teal.shade200, Colors.teal.shade300);
      case "U":
        return _gradient(Colors.indigo.shade200, Colors.indigo.shade300);
      case "Ư":
        return _gradient(Colors.cyan.shade200, Colors.cyan.shade300);
      case "V":
        return _gradient(Colors.lime.shade200, Colors.lime.shade300);
      case "X":
        return _gradient(Colors.red.shade200, Colors.red.shade300);
      case "Y":
        return _gradient(Colors.lightGreen.shade200, Colors.lightGreen.shade300);
      default:
        return _gradient(Colors.grey.shade200, Colors.grey.shade300);
    }
  }

  static LinearGradient _gradient(Color c1, Color c2) {
    return LinearGradient(
      colors: [c1, c2],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }
}
