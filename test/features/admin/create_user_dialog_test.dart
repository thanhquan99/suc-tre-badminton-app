import 'package:badminton_app/core/auth/models/user_role.dart';
import 'package:badminton_app/core/localization/supported_locales.dart';
import 'package:badminton_app/core/users/users_api_client.dart';
import 'package:badminton_app/core/users/users_providers.dart';
import 'package:badminton_app/features/admin/presentation/dialogs/create_user_dialog.dart';
import 'package:badminton_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../core/users/fakes.dart';

Widget _host({
  required UsersApiClient api,
  void Function(dynamic)? onPopped,
}) {
  return ProviderScope(
    overrides: [usersApiClientProvider.overrideWithValue(api)],
    child: MaterialApp(
      locale: const Locale('en'),
      supportedLocales: kSupportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      home: Builder(
        builder: (context) => Scaffold(
          body: Center(
            child: ElevatedButton(
              onPressed: () async {
                final res = await showDialog<dynamic>(
                  context: context,
                  barrierDismissible: false,
                  builder: (_) => const CreateUserDialog(),
                );
                if (onPopped != null) onPopped(res);
              },
              child: const Text('open'),
            ),
          ),
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('shows validation error when displayName is empty',
      (tester) async {
    final api = FakeUsersApiClient();
    await tester.pumpWidget(_host(api: api));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(FilledButton, 'Create'));
    await tester.pump();

    expect(find.text('Display name is required'), findsOneWidget);
    expect(api.createCalls, 0);
  });

  testWidgets('submits displayName and default role member', (tester) async {
    final api = FakeUsersApiClient();
    dynamic returned;
    await tester.pumpWidget(_host(api: api, onPopped: (r) => returned = r));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField), 'Test User');
    await tester.tap(find.widgetWithText(FilledButton, 'Create'));
    await tester.pumpAndSettle();

    expect(api.createCalls, 1);
    expect(api.lastCreatedDisplayName, 'Test User');
    expect(api.lastCreatedRole, UserRole.member);
    expect(returned, isNotNull);
  });

  testWidgets('allows switching role to manager before submit',
      (tester) async {
    final api = FakeUsersApiClient();
    await tester.pumpWidget(_host(api: api));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField), 'Manager One');
    await tester.tap(find.text('Manager'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Create'));
    await tester.pumpAndSettle();

    expect(api.lastCreatedRole, UserRole.manager);
  });
}
