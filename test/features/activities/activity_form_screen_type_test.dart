import 'package:badminton_app/core/activities/activities_api_client.dart';
import 'package:badminton_app/core/activities/activities_providers.dart';
import 'package:badminton_app/core/activities/models/activities_page.dart';
import 'package:badminton_app/core/activities/models/activities_query.dart';
import 'package:badminton_app/core/activities/models/activity.dart';
import 'package:badminton_app/core/activities/models/activity_detail.dart';
import 'package:badminton_app/core/activities/models/activity_type.dart';
import 'package:badminton_app/features/activities/presentation/activity_form_screen.dart';
import 'package:badminton_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeActivitiesApiClient implements ActivitiesApiClient {
  String? lastCreateTitle;
  ActivityType? lastCreateType;
  int createCalls = 0;

  @override
  Future<Activity> createActivity({
    required String title,
    String? description,
    required ActivityType type,
    required DateTime startAt,
    required DateTime endAt,
  }) async {
    createCalls += 1;
    lastCreateTitle = title;
    lastCreateType = type;
    return Activity(
      id: 'a-new',
      title: title,
      description: description ?? '',
      type: type,
      startAt: startAt,
      endAt: endAt,
      createdById: 'u1',
      participantCount: 0,
      isJoined: false,
    );
  }

  @override
  Future<void> deleteActivity(String id) async {}

  @override
  Future<ActivityDetail> getActivity(String id) async => throw UnimplementedError();

  @override
  Future<Activity> joinActivity(String id) async => throw UnimplementedError();

  @override
  Future<Activity> leaveActivity(String id) async => throw UnimplementedError();

  @override
  Future<ActivitiesPage> listActivities(ActivitiesQuery query) async =>
      const ActivitiesPage(
        data: [],
        total: 0,
        page: 1,
        limit: 100,
        totalPages: 0,
      );

  @override
  Future<Activity> updateActivity(
    String id, {
    String? title,
    String? description,
    ActivityType? type,
    DateTime? startAt,
    DateTime? endAt,
  }) async => throw UnimplementedError();
}

Widget _host(_FakeActivitiesApiClient api) {
  return ProviderScope(
    overrides: [
      activitiesApiClientProvider.overrideWithValue(api),
    ],
    child: const MaterialApp(
      locale: Locale('en'),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      home: ActivityFormScreen(),
    ),
  );
}

/// Opens the activity-type dropdown and taps the [optionLabel] entry.
Future<void> _selectType(WidgetTester tester, String optionLabel) async {
  // DropdownMenu wraps a TextField — tapping it opens the popup.
  await tester.tap(find.byType(DropdownMenu<ActivityType>));
  await tester.pumpAndSettle();
  // The selected option also appears in the field's TextField, so the label
  // text matches at least twice. `.last` reliably points at the popped-up
  // entry button.
  await tester.tap(find.text(optionLabel).last);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('initial create selects badminton type and hides title field',
      (tester) async {
    await tester.pumpWidget(_host(_FakeActivitiesApiClient()));
    await tester.pumpAndSettle();

    expect(find.widgetWithText(TextFormField, 'Title'), findsNothing);
    expect(find.widgetWithText(TextFormField, 'Description'), findsOneWidget);
  });

  testWidgets('selecting Other reveals the title field', (tester) async {
    await tester.pumpWidget(_host(_FakeActivitiesApiClient()));
    await tester.pumpAndSettle();

    await _selectType(tester, 'Other');

    expect(find.widgetWithText(TextFormField, 'Title'), findsOneWidget);
  });

  testWidgets('toggling away from Other and back restores typed title',
      (tester) async {
    await tester.pumpWidget(_host(_FakeActivitiesApiClient()));
    await tester.pumpAndSettle();

    await _selectType(tester, 'Other');
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Title'),
      'Pickleball',
    );
    await tester.pumpAndSettle();

    await _selectType(tester, 'Party');
    expect(find.widgetWithText(TextFormField, 'Title'), findsNothing);

    await _selectType(tester, 'Other');
    expect(find.text('Pickleball'), findsOneWidget);
  });

  testWidgets('Other with empty title disables the Create button', (tester) async {
    final api = _FakeActivitiesApiClient();
    await tester.pumpWidget(_host(api));
    await tester.pumpAndSettle();

    await _selectType(tester, 'Other');

    final createButton = tester
        .widget<FilledButton>(find.widgetWithText(FilledButton, 'Create'));
    expect(createButton.onPressed, isNull);
    expect(api.createCalls, 0);
  });

  testWidgets('Badminton submit calls createActivity with type=badmintonPlay',
      (tester) async {
    final api = _FakeActivitiesApiClient();
    await tester.pumpWidget(_host(api));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(FilledButton, 'Create'));
    await tester.pumpAndSettle();

    expect(api.createCalls, 1);
    expect(api.lastCreateType, ActivityType.badmintonPlay);
    expect(api.lastCreateTitle, 'Badminton Play (Đánh cầu)');
  });
}
