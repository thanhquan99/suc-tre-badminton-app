import 'package:badminton_app/core/auth/models/auth_user.dart';
import 'package:badminton_app/core/auth/models/user_role.dart';
import 'package:badminton_app/core/localization/supported_locales.dart';
import 'package:badminton_app/core/users/models/users_page.dart';
import 'package:badminton_app/core/users/users_providers.dart';
import 'package:badminton_app/features/admin/presentation/users_screen.dart';
import 'package:badminton_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../core/users/fakes.dart';

Widget wrap(FakeUsersApiClient api) {
  return ProviderScope(
    overrides: [usersApiClientProvider.overrideWithValue(api)],
    child: const MaterialApp(
      locale: Locale('en'),
      supportedLocales: kSupportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      home: UsersScreen(),
    ),
  );
}

void main() {
  testWidgets('renders list of users returned by the api', (tester) async {
    final api = FakeUsersApiClient()
      ..listResult = UsersPage(
        data: [
          fakeUser(id: 'u1', displayName: 'Alice', username: 'alice1234'),
          fakeUser(
            id: 'u2',
            displayName: 'Bob',
            username: 'bob5678',
            role: UserRole.manager,
          ),
        ],
        total: 2,
        page: 1,
        limit: 20,
        totalPages: 1,
      );

    await tester.pumpWidget(wrap(api));
    await tester.pumpAndSettle();

    expect(find.text('Alice'), findsOneWidget);
    expect(find.text('@alice1234'), findsOneWidget);
    expect(find.text('Bob'), findsOneWidget);
    expect(api.listCalls, 1);
  });

  testWidgets('empty list shows the empty-state message', (tester) async {
    final api = FakeUsersApiClient()
      ..listResult = const UsersPage(
        data: <AuthUser>[],
        total: 0,
        page: 1,
        limit: 20,
        totalPages: 0,
      );

    await tester.pumpWidget(wrap(api));
    await tester.pumpAndSettle();

    expect(find.text('No users found'), findsOneWidget);
  });

  testWidgets('role chip filter triggers a re-query with role', (tester) async {
    final api = FakeUsersApiClient();
    await tester.pumpWidget(wrap(api));
    await tester.pumpAndSettle();

    final initialCalls = api.listCalls;
    await tester.tap(find.widgetWithText(ChoiceChip, 'Manager'));
    await tester.pumpAndSettle();

    expect(api.listCalls, greaterThan(initialCalls));
    expect(api.lastListQuery?.role, UserRole.manager);
  });
}
