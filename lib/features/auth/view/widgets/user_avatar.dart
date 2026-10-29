import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:product_listing_demo/features/auth/model/login_response.dart';

class UserAvatar extends StatelessWidget {
  const UserAvatar({super.key, required this.user, this.radius = 18});

  final UserProfile? user;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final user = this.user;

    return CircleAvatar(
      radius: radius.r,
      backgroundColor: colorScheme.primary,
      foregroundColor: colorScheme.onPrimary,
      child: user == null
          ? Icon(Icons.person_outline, size: radius.r)
          : Text(
              user.initials,
              style: TextStyle(fontSize: (radius * 0.75).sp, fontWeight: FontWeight.w600),
            ),
    );
  }
}
