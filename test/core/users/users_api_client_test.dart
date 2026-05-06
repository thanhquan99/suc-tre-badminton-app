import 'package:badminton_app/core/auth/models/user_role.dart';
import 'package:badminton_app/core/users/models/users_query.dart';
import 'package:badminton_app/core/users/users_api_client.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';

void main() {
  late Dio dio;
  late DioAdapter adapter;
  late UsersApiClient client;

  setUp(() {
    dio = Dio(BaseOptions(baseUrl: 'https://test.local'));
    adapter = DioAdapter(dio: dio);
    client = UsersApiClient(dio);
  });

  group('createUser', () {
    test('POSTs displayName and role, parses the response', () async {
      adapter.onPost(
        '/users',
        (server) {
          server.reply(201, {
            'user': {
              'id': 'new-1',
              'username': 'nguyenvana1234',
              'displayName': 'Nguyễn Văn A',
              'role': 'member',
            },
            'password': 'Xa7!pQ9m\$2vR',
          });
        },
        data: {'displayName': 'Nguyễn Văn A', 'role': 'member'},
      );

      final res = await client.createUser(
        displayName: 'Nguyễn Văn A',
        role: UserRole.member,
      );

      expect(res.user.username, 'nguyenvana1234');
      expect(res.user.role, UserRole.member);
      expect(res.password, 'Xa7!pQ9m\$2vR');
    });
  });

  group('listUsers', () {
    test('GETs /users with query params and parses the page', () async {
      adapter.onGet(
        '/users',
        (server) {
          server.reply(200, {
            'data': [
              {
                'id': 'u1',
                'username': 'alice1234',
                'displayName': 'Alice',
                'role': 'member',
              },
            ],
            'total': 3,
            'page': 2,
            'limit': 1,
            'totalPages': 3,
          });
        },
        queryParameters: {
          'page': 2,
          'limit': 1,
          'sortBy': 'createdAt',
          'sortOrder': 'desc',
          'q': 'ali',
          'role': 'member',
        },
      );

      final page = await client.listUsers(const UsersQuery(
        q: 'ali',
        role: UserRole.member,
        page: 2,
        limit: 1,
      ));

      expect(page.total, 3);
      expect(page.totalPages, 3);
      expect(page.data, hasLength(1));
      expect(page.data.first.username, 'alice1234');
    });

    test('omits q and role when null/empty', () async {
      adapter.onGet(
        '/users',
        (server) {
          server.reply(200, {
            'data': <Map<String, dynamic>>[],
            'total': 0,
            'page': 1,
            'limit': 20,
            'totalPages': 0,
          });
        },
        queryParameters: {
          'page': 1,
          'limit': 20,
          'sortBy': 'createdAt',
          'sortOrder': 'desc',
        },
      );

      final page = await client.listUsers(const UsersQuery());
      expect(page.total, 0);
      expect(page.data, isEmpty);
    });
  });
}
