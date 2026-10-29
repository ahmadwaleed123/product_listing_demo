import 'package:product_listing_demo/core/network/api_response.dart';
import 'package:product_listing_demo/features/auth/model/auth_session.dart';

class LoginResponse {
  const LoginResponse({required this.session, required this.user});

  final AuthSession session;
  final UserProfile user;

  factory LoginResponse.fromJson(dynamic json) {
    final data = asJsonMap(json);
    return LoginResponse(
      session: AuthSession(
        accessToken: data['accessToken'] as String? ?? '',
        refreshToken: data['refreshToken'] as String? ?? '',
      ),
      user: UserProfile.fromJson(data),
    );
  }
}

class UserProfile {
  const UserProfile({
    required this.id,
    required this.username,
    required this.firstName,
    required this.lastName,
    this.email,
    this.image,
  });

  final int id;
  final String username;
  final String firstName;
  final String lastName;
  final String? email;
  final String? image;

  String get fullName => '$firstName $lastName'.trim();

  String get initials {
    final letters = [firstName, lastName].where((part) => part.isNotEmpty).map((part) => part[0]).join();
    if (letters.isNotEmpty) return letters.toUpperCase();
    return username.isNotEmpty ? username[0].toUpperCase() : '?';
  }

  factory UserProfile.fromJson(dynamic json) {
    final data = asJsonMap(json);
    return UserProfile(
      id: (data['id'] as num?)?.toInt() ?? 0,
      username: data['username'] as String? ?? '',
      firstName: data['firstName'] as String? ?? '',
      lastName: data['lastName'] as String? ?? '',
      email: data['email'] as String?,
      image: data['image'] as String?,
    );
  }
}
