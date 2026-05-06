import 'models/auth_user.dart';

sealed class AuthState {
  const AuthState();
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

class AuthAuthenticated extends AuthState {
  final AuthUser user;
  final String accessToken;

  const AuthAuthenticated({
    required this.user,
    required this.accessToken,
  });

  AuthAuthenticated copyWith({AuthUser? user, String? accessToken}) {
    return AuthAuthenticated(
      user: user ?? this.user,
      accessToken: accessToken ?? this.accessToken,
    );
  }
}
