import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'auth_notifier.dart';
import 'auth_state.dart';

const _retryMarker = 'auth_retried';

/// Minimal read-only view over a Riverpod scope. Both [Ref] and
/// [ProviderContainer] satisfy this implicitly via their `.read` method,
/// but Dart doesn't let us use structural typing — so we adapt at the call
/// site (see [AuthInterceptor.fromRef] and [AuthInterceptor.fromContainer]).
typedef _Reader = T Function<T>(ProviderListenable<T> provider);

class AuthInterceptor extends Interceptor {
  AuthInterceptor._(this._read, this._authedDio);

  factory AuthInterceptor.fromRef(Ref ref, Dio authedDio) {
    return AuthInterceptor._(<T>(p) => ref.read(p), authedDio);
  }

  factory AuthInterceptor.fromContainer(
    ProviderContainer container,
    Dio authedDio,
  ) {
    return AuthInterceptor._(<T>(p) => container.read(p), authedDio);
  }

  final _Reader _read;
  final Dio _authedDio;

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) {
    final auth = _read(authNotifierProvider);
    if (auth is AuthAuthenticated) {
      options.headers['Authorization'] = 'Bearer ${auth.accessToken}';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final status = err.response?.statusCode;
    final alreadyRetried = err.requestOptions.extra[_retryMarker] == true;
    if (status != 401 || alreadyRetried) {
      handler.next(err);
      return;
    }

    final newToken =
        await _read(authNotifierProvider.notifier).refreshAccessToken();
    if (newToken == null) {
      handler.next(err);
      return;
    }

    final original = err.requestOptions;
    final retryOptions = Options(
      method: original.method,
      headers: {
        ...original.headers,
        'Authorization': 'Bearer $newToken',
      },
      responseType: original.responseType,
      contentType: original.contentType,
      extra: {
        ...original.extra,
        _retryMarker: true,
      },
    );

    try {
      final response = await _authedDio.request<dynamic>(
        original.path,
        data: original.data,
        queryParameters: original.queryParameters,
        options: retryOptions,
      );
      handler.resolve(response);
    } on DioException catch (e) {
      handler.next(e);
    }
  }
}
