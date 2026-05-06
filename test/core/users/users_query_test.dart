import 'package:badminton_app/core/auth/models/user_role.dart';
import 'package:badminton_app/core/users/models/users_query.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('UsersQuery equality', () {
    test('identical field values are equal and share hashCode', () {
      const a = UsersQuery(q: 'x', role: UserRole.member, page: 2, limit: 10);
      const b = UsersQuery(q: 'x', role: UserRole.member, page: 2, limit: 10);
      expect(a == b, isTrue);
      expect(a.hashCode, b.hashCode);
    });

    test('differing fields are not equal', () {
      const a = UsersQuery(q: 'x');
      const b = UsersQuery(q: 'y');
      expect(a == b, isFalse);
    });
  });

  group('copyWith', () {
    test('keeps fields when not specified', () {
      const a = UsersQuery(q: 'x', role: UserRole.member, page: 3);
      final b = a.copyWith(page: 1);
      expect(b.q, 'x');
      expect(b.role, UserRole.member);
      expect(b.page, 1);
    });

    test('allows clearing role by passing null explicitly', () {
      const a = UsersQuery(q: 'x', role: UserRole.member);
      final b = a.copyWith(role: null);
      expect(b.role, isNull);
      expect(b.q, 'x');
    });
  });

  group('toQueryParams', () {
    test('omits q and role when unset', () {
      final params = const UsersQuery().toQueryParams();
      expect(params.containsKey('q'), isFalse);
      expect(params.containsKey('role'), isFalse);
      expect(params['page'], 1);
    });

    test('includes q and role when set', () {
      final params =
          const UsersQuery(q: 'al', role: UserRole.manager).toQueryParams();
      expect(params['q'], 'al');
      expect(params['role'], 'manager');
    });
  });
}
