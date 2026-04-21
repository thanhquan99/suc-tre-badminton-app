import 'package:dio/dio.dart';

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
}
