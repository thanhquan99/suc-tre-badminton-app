import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/auth/auth_notifier.dart';
import '../core/auth/auth_state.dart';
import '../core/auth/models/user_role.dart';
import '../features/activities/presentation/activities_screen.dart';
import '../features/activities/presentation/activity_detail_screen.dart';
import '../features/activities/presentation/activity_form_screen.dart';
import '../features/admin/presentation/user_detail_screen.dart';
import '../features/admin/presentation/users_screen.dart';
import '../features/auth/presentation/login_screen.dart';
import '../features/auth/presentation/splash_screen.dart';
import '../features/home/presentation/home_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final refreshListenable = ValueNotifier<int>(0);
  final sub = ref.listen<AuthState>(
    authNotifierProvider,
    (_, __) => refreshListenable.value++,
  );
  ref.onDispose(() {
    sub.close();
    refreshListenable.dispose();
  });

  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: refreshListenable,
    routes: [
      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (_, __) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (_, __) => const LoginScreen(),
      ),
      GoRoute(
        path: '/',
        name: 'home',
        builder: (_, __) => const HomeScreen(),
      ),
      GoRoute(
        path: '/admin/users',
        name: 'adminUsers',
        builder: (_, __) => const UsersScreen(),
      ),
      GoRoute(
        path: '/admin/users/:id',
        name: 'adminUserDetail',
        builder: (_, state) =>
            UserDetailScreen(userId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/activities',
        name: 'activities',
        builder: (_, __) => const ActivitiesScreen(),
      ),
      GoRoute(
        path: '/activities/new',
        name: 'activityNew',
        builder: (_, __) => const ActivityFormScreen(),
      ),
      GoRoute(
        path: '/activities/:id',
        name: 'activityDetail',
        builder: (_, state) =>
            ActivityDetailScreen(activityId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/activities/:id/edit',
        name: 'activityEdit',
        builder: (_, state) =>
            ActivityFormScreen(activityId: state.pathParameters['id']!),
      ),
    ],
    redirect: (context, goState) {
      final auth = ref.read(authNotifierProvider);
      final loc = goState.matchedLocation;
      switch (auth) {
        case AuthInitial():
          return loc == '/splash' ? null : '/splash';
        case AuthUnauthenticated():
          return loc == '/login' ? null : '/login';
        case AuthAuthenticated(user: final u):
          if (loc == '/splash' || loc == '/login') return '/';
          if (loc.startsWith('/admin/') && u.role != UserRole.admin) {
            return '/';
          }
          // /activities/new and /activities/:id/edit require admin/manager.
          final isActivityWrite = loc == '/activities/new' ||
              (loc.startsWith('/activities/') && loc.endsWith('/edit'));
          if (isActivityWrite &&
              u.role != UserRole.admin &&
              u.role != UserRole.manager) {
            return '/activities';
          }
          return null;
      }
    },
  );
});
