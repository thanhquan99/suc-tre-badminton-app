import '../../auth/models/auth_user.dart';

class CreateUserResponse {
  final AuthUser user;
  final String password;

  const CreateUserResponse({required this.user, required this.password});

  factory CreateUserResponse.fromJson(Map<String, dynamic> json) {
    return CreateUserResponse(
      user: AuthUser.fromJson(json['user'] as Map<String, dynamic>),
      password: json['password'] as String,
    );
  }
}
