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
  bool isActive = true,
}) {
  return AuthUser(
    id: id,
    username: username,
    displayName: displayName,
    role: role,
    isActive: isActive,
  );
}

class FakeUsersApiClient implements UsersApiClient {
  int createCalls = 0;
  int listCalls = 0;
  int getCalls = 0;
  int updateCalls = 0;
  Object? createError;
  Object? listError;
  Object? getError;
  Object? updateError;
  CreateUserResponse? createResult;
  UsersPage? listResult;
  AuthUser? getResult;
  AuthUser? updateResult;
  String? lastCreatedDisplayName;
  UserRole? lastCreatedRole;
  UsersQuery? lastListQuery;
  String? lastGetId;
  String? lastUpdateId;
  String? lastUpdateDisplayName;
  bool? lastUpdateIsActive;

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

  @override
  Future<AuthUser> getUser(String id) async {
    getCalls++;
    lastGetId = id;
    if (getError != null) throw getError!;
    return getResult ?? fakeUser(id: id);
  }

  @override
  Future<AuthUser> updateUser(
    String id, {
    String? displayName,
    bool? isActive,
  }) async {
    updateCalls++;
    lastUpdateId = id;
    lastUpdateDisplayName = displayName;
    lastUpdateIsActive = isActive;
    if (updateError != null) throw updateError!;
    return updateResult ??
        fakeUser(
          id: id,
          displayName: displayName ?? 'Alice',
          isActive: isActive ?? true,
        );
  }
}
