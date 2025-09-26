import 'package:flutter/material.dart';

class LearningInfo {
  final String id;
  final String title;
  final IconData icon;
  final List<Color> gradient;
  final String route;
  final int total;

  const LearningInfo({
    required this.id,
    required this.title,
    required this.icon,
    required this.gradient,
    required this.route,
    this.total = 0,
  });
}
