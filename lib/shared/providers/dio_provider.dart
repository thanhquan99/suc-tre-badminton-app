import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/auth/auth_interceptor.dart';
import '../../core/network/dio_client.dart';

/// Authenticated Dio: attaches Bearer tokens and handles 401-refresh-retry.
/// Use this for application API calls. For /auth/* endpoints, use
/// [plainDioProvider] (in core/auth/auth_providers.dart) to avoid refresh loops.
final dioProvider = Provider<Dio>((ref) {
  final dio = createDioClient();
  dio.interceptors.add(AuthInterceptor.fromRef(ref, dio));
  return dio;
});
