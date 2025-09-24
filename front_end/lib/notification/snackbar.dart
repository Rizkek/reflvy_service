import 'package:flutter/material.dart';

SnackBar buildSimpleSnackbar(String message) {
  return SnackBar(
    content: Text(message),
    behavior: SnackBarBehavior.floating,
    margin: const EdgeInsets.all(16),
    duration: const Duration(seconds: 3),
  );
}

void showSimpleSnackbar(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..removeCurrentSnackBar()
    ..showSnackBar(buildSimpleSnackbar(message));
}
