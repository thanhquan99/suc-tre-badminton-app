import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/auth/auth_notifier.dart';
import '../../../core/auth/auth_state.dart';
import '../../../core/auth/models/user_role.dart';
import '../../../core/localization/locale_notifier.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../auth/presentation/widgets/role_badge.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final currentLocale = ref.watch(localeNotifierProvider);
    final auth = ref.watch(authNotifierProvider);
    final user = auth is AuthAuthenticated ? auth.user : null;

    return Scaffold(
      appBar: AppBar(
        title: Text(user?.displayName ?? l10n.appTitle),
        actions: [
          if (user != null) RoleBadge(role: user.role),
          if (user != null)
            IconButton(
              icon: const Icon(Icons.calendar_month_outlined),
              tooltip: l10n.activitiesTooltip,
              onPressed: () => context.go('/activities'),
            ),
          if (user != null && user.role == UserRole.admin)
            IconButton(
              icon: const Icon(Icons.people_outline),
              tooltip: l10n.userManagementTooltip,
              onPressed: () => context.go('/admin/users'),
            ),
          PopupMenuButton<Locale>(
            icon: const Icon(Icons.language),
            tooltip: l10n.languageTooltip,
            initialValue: currentLocale,
            onSelected: (locale) =>
                ref.read(localeNotifierProvider.notifier).setLocale(locale),
            itemBuilder: (_) => const [
              PopupMenuItem(
                value: Locale('vi'),
                child: Text('Tiếng Việt'),
              ),
              PopupMenuItem(
                value: Locale('en'),
                child: Text('English'),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: l10n.logoutTooltip,
            onPressed: () => ref.read(authNotifierProvider.notifier).logout(),
          ),
        ],
      ),
      body: Center(child: Text(l10n.homeWelcome)),
    );
  }
}
