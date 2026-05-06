import 'package:badminton_app/core/auth/auth_providers.dart';
import 'package:badminton_app/core/localization/locale_notifier.dart';
import 'package:badminton_app/core/localization/supported_locales.dart';
import 'package:badminton_app/features/auth/presentation/login_screen.dart';
import 'package:badminton_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../core/auth/fakes.dart';

Widget wrap({
  required FakeAuthApiClient api,
  required FakeTokenStorage storage,
  Locale locale = const Locale('en'),
}) {
  return ProviderScope(
    overrides: [
      authApiClientProvider.overrideWithValue(api),
      tokenStorageProvider.overrideWithValue(storage),
      initialLocaleProvider.overrideWithValue(locale),
    ],
    child: MaterialApp(
      locale: locale,
      supportedLocales: kSupportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      home: const LoginScreen(),
    ),
  );
}

void main() {
  testWidgets('shows username validation error for invalid username',
      (tester) async {
    final api = FakeAuthApiClient();
    final storage = FakeTokenStorage();
    await tester.pumpWidget(wrap(api: api, storage: storage));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).first, 'X');
    await tester.enterText(find.byType(TextFormField).at(1), 'pw');
    await tester.tap(find.byType(FilledButton));
    await tester.pump();

    expect(
      find.textContaining("Use 3-30 lowercase"),
      findsOneWidget,
    );
    expect(api.loginCalls, 0);
  });

  testWidgets('shows password required error when empty', (tester) async {
    final api = FakeAuthApiClient();
    final storage = FakeTokenStorage();
    await tester.pumpWidget(wrap(api: api, storage: storage));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).first, 'admin');
    await tester.tap(find.byType(FilledButton));
    await tester.pump();

    expect(find.text('Password is required'), findsOneWidget);
    expect(api.loginCalls, 0);
  });

  testWidgets('valid form calls login on the notifier', (tester) async {
    final api = FakeAuthApiClient()..loginResult = fakeTokens();
    final storage = FakeTokenStorage();
    await tester.pumpWidget(wrap(api: api, storage: storage));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).first, 'admin');
    await tester.enterText(find.byType(TextFormField).at(1), 'hunter2');
    await tester.tap(find.byType(FilledButton));
    await tester.pumpAndSettle();

    expect(api.loginCalls, 1);
  });

  testWidgets('login 401 shows invalid-credentials snackbar', (tester) async {
    final api = FakeAuthApiClient()..loginError = dio401();
    final storage = FakeTokenStorage();
    await tester.pumpWidget(wrap(api: api, storage: storage));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).first, 'admin');
    await tester.enterText(find.byType(TextFormField).at(1), 'wrong');
    await tester.tap(find.byType(FilledButton));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Invalid username or password'), findsOneWidget);
  });
}
