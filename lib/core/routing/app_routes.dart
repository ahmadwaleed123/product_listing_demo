import 'package:flutter/material.dart';
import 'package:product_listing_demo/core/di/service_locator.dart';
import 'package:product_listing_demo/features/auth/view/login_screen.dart';
import 'package:product_listing_demo/features/products/model/product.dart';
import 'package:product_listing_demo/features/products/repository/products_repository.dart';
import 'package:product_listing_demo/features/products/store/products_store.dart';
import 'package:product_listing_demo/features/products/view/product_detail_screen.dart';
import 'package:product_listing_demo/features/products/view/products_screen.dart';
import 'package:product_listing_demo/features/splash/view/splash_screen.dart';
import 'package:provider/provider.dart';

class AppRoutes {
  static const splash = '/';
  static const login = '/login';
  static const products = '/products';
  static const productDetail = '/product-detail';

  static Map<String, WidgetBuilder> get routes {
    return {
      splash: (_) => const SplashScreen(),
      login: (_) => const LoginScreen(),
      products: (_) => ChangeNotifierProvider(
        create: (_) => ProductsStore(locator<ProductsRepository>())..load(),
        child: const ProductsScreen(),
      ),
      productDetail: (context) => ProductDetailScreen(product: ModalRoute.of(context)!.settings.arguments! as Product),
    };
  }
}
