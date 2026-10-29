import 'package:product_listing_demo/core/config/app_constants.dart';
import 'package:product_listing_demo/core/network/api_client.dart';
import 'package:product_listing_demo/core/network/api_response.dart';
import 'package:product_listing_demo/features/auth/model/login_response.dart';

class AuthApi {
  AuthApi([ApiClient? client]) : _client = client ?? ApiClient.instance;

  final ApiClient _client;

  Future<(String?, LoginResponse?)> login({required String username, required String password}) {
    return _client
        .post(
          Apis.login,
          data: {'username': username, 'password': password, 'expiresInMins': AppConstants.tokenLifetimeMins},
          parser: LoginResponse.fromJson,
          requiresAuth: false,
        )
        .result;
  }

  Future<(String?, UserProfile?)> me() {
    return _client.get(Apis.me, parser: UserProfile.fromJson).result;
  }
}
