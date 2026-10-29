import 'package:flutter/material.dart';
import 'package:product_listing_demo/core/routing/app_routes.dart';

// For navigation without a BuildContext, e.g. when the session expires mid-request.
class AppNavigator {
  AppNavigator._();

  static final navigatorKey = GlobalKey<NavigatorState>();

  static void toLogin() {
    navigatorKey.currentState?.pushNamedAndRemoveUntil(AppRoutes.login, (route) => false);
  }
}
