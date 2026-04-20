import 'package:flutter/widgets.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'locale_preference.dart';
import 'supported_locales.dart';

part 'locale_notifier.g.dart';

@Riverpod(keepAlive: true)
Locale initialLocale(InitialLocaleRef ref) {
  throw UnimplementedError(
    'initialLocaleProvider must be overridden in ProviderScope with a resolved Locale.',
  );
}

@Riverpod(keepAlive: true)
class LocaleNotifier extends _$LocaleNotifier {
  @override
  Locale build() => ref.watch(initialLocaleProvider);

  Future<void> setLocale(Locale locale) async {
    final matched = matchSupportedLocale(locale);
    if (matched == null) return;
    if (matched == state) return;
    state = matched;
    final prefs = await SharedPreferences.getInstance();
    await LocalePreference.write(prefs, matched);
  }
}
