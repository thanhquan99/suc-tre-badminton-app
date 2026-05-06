import 'user_role.dart';

class AuthUser {
  final String id;
  final String username;
  final String displayName;
  final UserRole role;
  final bool isActive;

  const AuthUser({
    required this.id,
    required this.username,
    required this.displayName,
    required this.role,
    required this.isActive,
  });

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      id: json['id'] as String,
      username: json['username'] as String,
      displayName: json['displayName'] as String,
      role: UserRole.fromJson(json['role'] as String),
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'username': username,
        'displayName': displayName,
        'role': role.toJson(),
        'isActive': isActive,
      };

  AuthUser copyWith({String? displayName, bool? isActive}) => AuthUser(
        id: id,
        username: username,
        displayName: displayName ?? this.displayName,
        role: role,
        isActive: isActive ?? this.isActive,
      );
}
