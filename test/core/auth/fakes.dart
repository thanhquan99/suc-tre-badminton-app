import 'package:badminton_app/core/auth/auth_api_client.dart';
import 'package:badminton_app/core/auth/models/auth_tokens.dart';
import 'package:badminton_app/core/auth/models/auth_user.dart';
import 'package:badminton_app/core/auth/models/user_role.dart';
import 'package:badminton_app/core/auth/token_storage.dart';
import 'package:dio/dio.dart';

class FakeTokenStorage implements TokenStorage {
  String? _current;
  int writeCount = 0;
  int clearCount = 0;

  FakeTokenStorage([this._current]);

  @override
  Future<String?> readRefreshToken() async => _current;

  @override
  Future<void> writeRefreshToken(String token) async {
    _current = token;
    writeCount++;
  }

  @override
  Future<void> clear() async {
    _current = null;
    clearCount++;
  }
}

AuthUser fakeUser({String role = 'admin'}) {
  return AuthUser(
    id: 'u1',
    username: 'admin',
    displayName: 'Administrator',
    role: UserRole.fromJson(role),
  );
}

AuthTokens fakeTokens({
  String access = 'access-1',
  String refresh = 'refresh-1',
  AuthUser? user,
}) {
  return AuthTokens(
    accessToken: access,
    refreshToken: refresh,
    user: user ?? fakeUser(),
  );
}

class FakeAuthApiClient implements AuthApiClient {
  int loginCalls = 0;
  int refreshCalls = 0;
  int logoutCalls = 0;
  AuthTokens? loginResult;
  AuthTokens? refreshResult;
  Object? loginError;
  Object? refreshError;

  @override
  Future<AuthTokens> login(String username, String password) async {
    loginCalls++;
    if (loginError != null) throw loginError!;
    return loginResult ?? fakeTokens();
  }

  @override
  Future<AuthTokens> refresh(String refreshToken) async {
    refreshCalls++;
    if (refreshError != null) throw refreshError!;
    return refreshResult ??
        fakeTokens(access: 'access-rotated', refresh: 'refresh-rotated');
  }

  @override
  Future<void> logout(String refreshToken, {required String accessToken}) async {
    logoutCalls++;
  }

  @override
  Future<AuthUser> me(String accessToken) async => fakeUser();
}

DioException dio401() {
  final req = RequestOptions(path: '/auth/refresh');
  return DioException(
    requestOptions: req,
    response: Response(requestOptions: req, statusCode: 401),
    type: DioExceptionType.badResponse,
  );
}
