import 'package:flutter/material.dart';

import 'config/app_routes.dart';
import 'config/app_theme.dart';

class WonderKidsMathApp extends StatelessWidget {
  const WonderKidsMathApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Wonder Kids Math',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.system,
      initialRoute: AppRoutes.start,
      onGenerateRoute: AppRoutes.generateRoute,
    );
  }
}
