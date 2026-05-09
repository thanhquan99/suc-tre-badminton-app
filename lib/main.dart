import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'core/localization/initial_locale.dart';
import 'core/localization/locale_notifier.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initializeDateFormatting('vi_VN');
  await initializeDateFormatting('en');

  final prefs = await SharedPreferences.getInstance();
  final deviceLocale = WidgetsBinding.instance.platformDispatcher.locale;
  final initial = resolveInitialLocale(prefs, deviceLocale);

  runApp(
    ProviderScope(
      overrides: [
        initialLocaleProvider.overrideWithValue(initial),
      ],
      child: const BadmintonApp(),
    ),
  );
}
