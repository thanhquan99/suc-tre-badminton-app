import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'supported_locales.dart';

class LocalePreference {
  static const String _key = 'app.locale';

  const LocalePreference._();

  static Locale? read(SharedPreferences prefs) {
    final code = prefs.getString(_key);
    if (code == null || code.isEmpty) return null;
    return matchSupportedLocale(Locale(code));
  }

  static Future<void> write(SharedPreferences prefs, Locale locale) async {
    await prefs.setString(_key, locale.languageCode);
  }
}
