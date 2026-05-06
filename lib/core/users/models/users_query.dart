import '../../auth/models/user_role.dart';

class UsersQuery {
  final String? q;
  final UserRole? role;
  final int page;
  final int limit;
  final String sortBy;
  final String sortOrder;

  const UsersQuery({
    this.q,
    this.role,
    this.page = 1,
    this.limit = 20,
    this.sortBy = 'createdAt',
    this.sortOrder = 'desc',
  });

  Map<String, dynamic> toQueryParams() {
    final params = <String, dynamic>{
      'page': page,
      'limit': limit,
      'sortBy': sortBy,
      'sortOrder': sortOrder,
    };
    if (q != null && q!.isNotEmpty) params['q'] = q;
    if (role != null) params['role'] = role!.toJson();
    return params;
  }

  UsersQuery copyWith({
    String? q,
    Object? role = _unset,
    int? page,
    int? limit,
    String? sortBy,
    String? sortOrder,
  }) {
    return UsersQuery(
      q: q ?? this.q,
      role: identical(role, _unset) ? this.role : role as UserRole?,
      page: page ?? this.page,
      limit: limit ?? this.limit,
      sortBy: sortBy ?? this.sortBy,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is UsersQuery &&
      other.q == q &&
      other.role == role &&
      other.page == page &&
      other.limit == limit &&
      other.sortBy == sortBy &&
      other.sortOrder == sortOrder;

  @override
  int get hashCode => Object.hash(q, role, page, limit, sortBy, sortOrder);
}

const _unset = Object();
