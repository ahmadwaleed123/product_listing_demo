import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.outlined = false,
    this.height = 52,
  });

  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool outlined;
  final double height;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final foreground = outlined ? colorScheme.primary : colorScheme.onPrimary;

    return SizedBox(
      width: double.infinity,
      height: height.h,
      child: AbsorbPointer(
        absorbing: isLoading,
        child: ElevatedButton(
          onPressed: isLoading ? () {} : onPressed,
          style: ElevatedButton.styleFrom(
            elevation: 0,
            backgroundColor: outlined ? colorScheme.surface : colorScheme.primary,
            foregroundColor: foreground,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.r),
              side: outlined ? BorderSide(color: colorScheme.primary) : BorderSide.none,
            ),
          ),
          child: isLoading
              ? SizedBox.square(
                  dimension: 22.r,
                  child: CircularProgressIndicator(strokeWidth: 2.4, color: foreground),
                )
              : Text(
                  text,
                  style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
                ),
        ),
      ),
    );
  }
}
