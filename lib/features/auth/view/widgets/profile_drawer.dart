import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:product_listing_demo/features/auth/store/auth_session_store.dart';
import 'package:product_listing_demo/features/auth/view/widgets/user_avatar.dart';
import 'package:provider/provider.dart';

class ProfileDrawer extends StatelessWidget {
  const ProfileDrawer({super.key, required this.onLogout});

  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Drawer(
      width: 304.w,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Consumer<AuthSessionStore>(
              builder: (_, sessionStore, _) {
                final user = sessionStore.user;
                return Padding(
                  padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 20.h),
                  child: Row(
                    children: [
                      UserAvatar(user: user, radius: 28),
                      SizedBox(width: 14.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user?.fullName ?? '',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                            ),
                            if (user != null && user.username.isNotEmpty) ...[
                              SizedBox(height: 2.h),
                              Text(
                                '@${user.username}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.primary),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            const Divider(),
            const Spacer(),
            const Divider(),
            ListTile(
              contentPadding: EdgeInsets.symmetric(horizontal: 24.w),
              leading: Icon(Icons.logout, size: 24.r, color: theme.colorScheme.error),
              title: Text(
                'Log out',
                style: TextStyle(fontSize: 16.sp, color: theme.colorScheme.error, fontWeight: FontWeight.w600),
              ),
              onTap: onLogout,
            ),
            SizedBox(height: 8.h),
          ],
        ),
      ),
    );
  }
}
