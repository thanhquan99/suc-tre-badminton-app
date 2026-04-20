enum UserRole {
  admin,
  manager,
  member;

  String toJson() => name;

  static UserRole fromJson(String value) {
    return UserRole.values.firstWhere(
      (r) => r.name == value,
      orElse: () => throw FormatException('Unknown user role: $value'),
    );
  }
}
