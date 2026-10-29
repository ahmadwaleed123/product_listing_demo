import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class StateView extends StatelessWidget {
  const StateView({super.key, required this.icon, required this.title, this.message, this.actionText, this.onAction});

  final IconData icon;
  final String title;
  final String? message;
  final String? actionText;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.r),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 56.r, color: theme.colorScheme.onSurfaceVariant),
            SizedBox(height: 16.h),
            Text(title, style: theme.textTheme.titleMedium, textAlign: TextAlign.center),
            if (message != null) ...[
              SizedBox(height: 6.h),
              Text(
                message!,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              ),
            ],
            if (onAction != null) ...[
              SizedBox(height: 20.h),
              OutlinedButton(onPressed: onAction, child: Text(actionText ?? 'Try again')),
            ],
          ],
        ),
      ),
    );
  }
}
