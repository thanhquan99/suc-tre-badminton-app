import '../../auth/models/auth_user.dart';

class UsersPage {
  final List<AuthUser> data;
  final int total;
  final int page;
  final int limit;
  final int totalPages;

  const UsersPage({
    required this.data,
    required this.total,
    required this.page,
    required this.limit,
    required this.totalPages,
  });

  factory UsersPage.fromJson(Map<String, dynamic> json) {
    return UsersPage(
      data: (json['data'] as List<dynamic>)
          .map((e) => AuthUser.fromJson(e as Map<String, dynamic>))
          .toList(),
      total: json['total'] as int,
      page: json['page'] as int,
      limit: json['limit'] as int,
      totalPages: json['totalPages'] as int,
    );
  }
}
