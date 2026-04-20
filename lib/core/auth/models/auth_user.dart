import 'user_role.dart';

class AuthUser {
  final String id;
  final String username;
  final String displayName;
  final UserRole role;

  const AuthUser({
    required this.id,
    required this.username,
    required this.displayName,
    required this.role,
  });

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      id: json['id'] as String,
      username: json['username'] as String,
      displayName: json['displayName'] as String,
      role: UserRole.fromJson(json['role'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'username': username,
        'displayName': displayName,
        'role': role.toJson(),
      };
}
