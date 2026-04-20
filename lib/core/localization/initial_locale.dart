import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'locale_preference.dart';
import 'supported_locales.dart';

Locale resolveInitialLocale(SharedPreferences prefs, Locale? deviceLocale) {
  final saved = LocalePreference.read(prefs);
  if (saved != null) return saved;

  final matched = matchSupportedLocale(deviceLocale);
  if (matched != null) return matched;

  return kFallbackLocale;
}
