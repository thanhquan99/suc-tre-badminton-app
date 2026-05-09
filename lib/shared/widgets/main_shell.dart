import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/auth/auth_notifier.dart';
import '../../core/auth/auth_state.dart';
import '../../core/auth/models/user_role.dart';
import '../../l10n/generated/app_localizations.dart';

class MainShell extends ConsumerWidget {
  const MainShell({
    super.key,
    required this.navigationShell,
  });

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final auth = ref.watch(authNotifierProvider);
    final isAdmin =
        auth is AuthAuthenticated && auth.user.role == UserRole.admin;

    final destinations = <NavigationDestination>[
      NavigationDestination(
        icon: const Icon(Icons.home_outlined),
        selectedIcon: const Icon(Icons.home),
        label: l10n.navHomeLabel,
      ),
      NavigationDestination(
        icon: const Icon(Icons.calendar_month_outlined),
        selectedIcon: const Icon(Icons.calendar_month),
        label: l10n.navActivitiesLabel,
      ),
      if (isAdmin)
        NavigationDestination(
          icon: const Icon(Icons.people_outline),
          selectedIcon: const Icon(Icons.people),
          label: l10n.navUsersLabel,
        ),
    ];

    final currentIndex = navigationShell.currentIndex.clamp(
      0,
      destinations.length - 1,
    );

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (i) => navigationShell.goBranch(
          i,
          initialLocation: i == navigationShell.currentIndex,
        ),
        destinations: destinations,
      ),
    );
  }
}
