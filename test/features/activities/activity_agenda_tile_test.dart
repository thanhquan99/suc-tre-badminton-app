import 'package:badminton_app/core/activities/models/activity.dart';
import 'package:badminton_app/features/activities/presentation/widgets/activity_agenda_tile.dart';
import 'package:badminton_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget wrap(Widget child) {
    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('en'),
      home: Scaffold(body: child),
    );
  }

  Activity buildActivity({
    bool isJoined = false,
    int participantCount = 3,
    DateTime? startAt,
    DateTime? endAt,
  }) {
    final start = startAt ?? DateTime.now().add(const Duration(days: 1));
    return Activity(
      id: 'a1',
      title: 'Sunday play',
      description: '',
      startAt: start,
      endAt: endAt ?? start.add(const Duration(hours: 2)),
      createdById: 'u1',
      participantCount: participantCount,
      isJoined: isJoined,
    );
  }

  testWidgets('renders title, count, and "Not joined" badge by default',
      (tester) async {
    final activity = buildActivity();
    await tester.pumpWidget(
      wrap(
        ActivityAgendaTile(
          activity: activity,
          locale: 'en',
          onTap: () {},
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Sunday play'), findsOneWidget);
    expect(find.text('3'), findsOneWidget);
    expect(find.text('Not joined'), findsOneWidget);
    expect(find.text("You're in"), findsNothing);
  });

  testWidgets('shows "You\'re in" when isJoined is true', (tester) async {
    await tester.pumpWidget(
      wrap(
        ActivityAgendaTile(
          activity: buildActivity(isJoined: true),
          locale: 'en',
          onTap: () {},
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text("You're in"), findsOneWidget);
  });

  testWidgets('invokes onTap when tapped', (tester) async {
    var tapped = false;
    await tester.pumpWidget(
      wrap(
        ActivityAgendaTile(
          activity: buildActivity(),
          locale: 'en',
          onTap: () => tapped = true,
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byType(ListTile));
    expect(tapped, isTrue);
  });
}
