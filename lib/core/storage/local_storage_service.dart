import 'dart:async';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:product_listing_demo/core/config/app_constants.dart';

class LocalStorageService {
  LocalStorageService._();

  static final LocalStorageService instance = LocalStorageService._();

  final FlutterSecureStorage _storage = const FlutterSecureStorage(
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );

  Map<String, String> _data = {};

  // Loads everything into memory once at startup so reads stay synchronous.
  Future<void> init() async {
    _data = await _storage.readAll();
  }

  String? readString(String key) => _data[key];

  void writeString(String key, String value) {
    _data[key] = value;
    unawaited(_storage.write(key: key, value: value));
  }

  void remove(String key) {
    _data.remove(key);
    unawaited(_storage.delete(key: key));
  }

  void deleteAll() {
    _data = {};
    unawaited(_storage.deleteAll());
  }

  String get accessToken => _data[StorageKeys.accessToken] ?? '';

  String get refreshToken => _data[StorageKeys.refreshToken] ?? '';

  bool get hasSession => accessToken.isNotEmpty;

  void saveTokens({required String accessToken, required String refreshToken}) {
    writeString(StorageKeys.accessToken, accessToken);
    writeString(StorageKeys.refreshToken, refreshToken);
  }

  void clearTokens() {
    remove(StorageKeys.accessToken);
    remove(StorageKeys.refreshToken);
  }
}
