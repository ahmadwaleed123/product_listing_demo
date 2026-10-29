import 'package:product_listing_demo/core/navigation/app_navigator.dart';
import 'package:product_listing_demo/core/network/api_client.dart';
import 'package:product_listing_demo/core/storage/local_storage_service.dart';
import 'package:product_listing_demo/features/auth/api/auth_api.dart';
import 'package:product_listing_demo/features/auth/repository/auth_repository.dart';
import 'package:product_listing_demo/features/auth/store/auth_session_store.dart';
import 'package:product_listing_demo/features/auth/store/auth_store.dart';
import 'package:product_listing_demo/features/products/api/products_api.dart';
import 'package:product_listing_demo/features/products/repository/products_repository.dart';

final locator = ServiceLocator();

Future<void> setupServiceLocator() async {
  await LocalStorageService.instance.init();

  locator.registerSingleton(AuthSessionStore(LocalStorageService.instance));

  ApiClient.instance.configure(
    onSessionExpired: () {
      locator<AuthSessionStore>().clear();
      AppNavigator.toLogin();
    },
  );

  // APIs
  locator.registerSingleton(AuthApi());
  locator.registerSingleton(ProductsApi());

  // Repositories
  locator.registerSingleton(AuthRepository(authApi: locator<AuthApi>(), sessionStore: locator<AuthSessionStore>()));
  locator.registerSingleton(ProductsRepository(productsApi: locator<ProductsApi>()));

  // Stores
  locator.registerSingleton(AuthStore(locator<AuthRepository>()));
}

class ServiceLocator {
  final Map<Type, Object> _instances = {};

  void registerSingleton<T extends Object>(T instance) {
    _instances[T] = instance;
  }

  T call<T extends Object>() {
    final instance = _instances[T];
    if (instance == null) {
      throw StateError('$T is not registered in ServiceLocator.');
    }
    return instance as T;
  }
}
