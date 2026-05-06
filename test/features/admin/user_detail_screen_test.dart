import 'package:badminton_app/core/auth/models/auth_user.dart';
import 'package:badminton_app/core/auth/models/user_role.dart';
import 'package:badminton_app/core/localization/supported_locales.dart';
import 'package:badminton_app/core/users/users_providers.dart';
import 'package:badminton_app/features/admin/presentation/user_detail_screen.dart';
import 'package:badminton_app/l10n/generated/app_localizations.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../../core/users/fakes.dart';

GoRouter buildRouter(String userId) => GoRouter(
      initialLocation: '/admin/users/$userId',
      routes: [
        GoRoute(path: '/', builder: (_, __) => const _StubHome()),
        GoRoute(
          path: '/admin/users/:id',
          builder: (_, state) =>
              UserDetailScreen(userId: state.pathParameters['id']!),
        ),
      ],
    );

class _StubHome extends StatelessWidget {
  const _StubHome();
  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: Text('home-stub')));
}

Widget hostFor(FakeUsersApiClient api, String userId) {
  return ProviderScope(
    overrides: [usersApiClientProvider.overrideWithValue(api)],
    child: MaterialApp.router(
      locale: const Locale('en'),
      supportedLocales: kSupportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      routerConfig: buildRouter(userId),
    ),
  );
}

void main() {
  testWidgets('renders username, role, and editable fields', (tester) async {
    final api = FakeUsersApiClient()
      ..getResult = const AuthUser(
        id: 'u1',
        username: 'alice1',
        displayName: 'Alice',
        role: UserRole.member,
        isActive: true,
      );

    await tester.pumpWidget(hostFor(api, 'u1'));
    await tester.pumpAndSettle();

    expect(find.text('@alice1'), findsOneWidget);
    expect(find.text('Member'), findsOneWidget);
    final saveButton = find.widgetWithText(FilledButton, 'Save changes');
    expect(saveButton, findsOneWidget);
    expect(tester.widget<FilledButton>(saveButton).onPressed, isNull);
  });

  testWidgets('Save enables when displayName changes', (tester) async {
    final api = FakeUsersApiClient()
      ..getResult = const AuthUser(
        id: 'u1',
        username: 'alice1',
        displayName: 'Alice',
        role: UserRole.member,
        isActive: true,
      );

    await tester.pumpWidget(hostFor(api, 'u1'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField), 'Alice B');
    await tester.pump();

    final saveButton = find.widgetWithText(FilledButton, 'Save changes');
    expect(tester.widget<FilledButton>(saveButton).onPressed, isNotNull);
  });

  testWidgets('Save sends only the diff and shows snackbar on success',
      (tester) async {
    final api = FakeUsersApiClient()
      ..getResult = const AuthUser(
        id: 'u1',
        username: 'alice1',
        displayName: 'Alice',
        role: UserRole.member,
        isActive: true,
      )
      ..updateResult = const AuthUser(
        id: 'u1',
        username: 'alice1',
        displayName: 'Alice B',
        role: UserRole.member,
        isActive: true,
      );

    await tester.pumpWidget(hostFor(api, 'u1'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField), 'Alice B');
    await tester.pump();
    await tester.tap(find.widgetWithText(FilledButton, 'Save changes'));
    await tester.pumpAndSettle();

    expect(api.updateCalls, 1);
    expect(api.lastUpdateDisplayName, 'Alice B');
    expect(api.lastUpdateIsActive, isNull);
  });

  testWidgets('renders self-deactivation error message on 400', (tester) async {
    final req = RequestOptions(path: '/users/u1');
    final api = FakeUsersApiClient()
      ..getResult = const AuthUser(
        id: 'u1',
        username: 'alice1',
        displayName: 'Alice',
        role: UserRole.member,
        isActive: true,
      )
      ..updateError = DioException(
        requestOptions: req,
        response: Response(
          requestOptions: req,
          statusCode: 400,
          data: {'message': 'Cannot deactivate your own account'},
        ),
        type: DioExceptionType.badResponse,
      );

    await tester.pumpWidget(hostFor(api, 'u1'));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(SwitchListTile));
    await tester.pump();
    await tester.tap(find.widgetWithText(FilledButton, 'Save changes'));
    await tester.pumpAndSettle();

    expect(find.text("You can't deactivate your own account."), findsOneWidget);
  });

  testWidgets('shows not-found message when initial load returns 404',
      (tester) async {
    final req = RequestOptions(path: '/users/missing');
    final api = FakeUsersApiClient()
      ..getError = DioException(
        requestOptions: req,
        response: Response(requestOptions: req, statusCode: 404),
        type: DioExceptionType.badResponse,
      );

    await tester.pumpWidget(hostFor(api, 'missing'));
    await tester.pumpAndSettle();

    expect(find.text('User not found'), findsOneWidget);
  });
}
