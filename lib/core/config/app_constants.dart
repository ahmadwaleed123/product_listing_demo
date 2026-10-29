class AppConstants {
  static const appName = 'Product Listing';
  static const pageSize = 20;
  static const tokenLifetimeMins = 30;

  // DummyJSON test user, used to prefill the login form in debug builds.
  static const demoUsername = 'emilys';
  static const demoPassword = 'emilyspass';
}

class StorageKeys {
  static const accessToken = 'access_token';
  static const refreshToken = 'refresh_token';
}

class Apis {
  static const baseUrl = 'https://dummyjson.com';

  static const login = '/auth/login';
  static const refreshToken = '/auth/refresh';
  static const me = '/auth/me';
  static const products = '/products';
}
