import 'package:flutter/widgets.dart';

const List<Locale> kSupportedLocales = [
  Locale('vi'),
  Locale('en'),
];

const Locale kFallbackLocale = Locale('vi');

Locale? matchSupportedLocale(Locale? candidate) {
  if (candidate == null) return null;
  for (final locale in kSupportedLocales) {
    if (locale.languageCode == candidate.languageCode) {
      return locale;
    }
  }
  return null;
}
