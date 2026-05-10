import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shared/providers/dio_provider.dart';
import 'activities_api_client.dart';
import 'models/activities_page.dart';
import 'models/activities_query.dart';
import 'models/activity.dart';
import 'models/activity_detail.dart';
import 'models/activity_type.dart';

final activitiesApiClientProvider = Provider<ActivitiesApiClient>((ref) {
  return ActivitiesApiClient(ref.watch(dioProvider));
});

final activitiesListProvider = FutureProvider.family
    .autoDispose<ActivitiesPage, ActivitiesQuery>((ref, query) async {
  final client = ref.watch(activitiesApiClientProvider);
  return client.listActivities(query);
});

final activityByIdProvider = FutureProvider.family
    .autoDispose<ActivityDetail, String>((ref, id) async {
  final client = ref.watch(activitiesApiClientProvider);
  return client.getActivity(id);
});

class CreateActivityNotifier extends AutoDisposeAsyncNotifier<Activity?> {
  @override
  Future<Activity?> build() async => null;

  Future<Activity> create({
    required String title,
    String? description,
    required ActivityType type,
    required DateTime startAt,
    required DateTime endAt,
  }) async {
    final client = ref.read(activitiesApiClientProvider);
    state = const AsyncValue.loading();
    try {
      final result = await client.createActivity(
        title: title,
        description: description,
        type: type,
        startAt: startAt,
        endAt: endAt,
      );
      state = AsyncValue.data(result);
      ref.invalidate(activitiesListProvider);
      return result;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }
}

final createActivityNotifierProvider =
    AsyncNotifierProvider.autoDispose<CreateActivityNotifier, Activity?>(
  CreateActivityNotifier.new,
);

class UpdateActivityNotifier
    extends AutoDisposeFamilyAsyncNotifier<Activity?, String> {
  @override
  Future<Activity?> build(String id) async => null;

  Future<Activity> save({
    String? title,
    String? description,
    ActivityType? type,
    DateTime? startAt,
    DateTime? endAt,
  }) async {
    final client = ref.read(activitiesApiClientProvider);
    state = const AsyncValue.loading();
    try {
      final updated = await client.updateActivity(
        arg,
        title: title,
        description: description,
        type: type,
        startAt: startAt,
        endAt: endAt,
      );
      state = AsyncValue.data(updated);
      ref.invalidate(activityByIdProvider(arg));
      ref.invalidate(activitiesListProvider);
      return updated;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }
}

final updateActivityNotifierProvider = AsyncNotifierProvider.autoDispose
    .family<UpdateActivityNotifier, Activity?, String>(
  UpdateActivityNotifier.new,
);

class DeleteActivityNotifier
    extends AutoDisposeFamilyAsyncNotifier<void, String> {
  @override
  Future<void> build(String id) async {}

  Future<void> delete() async {
    final client = ref.read(activitiesApiClientProvider);
    state = const AsyncValue.loading();
    try {
      await client.deleteActivity(arg);
      state = const AsyncValue.data(null);
      ref.invalidate(activitiesListProvider);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }
}

final deleteActivityNotifierProvider = AsyncNotifierProvider.autoDispose
    .family<DeleteActivityNotifier, void, String>(
  DeleteActivityNotifier.new,
);

class JoinActivityNotifier
    extends AutoDisposeFamilyAsyncNotifier<Activity?, String> {
  @override
  Future<Activity?> build(String id) async => null;

  Future<Activity> join() async {
    final client = ref.read(activitiesApiClientProvider);
    state = const AsyncValue.loading();
    try {
      final result = await client.joinActivity(arg);
      state = AsyncValue.data(result);
      ref.invalidate(activityByIdProvider(arg));
      ref.invalidate(activitiesListProvider);
      return result;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<Activity> leave() async {
    final client = ref.read(activitiesApiClientProvider);
    state = const AsyncValue.loading();
    try {
      final result = await client.leaveActivity(arg);
      state = AsyncValue.data(result);
      ref.invalidate(activityByIdProvider(arg));
      ref.invalidate(activitiesListProvider);
      return result;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }
}

final joinActivityNotifierProvider = AsyncNotifierProvider.autoDispose
    .family<JoinActivityNotifier, Activity?, String>(
  JoinActivityNotifier.new,
);
