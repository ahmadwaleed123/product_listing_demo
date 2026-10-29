import 'package:flutter/foundation.dart';
import 'package:product_listing_demo/core/config/app_constants.dart';
import 'package:product_listing_demo/core/navigation/app_messenger.dart';
import 'package:product_listing_demo/features/auth/repository/auth_repository.dart';

class AuthStore extends ChangeNotifier {
  AuthStore(this._repository);

  final AuthRepository _repository;

  static const _prefillUsername = kDebugMode ? AppConstants.demoUsername : '';
  static const _prefillPassword = kDebugMode ? AppConstants.demoPassword : '';

  String _username = _prefillUsername;
  String get username => _username;

  String _password = _prefillPassword;
  String get password => _password;

  bool _obscurePassword = true;
  bool get obscurePassword => _obscurePassword;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool get canSubmit => _username.trim().isNotEmpty && _password.isNotEmpty && !_isLoading;

  void setUsername(String value) {
    _username = value;
    notifyListeners();
  }

  void setPassword(String value) {
    _password = value;
    notifyListeners();
  }

  void togglePasswordVisibility() {
    _obscurePassword = !_obscurePassword;
    notifyListeners();
  }

  Future<bool> login() async {
    if (!canSubmit) return false;

    _isLoading = true;
    notifyListeners();

    final (message, data) = await _repository.login(username: _username.trim(), password: _password);

    _isLoading = false;
    if (data != null) _password = _prefillPassword;
    notifyListeners();

    if (data != null) return true;
    AppMessenger.showError(message);
    return false;
  }

  void logout() {
    _repository.logout();
    _username = _prefillUsername;
    _password = _prefillPassword;
    notifyListeners();
  }
}
