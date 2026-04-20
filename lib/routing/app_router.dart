import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/localization/locale_notifier.dart';
import '../l10n/generated/app_localizations.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),
    ],
  );
});

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final currentLocale = ref.watch(localeNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appTitle),
        actions: [
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
        ],
      ),
      body: Center(
        child: Text(l10n.homeWelcome),
      ),
    );
  }
}
