import 'package:dio/dio.dart';

import '../auth/models/auth_user.dart';
import '../auth/models/user_role.dart';
import 'models/create_user_response.dart';
import 'models/users_page.dart';
import 'models/users_query.dart';

class UsersApiClient {
  UsersApiClient(this._dio);

  final Dio _dio;

  Future<CreateUserResponse> createUser({
    required String displayName,
    required UserRole role,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/users',
      data: {'displayName': displayName, 'role': role.toJson()},
    );
    return CreateUserResponse.fromJson(response.data!);
  }

  Future<UsersPage> listUsers(UsersQuery query) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/users',
      queryParameters: query.toQueryParams(),
    );
    return UsersPage.fromJson(response.data!);
  }

  Future<AuthUser> getUser(String id) async {
    final response = await _dio.get<Map<String, dynamic>>('/users/$id');
    return AuthUser.fromJson(response.data!);
  }

  Future<AuthUser> updateUser(
    String id, {
    String? displayName,
    bool? isActive,
  }) async {
    final body = <String, dynamic>{};
    if (displayName != null) body['displayName'] = displayName;
    if (isActive != null) body['isActive'] = isActive;
    final response = await _dio.patch<Map<String, dynamic>>(
      '/users/$id',
      data: body,
    );
    return AuthUser.fromJson(response.data!);
  }
}
