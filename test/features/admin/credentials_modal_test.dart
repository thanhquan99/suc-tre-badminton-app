import 'package:badminton_app/core/auth/models/auth_user.dart';
import 'package:badminton_app/core/auth/models/user_role.dart';
import 'package:badminton_app/core/localization/supported_locales.dart';
import 'package:badminton_app/core/users/models/create_user_response.dart';
import 'package:badminton_app/features/admin/presentation/dialogs/credentials_modal.dart';
import 'package:badminton_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const response = CreateUserResponse(
    user: AuthUser(
      id: 'new-1',
      username: 'testuser1234',
      displayName: 'Test User',
      role: UserRole.member,
    ),
    password: 'Xa7!pQ9m\$2vR',
  );

  Widget host() => const MaterialApp(
        locale: Locale('en'),
        supportedLocales: kSupportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: Scaffold(body: CredentialsModal(response: response)),
      );

  testWidgets('renders username and password', (tester) async {
    await tester.pumpWidget(host());
    await tester.pumpAndSettle();

    expect(find.text('testuser1234'), findsOneWidget);
    expect(find.text('Xa7!pQ9m\$2vR'), findsOneWidget);
    expect(
      find.text('This password will not be shown again. Copy it now.'),
      findsOneWidget,
    );
  });

  testWidgets('copy button writes two-line text to the clipboard',
      (tester) async {
    final captured = <MethodCall>[];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (call) async {
      if (call.method == 'Clipboard.setData') captured.add(call);
      return null;
    });

    await tester.pumpWidget(host());
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(FilledButton, 'Copy credentials'));
    await tester.pump();

    expect(captured, hasLength(1));
    final text = (captured.single.arguments as Map)['text'] as String;
    expect(text, 'username: testuser1234\npassword: Xa7!pQ9m\$2vR');
    expect(find.text('Credentials copied'), findsOneWidget);

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, null);
  });

  testWidgets('Done button pops the dialog', (tester) async {
    bool popped = false;
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        supportedLocales: kSupportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () async {
                  await showDialog<void>(
                    context: context,
                    barrierDismissible: false,
                    builder: (_) => const CredentialsModal(response: response),
                  );
                  popped = true;
                },
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(FilledButton, 'Done'));
    await tester.pumpAndSettle();

    expect(popped, isTrue);
  });
}
