import 'package:badminton_app/core/auth/auth_interceptor.dart';
import 'package:badminton_app/core/auth/auth_notifier.dart';
import 'package:badminton_app/core/auth/auth_providers.dart';
import 'package:badminton_app/core/auth/auth_state.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';

import 'fakes.dart';

void main() {
  late Dio authedDio;
  late DioAdapter adapter;
  late FakeAuthApiClient api;
  late FakeTokenStorage storage;
  late ProviderContainer container;

  setUp(() {
    authedDio = Dio(BaseOptions(baseUrl: 'https://test.local'));
    adapter = DioAdapter(dio: authedDio);
    api = FakeAuthApiClient();
    storage = FakeTokenStorage('bootstrap-refresh');

    container = ProviderContainer(
      overrides: [
        authApiClientProvider.overrideWithValue(api),
        tokenStorageProvider.overrideWithValue(storage),
      ],
    );
    authedDio.interceptors.add(
      AuthInterceptor.fromContainer(container, authedDio),
    );
  });

  tearDown(() => container.dispose());

  Future<void> authenticate({required String accessToken}) async {
    api.refreshResult = fakeTokens(access: accessToken, refresh: 'r');
    await container.read(authNotifierProvider.notifier).bootstrap();
    expect(container.read(authNotifierProvider), isA<AuthAuthenticated>());
  }

  test('attaches Bearer token to requests when authenticated', () async {
    await authenticate(accessToken: 'good-token');
    adapter.onGet('/items', (server) {
      server.reply(200, {'items': []});
    }, headers: {'Authorization': 'Bearer good-token'});

    final res = await authedDio.get<dynamic>('/items');
    expect(res.statusCode, 200);
  });

  test('on 401, calls refresh, retries, resolves with new response', () async {
    await authenticate(accessToken: 'expired-token');
    // Next refresh returns new token
    api.refreshResult = fakeTokens(access: 'fresh-token', refresh: 'r2');

    adapter
      ..onGet('/items', (server) => server.reply(401, {'message': 'Unauthorized'}),
          headers: {'Authorization': 'Bearer expired-token'})
      ..onGet('/items', (server) => server.reply(200, {'ok': true}),
          headers: {'Authorization': 'Bearer fresh-token'});

    final res = await authedDio.get<dynamic>('/items');
    expect(res.statusCode, 200);
    expect((res.data as Map)['ok'], true);
    // One initial bootstrap + one retry refresh = 2
    expect(api.refreshCalls, 2);
  });

  test('on 401 retry that also 401s, propagates error (no infinite loop)',
      () async {
    await authenticate(accessToken: 'expired-token');
    api.refreshResult = fakeTokens(access: 'fresh-token', refresh: 'r2');

    adapter
      ..onGet('/items', (server) => server.reply(401, {}),
          headers: {'Authorization': 'Bearer expired-token'})
      ..onGet('/items', (server) => server.reply(401, {}),
          headers: {'Authorization': 'Bearer fresh-token'});

    await expectLater(
      authedDio.get<dynamic>('/items'),
      throwsA(isA<DioException>()),
    );
  });

  test('refresh failure → 401 propagates, state flips to Unauthenticated',
      () async {
    await authenticate(accessToken: 'expired-token');
    api.refreshError = dio401();

    adapter.onGet('/items', (server) => server.reply(401, {}),
        headers: {'Authorization': 'Bearer expired-token'});

    await expectLater(
      authedDio.get<dynamic>('/items'),
      throwsA(isA<DioException>()),
    );
    expect(container.read(authNotifierProvider), isA<AuthUnauthenticated>());
  });
}
