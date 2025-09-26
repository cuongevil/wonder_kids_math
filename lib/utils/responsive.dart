import 'dart:io' show Platform;
import 'package:flutter/material.dart';

class Responsive {
  final BuildContext context;
  Responsive(this.context);

  double get width => MediaQuery.of(context).size.width;
  double get height => MediaQuery.of(context).size.height;

  bool get isSmall => width < 600;   // phone
  bool get isMedium => width < 1024; // tablet
  bool get isLarge => width >= 1024; // desktop/web

  double wp(double percent) => width * percent / 100;
  double hp(double percent) => height * percent / 100;

  bool get isAndroid => Platform.isAndroid;
  bool get isIOS => Platform.isIOS;
}