import 'activity.dart';

class ActivitiesPage {
  final List<Activity> data;
  final int total;
  final int page;
  final int limit;
  final int totalPages;

  const ActivitiesPage({
    required this.data,
    required this.total,
    required this.page,
    required this.limit,
    required this.totalPages,
  });

  factory ActivitiesPage.fromJson(Map<String, dynamic> json) {
    final list = (json['data'] as List)
        .map((e) => Activity.fromJson(e as Map<String, dynamic>))
        .toList();
    return ActivitiesPage(
      data: list,
      total: json['total'] as int,
      page: json['page'] as int,
      limit: json['limit'] as int,
      totalPages: json['totalPages'] as int,
    );
  }
}
