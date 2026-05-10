import 'package:badminton_app/core/activities/activities_api_client.dart';
import 'package:badminton_app/core/activities/models/activities_query.dart';
import 'package:badminton_app/core/activities/models/activity_type.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';

void main() {
  late Dio dio;
  late DioAdapter adapter;
  late ActivitiesApiClient client;

  setUp(() {
    dio = Dio(BaseOptions(baseUrl: 'https://test.local'));
    adapter = DioAdapter(dio: dio);
    client = ActivitiesApiClient(dio);
  });

  Map<String, dynamic> sampleListItem({
    String id = 'a1',
    String title = 'Sunday play',
    bool isJoined = false,
    int participantCount = 0,
  }) =>
      {
        'id': id,
        'title': title,
        'description': '',
        'startAt': '2026-05-08T11:00:00.000Z',
        'endAt': '2026-05-08T13:00:00.000Z',
        'createdById': 'u1',
        'participantCount': participantCount,
        'isJoined': isJoined,
      };

  group('list/detail parsing', () {
    test('list item without type defaults to other', () async {
      adapter.onGet(
        '/activities',
        (server) {
          server.reply(200, {
            'data': [sampleListItem()],
            'total': 1,
            'page': 1,
            'limit': 100,
            'totalPages': 1,
          });
        },
        queryParameters: {
          'page': 1,
          'limit': 100,
          'sortBy': 'startAt',
          'sortOrder': 'asc',
        },
      );
      final page = await client.listActivities(const ActivitiesQuery());
      expect(page.data.first.type, ActivityType.other);
    });

    test('list item with type=party parses correctly', () async {
      adapter.onGet(
        '/activities',
        (server) {
          server.reply(200, {
            'data': [
              {...sampleListItem(), 'type': 'party'},
            ],
            'total': 1,
            'page': 1,
            'limit': 100,
            'totalPages': 1,
          });
        },
        queryParameters: {
          'page': 1,
          'limit': 100,
          'sortBy': 'startAt',
          'sortOrder': 'asc',
        },
      );
      final page = await client.listActivities(const ActivitiesQuery());
      expect(page.data.first.type, ActivityType.party);
    });
  });

  group('listActivities', () {
    test('GETs /activities with from/to/page/limit', () async {
      adapter.onGet(
        '/activities',
        (server) {
          server.reply(200, {
            'data': [sampleListItem()],
            'total': 1,
            'page': 1,
            'limit': 100,
            'totalPages': 1,
          });
        },
        queryParameters: {
          'page': 1,
          'limit': 100,
          'sortBy': 'startAt',
          'sortOrder': 'asc',
          'from': '2026-05-01T00:00:00.000Z',
          'to': '2026-05-31T00:00:00.000Z',
        },
      );

      final page = await client.listActivities(ActivitiesQuery(
        from: DateTime.utc(2026, 5, 1),
        to: DateTime.utc(2026, 5, 31),
      ));

      expect(page.total, 1);
      expect(page.data.first.title, 'Sunday play');
    });

    test('omits from/to when null', () async {
      adapter.onGet(
        '/activities',
        (server) {
          server.reply(200, {
            'data': <Map<String, dynamic>>[],
            'total': 0,
            'page': 1,
            'limit': 100,
            'totalPages': 0,
          });
        },
        queryParameters: {
          'page': 1,
          'limit': 100,
          'sortBy': 'startAt',
          'sortOrder': 'asc',
        },
      );

      final page = await client.listActivities(const ActivitiesQuery());
      expect(page.total, 0);
    });
  });

  group('getActivity', () {
    test('GETs /activities/:id and parses participants newest-first', () async {
      adapter.onGet(
        '/activities/a1',
        (server) {
          server.reply(200, {
            ...sampleListItem(participantCount: 2, isJoined: true),
            'createdBy': {'id': 'u1', 'displayName': 'Manager One'},
            'participants': [
              {
                'id': 'p2',
                'displayName': 'Bob',
                'joinedAt': '2026-05-07T10:01:00.000Z',
              },
              {
                'id': 'p1',
                'displayName': 'Alice',
                'joinedAt': '2026-05-07T10:00:00.000Z',
              },
            ],
          });
        },
      );

      final detail = await client.getActivity('a1');
      expect(detail.participants.first.displayName, 'Bob');
      expect(detail.participants[1].displayName, 'Alice');
      expect(detail.createdBy?.displayName, 'Manager One');
      expect(detail.isJoined, isTrue);
    });

    test('parses null createdBy when creator user is missing', () async {
      adapter.onGet(
        '/activities/a1',
        (server) {
          server.reply(200, {
            ...sampleListItem(),
            'createdBy': null,
            'participants': <Map<String, dynamic>>[],
          });
        },
      );

      final detail = await client.getActivity('a1');
      expect(detail.createdBy, isNull);
      expect(detail.participants, isEmpty);
    });
  });

  group('createActivity', () {
    test('POSTs body with type and UTC ISO timestamps', () async {
      adapter.onPost(
        '/activities',
        (server) {
          server.reply(201, sampleListItem());
        },
        data: {
          'title': 'Sunday play',
          'type': 'badminton_play',
          'description': 'Bring water',
          'startAt': '2026-05-08T11:00:00.000Z',
          'endAt': '2026-05-08T13:00:00.000Z',
        },
      );

      final res = await client.createActivity(
        title: 'Sunday play',
        description: 'Bring water',
        type: ActivityType.badmintonPlay,
        startAt: DateTime.utc(2026, 5, 8, 11),
        endAt: DateTime.utc(2026, 5, 8, 13),
      );
      expect(res.title, 'Sunday play');
    });

    test('omits description when null', () async {
      adapter.onPost(
        '/activities',
        (server) {
          server.reply(201, sampleListItem());
        },
        data: {
          'title': 'Sunday play',
          'type': 'other',
          'startAt': '2026-05-08T11:00:00.000Z',
          'endAt': '2026-05-08T13:00:00.000Z',
        },
      );

      await client.createActivity(
        title: 'Sunday play',
        type: ActivityType.other,
        startAt: DateTime.utc(2026, 5, 8, 11),
        endAt: DateTime.utc(2026, 5, 8, 13),
      );
    });

    test('sends type=party', () async {
      adapter.onPost(
        '/activities',
        (server) {
          server.reply(201, sampleListItem());
        },
        data: {
          'title': 'Party (Đi nhậu)',
          'type': 'party',
          'startAt': '2026-05-08T11:00:00.000Z',
          'endAt': '2026-05-08T13:00:00.000Z',
        },
      );

      await client.createActivity(
        title: 'Party (Đi nhậu)',
        type: ActivityType.party,
        startAt: DateTime.utc(2026, 5, 8, 11),
        endAt: DateTime.utc(2026, 5, 8, 13),
      );
    });
  });

  group('updateActivity', () {
    test('PATCHes only the fields that are non-null', () async {
      adapter.onPatch(
        '/activities/a1',
        (server) {
          server.reply(200, sampleListItem(title: 'Renamed'));
        },
        data: {'title': 'Renamed'},
      );

      final res = await client.updateActivity('a1', title: 'Renamed');
      expect(res.title, 'Renamed');
    });

    test('PATCHes startAt+endAt converted to UTC', () async {
      adapter.onPatch(
        '/activities/a1',
        (server) {
          server.reply(200, sampleListItem());
        },
        data: {
          'startAt': '2026-05-09T11:00:00.000Z',
          'endAt': '2026-05-09T13:00:00.000Z',
        },
      );

      await client.updateActivity(
        'a1',
        startAt: DateTime.utc(2026, 5, 9, 11),
        endAt: DateTime.utc(2026, 5, 9, 13),
      );
    });

    test('PATCHes only the type field when provided', () async {
      adapter.onPatch(
        '/activities/a1',
        (server) {
          server.reply(200, sampleListItem());
        },
        data: {'type': 'badminton_play'},
      );

      await client.updateActivity('a1', type: ActivityType.badmintonPlay);
    });
  });

  group('deleteActivity', () {
    test('DELETEs /activities/:id', () async {
      adapter.onDelete(
        '/activities/a1',
        (server) => server.reply(204, null),
      );
      await client.deleteActivity('a1');
    });
  });

  group('joinActivity / leaveActivity', () {
    test('POSTs /activities/:id/join', () async {
      adapter.onPost(
        '/activities/a1/join',
        (server) =>
            server.reply(200, sampleListItem(isJoined: true, participantCount: 1)),
        data: null,
      );
      final res = await client.joinActivity('a1');
      expect(res.isJoined, isTrue);
      expect(res.participantCount, 1);
    });

    test('DELETEs /activities/:id/join', () async {
      adapter.onDelete(
        '/activities/a1/join',
        (server) => server.reply(200, sampleListItem()),
      );
      final res = await client.leaveActivity('a1');
      expect(res.isJoined, isFalse);
    });
  });
}
