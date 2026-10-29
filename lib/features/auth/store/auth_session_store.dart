import 'package:flutter/foundation.dart';
import 'package:product_listing_demo/core/storage/local_storage_service.dart';
import 'package:product_listing_demo/features/auth/model/auth_session.dart';
import 'package:product_listing_demo/features/auth/model/login_response.dart';

class AuthSessionStore extends ChangeNotifier {
  AuthSessionStore(this._storage);

  final LocalStorageService _storage;

  // Tokens stay in secure storage only, the profile is kept in memory.
  UserProfile? _user;
  UserProfile? get user => _user;

  bool get isLoggedIn => _storage.hasSession;

  void saveSession(AuthSession session, {UserProfile? user}) {
    _storage.saveTokens(accessToken: session.accessToken, refreshToken: session.refreshToken);
    if (user != null) setUser(user);
  }

  void setUser(UserProfile value) {
    _user = value;
    notifyListeners();
  }

  void clear() {
    _user = null;
    _storage.clearTokens();
    notifyListeners();
  }
}
