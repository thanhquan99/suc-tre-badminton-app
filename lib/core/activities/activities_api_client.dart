import 'package:dio/dio.dart';

import 'models/activities_page.dart';
import 'models/activities_query.dart';
import 'models/activity.dart';
import 'models/activity_detail.dart';
import 'models/activity_type.dart';

class ActivitiesApiClient {
  ActivitiesApiClient(this._dio);

  final Dio _dio;

  Future<ActivitiesPage> listActivities(ActivitiesQuery query) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/activities',
      queryParameters: query.toQueryParams(),
    );
    return ActivitiesPage.fromJson(response.data!);
  }

  Future<ActivityDetail> getActivity(String id) async {
    final response = await _dio.get<Map<String, dynamic>>('/activities/$id');
    return ActivityDetail.fromJson(response.data!);
  }

  Future<Activity> createActivity({
    required String title,
    String? description,
    required ActivityType type,
    required DateTime startAt,
    required DateTime endAt,
  }) async {
    final body = <String, dynamic>{
      'title': title,
      'type': type.wireValue,
      'startAt': startAt.toUtc().toIso8601String(),
      'endAt': endAt.toUtc().toIso8601String(),
    };
    if (description != null) body['description'] = description;
    final response = await _dio.post<Map<String, dynamic>>(
      '/activities',
      data: body,
    );
    return Activity.fromJson(response.data!);
  }

  Future<Activity> updateActivity(
    String id, {
    String? title,
    String? description,
    ActivityType? type,
    DateTime? startAt,
    DateTime? endAt,
  }) async {
    final body = <String, dynamic>{};
    if (title != null) body['title'] = title;
    if (description != null) body['description'] = description;
    if (type != null) body['type'] = type.wireValue;
    if (startAt != null) body['startAt'] = startAt.toUtc().toIso8601String();
    if (endAt != null) body['endAt'] = endAt.toUtc().toIso8601String();
    final response = await _dio.patch<Map<String, dynamic>>(
      '/activities/$id',
      data: body,
    );
    return Activity.fromJson(response.data!);
  }

  Future<void> deleteActivity(String id) async {
    await _dio.delete<void>('/activities/$id');
  }

  Future<Activity> joinActivity(String id) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/activities/$id/join',
    );
    return Activity.fromJson(response.data!);
  }

  Future<Activity> leaveActivity(String id) async {
    final response = await _dio.delete<Map<String, dynamic>>(
      '/activities/$id/join',
    );
    return Activity.fromJson(response.data!);
  }
}
