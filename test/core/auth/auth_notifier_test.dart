import 'package:badminton_app/core/auth/auth_notifier.dart';
import 'package:badminton_app/core/auth/auth_providers.dart';
import 'package:badminton_app/core/auth/auth_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fakes.dart';

ProviderContainer makeContainer({
  required FakeAuthApiClient api,
  required FakeTokenStorage storage,
}) {
  return ProviderContainer(
    overrides: [
      authApiClientProvider.overrideWithValue(api),
      tokenStorageProvider.overrideWithValue(storage),
    ],
  );
}

void main() {
  group('AuthNotifier', () {
    test('initial state is AuthInitial', () {
      final api = FakeAuthApiClient();
      final storage = FakeTokenStorage();
      final container = makeContainer(api: api, storage: storage);
      addTearDown(container.dispose);

      expect(container.read(authNotifierProvider), isA<AuthInitial>());
    });

    test('bootstrap with no stored token → Unauthenticated', () async {
      final api = FakeAuthApiClient();
      final storage = FakeTokenStorage();
      final container = makeContainer(api: api, storage: storage);
      addTearDown(container.dispose);

      await container.read(authNotifierProvider.notifier).bootstrap();
      expect(container.read(authNotifierProvider), isA<AuthUnauthenticated>());
      expect(api.refreshCalls, 0);
    });

    test('bootstrap with stored token → refresh succeeds → Authenticated',
        () async {
      final api = FakeAuthApiClient()
        ..refreshResult =
            fakeTokens(access: 'boot-access', refresh: 'boot-refresh');
      final storage = FakeTokenStorage('stored-token');
      final container = makeContainer(api: api, storage: storage);
      addTearDown(container.dispose);

      await container.read(authNotifierProvider.notifier).bootstrap();
      final s = container.read(authNotifierProvider);
      expect(s, isA<AuthAuthenticated>());
      expect((s as AuthAuthenticated).accessToken, 'boot-access');
      expect(await storage.readRefreshToken(), 'boot-refresh');
    });

    test('bootstrap with stored token → refresh fails → Unauthenticated + storage cleared',
        () async {
      final api = FakeAuthApiClient()..refreshError = dio401();
      final storage = FakeTokenStorage('stored-token');
      final container = makeContainer(api: api, storage: storage);
      addTearDown(container.dispose);

      await container.read(authNotifierProvider.notifier).bootstrap();
      expect(container.read(authNotifierProvider), isA<AuthUnauthenticated>());
      expect(storage.clearCount, 1);
      expect(await storage.readRefreshToken(), isNull);
    });

    test('login success writes refresh token and flips to Authenticated',
        () async {
      final api = FakeAuthApiClient()
        ..loginResult =
            fakeTokens(access: 'login-access', refresh: 'login-refresh');
      final storage = FakeTokenStorage();
      final container = makeContainer(api: api, storage: storage);
      addTearDown(container.dispose);

      await container
          .read(authNotifierProvider.notifier)
          .login('admin', 'pw');
      final s = container.read(authNotifierProvider);
      expect(s, isA<AuthAuthenticated>());
      expect((s as AuthAuthenticated).accessToken, 'login-access');
      expect(await storage.readRefreshToken(), 'login-refresh');
    });

    test('login failure does not flip state and rethrows', () async {
      final api = FakeAuthApiClient()..loginError = dio401();
      final storage = FakeTokenStorage();
      final container = makeContainer(api: api, storage: storage);
      addTearDown(container.dispose);

      await expectLater(
        container.read(authNotifierProvider.notifier).login('admin', 'bad'),
        throwsA(isA<Object>()),
      );
      expect(container.read(authNotifierProvider), isA<AuthInitial>());
      expect(await storage.readRefreshToken(), isNull);
    });

    test('logout clears storage and calls API', () async {
      final api = FakeAuthApiClient()
        ..loginResult =
            fakeTokens(access: 'a', refresh: 'r');
      final storage = FakeTokenStorage();
      final container = makeContainer(api: api, storage: storage);
      addTearDown(container.dispose);

      await container
          .read(authNotifierProvider.notifier)
          .login('admin', 'pw');
      await container.read(authNotifierProvider.notifier).logout();

      expect(container.read(authNotifierProvider), isA<AuthUnauthenticated>());
      expect(api.logoutCalls, 1);
      expect(await storage.readRefreshToken(), isNull);
    });

    test('refreshAccessToken single-flight: concurrent calls hit API once',
        () async {
      final api = FakeAuthApiClient()
        ..refreshResult =
            fakeTokens(access: 'new-access', refresh: 'new-refresh');
      final storage = FakeTokenStorage('stored');
      final container = makeContainer(api: api, storage: storage);
      addTearDown(container.dispose);

      // First authenticate so state is Authenticated before refresh.
      await container.read(authNotifierProvider.notifier).bootstrap();
      api.refreshCalls = 0;
      api.refreshResult = fakeTokens(access: 'newer', refresh: 'newer-r');

      final f1 =
          container.read(authNotifierProvider.notifier).refreshAccessToken();
      final f2 =
          container.read(authNotifierProvider.notifier).refreshAccessToken();

      final results = await Future.wait([f1, f2]);
      expect(results, ['newer', 'newer']);
      expect(api.refreshCalls, 1);
    });

    test('refreshAccessToken with no stored token → null + Unauthenticated',
        () async {
      final api = FakeAuthApiClient();
      final storage = FakeTokenStorage();
      final container = makeContainer(api: api, storage: storage);
      addTearDown(container.dispose);

      final result = await container
          .read(authNotifierProvider.notifier)
          .refreshAccessToken();
      expect(result, isNull);
      expect(container.read(authNotifierProvider), isA<AuthUnauthenticated>());
    });

    test('refreshAccessToken on API failure → null + Unauthenticated + clear',
        () async {
      final api = FakeAuthApiClient()..refreshError = dio401();
      final storage = FakeTokenStorage('doomed');
      final container = makeContainer(api: api, storage: storage);
      addTearDown(container.dispose);

      final result = await container
          .read(authNotifierProvider.notifier)
          .refreshAccessToken();
      expect(result, isNull);
      expect(container.read(authNotifierProvider), isA<AuthUnauthenticated>());
      expect(await storage.readRefreshToken(), isNull);
    });
  });
}
