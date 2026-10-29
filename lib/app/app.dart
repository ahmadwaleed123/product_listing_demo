import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:product_listing_demo/core/config/app_constants.dart';
import 'package:product_listing_demo/core/di/service_locator.dart';
import 'package:product_listing_demo/core/navigation/app_messenger.dart';
import 'package:product_listing_demo/core/navigation/app_navigator.dart';
import 'package:product_listing_demo/core/routing/app_routes.dart';
import 'package:product_listing_demo/core/theme/app_theme.dart';
import 'package:product_listing_demo/features/auth/store/auth_session_store.dart';
import 'package:product_listing_demo/features/auth/store/auth_store.dart';
import 'package:provider/provider.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: locator<AuthSessionStore>()),
        ChangeNotifierProvider.value(value: locator<AuthStore>()),
      ],
      child: ScreenUtilInit(
        designSize: const Size(402, 874),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) {
          return MaterialApp(
            title: AppConstants.appName,
            navigatorKey: AppNavigator.navigatorKey,
            scaffoldMessengerKey: AppMessenger.scaffoldMessengerKey,
            debugShowCheckedModeBanner: false,
            theme: AppTheme.theme,
            initialRoute: AppRoutes.splash,
            routes: AppRoutes.routes,
            builder: (context, child) => AnnotatedRegion<SystemUiOverlayStyle>(
              value: SystemUiOverlayStyle.dark,
              child: child ?? const SizedBox.shrink(),
            ),
          );
        },
      ),
    );
  }
}
