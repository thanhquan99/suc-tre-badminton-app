import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'auth_api_client.dart';
import 'auth_providers.dart';
import 'auth_state.dart';
import 'token_storage.dart';

part 'auth_notifier.g.dart';

@Riverpod(keepAlive: true)
class AuthNotifier extends _$AuthNotifier {
  AuthApiClient get _api => ref.read(authApiClientProvider);
  TokenStorage get _storage => ref.read(tokenStorageProvider);

  Future<String?>? _refreshInFlight;

  @override
  AuthState build() => const AuthInitial();

  Future<void> bootstrap() async {
    final stored = await _storage.readRefreshToken();
    if (stored == null || stored.isEmpty) {
      state = const AuthUnauthenticated();
      return;
    }
    try {
      final tokens = await _api.refresh(stored);
      await _storage.writeRefreshToken(tokens.refreshToken);
      state = AuthAuthenticated(
        user: tokens.user,
        accessToken: tokens.accessToken,
      );
    } catch (_) {
      await _storage.clear();
      state = const AuthUnauthenticated();
    }
  }

  Future<void> login(String username, String password) async {
    final tokens = await _api.login(username, password);
    await _storage.writeRefreshToken(tokens.refreshToken);
    state = AuthAuthenticated(
      user: tokens.user,
      accessToken: tokens.accessToken,
    );
  }

  Future<void> logout() async {
    final current = state;
    final stored = await _storage.readRefreshToken();
    if (stored != null && current is AuthAuthenticated) {
      try {
        await _api.logout(stored, accessToken: current.accessToken);
      } on DioException {
        // best-effort: local state flip proceeds regardless
      }
    }
    await _storage.clear();
    state = const AuthUnauthenticated();
  }

  /// Returns a new access token on success, or null on failure.
  /// Single-flight: concurrent callers await the same in-flight future.
  Future<String?> refreshAccessToken() {
    final existing = _refreshInFlight;
    if (existing != null) return existing;
    final fut = _performRefresh();
    _refreshInFlight = fut;
    fut.whenComplete(() {
      _refreshInFlight = null;
    });
    return fut;
  }

  Future<String?> _performRefresh() async {
    final stored = await _storage.readRefreshToken();
    if (stored == null || stored.isEmpty) {
      await _storage.clear();
      state = const AuthUnauthenticated();
      return null;
    }
    try {
      final tokens = await _api.refresh(stored);
      await _storage.writeRefreshToken(tokens.refreshToken);
      state = AuthAuthenticated(
        user: tokens.user,
        accessToken: tokens.accessToken,
      );
      return tokens.accessToken;
    } catch (_) {
      await _storage.clear();
      state = const AuthUnauthenticated();
      return null;
    }
  }
}
