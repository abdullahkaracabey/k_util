import 'package:flutter/material.dart';

class Snack {
  static showInfoSnack(BuildContext context, String text,
      {Duration? duration}) {
    var textTheme = Theme.of(context).textTheme;
    SnackBar snackBar = SnackBar(
        duration: duration ?? const Duration(seconds: 4),
        content: Text(
          text,
          style: textTheme.bodyLarge!.copyWith(
              fontWeight: FontWeight.w800, fontSize: 14.0, color: Colors.white),
        ));

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
