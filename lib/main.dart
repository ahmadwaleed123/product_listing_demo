import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:product_listing_demo/app/app.dart';
import 'package:product_listing_demo/core/di/service_locator.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  await setupServiceLocator();
  runApp(const App());
}
