import 'package:flutter/material.dart';

/// 🔹 Dùng ChangeNotifier để AppShell lắng nghe thay đổi toàn cục
class AppShellController extends ChangeNotifier {
  static final AppShellController instance = AppShellController._();
  AppShellController._();

  int _currentIndex = 0;
  int get currentIndex => _currentIndex;

  void changeTab(int index) {
    _currentIndex = index;
    notifyListeners();
  }
}
