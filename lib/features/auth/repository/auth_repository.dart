import 'package:product_listing_demo/features/auth/api/auth_api.dart';
import 'package:product_listing_demo/features/auth/model/login_response.dart';
import 'package:product_listing_demo/features/auth/store/auth_session_store.dart';

class AuthRepository {
  AuthRepository({required AuthApi authApi, required AuthSessionStore sessionStore})
    : _authApi = authApi,
      _sessionStore = sessionStore;

  final AuthApi _authApi;
  final AuthSessionStore _sessionStore;

  Future<(String?, LoginResponse?)> login({required String username, required String password}) async {
    final (message, data) = await _authApi.login(username: username, password: password);
    if (data == null || !data.session.hasAccessToken) {
      return (message ?? 'Unable to sign in. Please try again.', null);
    }

    _sessionStore.saveSession(data.session, user: data.user);
    return (null, data);
  }

  Future<UserProfile?> loadProfile() async {
    final (_, user) = await _authApi.me();
    if (user != null) _sessionStore.setUser(user);
    return user;
  }

  void logout() => _sessionStore.clear();
}
