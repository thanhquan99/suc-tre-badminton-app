class ActivitiesQuery {
  final DateTime? from;
  final DateTime? to;
  final int page;
  final int limit;
  final String sortBy;
  final String sortOrder;

  const ActivitiesQuery({
    this.from,
    this.to,
    this.page = 1,
    this.limit = 100,
    this.sortBy = 'startAt',
    this.sortOrder = 'asc',
  });

  Map<String, dynamic> toQueryParams() {
    final params = <String, dynamic>{
      'page': page,
      'limit': limit,
      'sortBy': sortBy,
      'sortOrder': sortOrder,
    };
    if (from != null) params['from'] = from!.toUtc().toIso8601String();
    if (to != null) params['to'] = to!.toUtc().toIso8601String();
    return params;
  }

  ActivitiesQuery copyWith({
    Object? from = _unset,
    Object? to = _unset,
    int? page,
    int? limit,
    String? sortBy,
    String? sortOrder,
  }) {
    return ActivitiesQuery(
      from: identical(from, _unset) ? this.from : from as DateTime?,
      to: identical(to, _unset) ? this.to : to as DateTime?,
      page: page ?? this.page,
      limit: limit ?? this.limit,
      sortBy: sortBy ?? this.sortBy,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is ActivitiesQuery &&
      other.from == from &&
      other.to == to &&
      other.page == page &&
      other.limit == limit &&
      other.sortBy == sortBy &&
      other.sortOrder == sortOrder;

  @override
  int get hashCode => Object.hash(from, to, page, limit, sortBy, sortOrder);
}

const _unset = Object();
