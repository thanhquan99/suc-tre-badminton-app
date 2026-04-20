import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/auth/auth_notifier.dart';
import '../core/auth/auth_state.dart';
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
    ],
    redirect: (context, goState) {
      final auth = ref.read(authNotifierProvider);
      final loc = goState.matchedLocation;
      return switch (auth) {
        AuthInitial() => loc == '/splash' ? null : '/splash',
        AuthUnauthenticated() => loc == '/login' ? null : '/login',
        AuthAuthenticated() =>
          (loc == '/splash' || loc == '/login') ? '/' : null,
      };
    },
  );
});
