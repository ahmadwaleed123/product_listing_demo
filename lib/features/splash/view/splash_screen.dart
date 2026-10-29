import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:product_listing_demo/core/config/app_constants.dart';
import 'package:product_listing_demo/core/di/service_locator.dart';
import 'package:product_listing_demo/core/routing/app_routes.dart';
import 'package:product_listing_demo/features/auth/repository/auth_repository.dart';
import 'package:product_listing_demo/features/auth/store/auth_session_store.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  static const _minimumDisplay = Duration(milliseconds: 800);
  static const _profileTimeout = Duration(seconds: 8);

  @override
  void initState() {
    super.initState();
    _start();
  }

  Future<void> _start() async {
    final sessionStore = locator<AuthSessionStore>();

    if (sessionStore.isLoggedIn) {
      await Future.wait([
        locator<AuthRepository>().loadProfile().timeout(_profileTimeout, onTimeout: () => null),
        Future<void>.delayed(_minimumDisplay),
      ]);
    } else {
      await Future<void>.delayed(_minimumDisplay);
    }

    // A rejected refresh token ends the session while the profile is loading.
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, sessionStore.isLoggedIn ? AppRoutes.products : AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: colorScheme.primary,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.storefront_outlined, size: 72.r, color: colorScheme.onPrimary),
              SizedBox(height: 16.h),
              Text(
                AppConstants.appName,
                style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.w700, color: colorScheme.onPrimary),
              ),
              SizedBox(height: 32.h),
              SizedBox.square(
                dimension: 24.r,
                child: CircularProgressIndicator(strokeWidth: 2.4, color: colorScheme.onPrimary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
