import 'package:flutter/material.dart';

class AvoidKeyboard extends StatelessWidget {
  final Widget child;

  const AvoidKeyboard({super.key, required this.child});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: child,
    );
  }
}
