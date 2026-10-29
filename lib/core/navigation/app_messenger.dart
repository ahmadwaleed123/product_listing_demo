import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppMessenger {
  AppMessenger._();

  static final scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

  static void showError(String? message) {
    _show(message ?? 'Something went wrong. Please try again.');
  }

  static void showSuccess(String message) {
    _show(message);
  }

  static void _show(String message) {
    final messenger = scaffoldMessengerKey.currentState;
    if (messenger == null || message.trim().isEmpty) return;

    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
          content: Text(message, style: TextStyle(fontSize: 14.sp)),
        ),
      );
  }
}
