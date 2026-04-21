import 'package:badminton_app/core/auth/models/auth_user.dart';
import 'package:badminton_app/core/auth/models/user_role.dart';
import 'package:badminton_app/core/users/models/create_user_response.dart';
import 'package:badminton_app/core/users/models/users_page.dart';
import 'package:badminton_app/core/users/models/users_query.dart';
import 'package:badminton_app/core/users/users_api_client.dart';

AuthUser fakeUser({
  String id = 'u1',
  String username = 'alice1234',
  String displayName = 'Alice',
  UserRole role = UserRole.member,
}) {
  return AuthUser(
    id: id,
    username: username,
    displayName: displayName,
    role: role,
  );
}

class FakeUsersApiClient implements UsersApiClient {
  int createCalls = 0;
  int listCalls = 0;
  Object? createError;
  Object? listError;
  CreateUserResponse? createResult;
  UsersPage? listResult;
  String? lastCreatedDisplayName;
  UserRole? lastCreatedRole;
  UsersQuery? lastListQuery;

  @override
  Future<CreateUserResponse> createUser({
    required String displayName,
    required UserRole role,
  }) async {
    createCalls++;
    lastCreatedDisplayName = displayName;
    lastCreatedRole = role;
    if (createError != null) throw createError!;
    return createResult ??
        CreateUserResponse(
          user: fakeUser(id: 'new-1', username: 'alice1234', displayName: displayName, role: role),
          password: 'Xa7!pQ9m\$2vR',
        );
  }

  @override
  Future<UsersPage> listUsers(UsersQuery query) async {
    listCalls++;
    lastListQuery = query;
    if (listError != null) throw listError!;
    return listResult ??
        UsersPage(
          data: [fakeUser()],
          total: 1,
          page: query.page,
          limit: query.limit,
          totalPages: 1,
        );
  }
}
