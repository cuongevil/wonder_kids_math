import 'package:flutter/material.dart';

import '../widgets/app_scaffold.dart';

class BaseScreen extends StatelessWidget {
  final String title;
  final Widget child;
  final Widget? fab;

  const BaseScreen({
    super.key,
    required this.title,
    required this.child,
    this.fab,
  });

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: title,
      body: Padding(
        padding: EdgeInsets.only(
          top: kToolbarHeight + MediaQuery.of(context).padding.top + 16,
          left: 8,
          right: 8,
        ),
        child: child,
      ),
      floatingActionButton: fab,
    );
  }
}
