import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shared/providers/dio_provider.dart';
import '../auth/models/auth_user.dart';
import '../auth/models/user_role.dart';
import 'models/create_user_response.dart';
import 'models/users_page.dart';
import 'models/users_query.dart';
import 'users_api_client.dart';

final usersApiClientProvider = Provider<UsersApiClient>((ref) {
  return UsersApiClient(ref.watch(dioProvider));
});

final usersListProvider =
    FutureProvider.family.autoDispose<UsersPage, UsersQuery>((ref, query) async {
  final client = ref.watch(usersApiClientProvider);
  return client.listUsers(query);
});

class CreateUserNotifier
    extends AutoDisposeAsyncNotifier<CreateUserResponse?> {
  @override
  Future<CreateUserResponse?> build() async => null;

  Future<CreateUserResponse> create({
    required String displayName,
    required UserRole role,
  }) async {
    final client = ref.read(usersApiClientProvider);
    state = const AsyncValue.loading();
    try {
      final result = await client.createUser(
        displayName: displayName,
        role: role,
      );
      state = AsyncValue.data(result);
      return result;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  void reset() {
    state = const AsyncValue.data(null);
  }
}

final createUserNotifierProvider = AsyncNotifierProvider.autoDispose<
    CreateUserNotifier, CreateUserResponse?>(CreateUserNotifier.new);

final userByIdProvider =
    FutureProvider.family.autoDispose<AuthUser, String>((ref, id) async {
  final client = ref.watch(usersApiClientProvider);
  return client.getUser(id);
});

class UpdateUserNotifier
    extends AutoDisposeFamilyAsyncNotifier<AuthUser?, String> {
  @override
  Future<AuthUser?> build(String id) async => null;

  Future<AuthUser> save({String? displayName, bool? isActive}) async {
    final client = ref.read(usersApiClientProvider);
    state = const AsyncValue.loading();
    try {
      final updated = await client.updateUser(
        arg,
        displayName: displayName,
        isActive: isActive,
      );
      state = AsyncValue.data(updated);
      ref.invalidate(userByIdProvider(arg));
      ref.invalidate(usersListProvider);
      return updated;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }
}

final updateUserNotifierProvider = AsyncNotifierProvider.autoDispose
    .family<UpdateUserNotifier, AuthUser?, String>(UpdateUserNotifier.new);
