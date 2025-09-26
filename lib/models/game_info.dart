import 'package:flutter/material.dart';

class GameInfo {
  final String id;
  final String title;
  final IconData icon;
  final Color color;
  final String route;
  final int total;

  const GameInfo({
    required this.id,
    required this.title,
    required this.icon,
    required this.color,
    required this.route,
    this.total = 0,
  });
}
