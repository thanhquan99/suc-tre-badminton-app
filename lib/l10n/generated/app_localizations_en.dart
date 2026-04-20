// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Badminton Club';

  @override
  String get homeWelcome => 'Welcome to Badminton Club Tracker';

  @override
  String get languageTooltip => 'Language';

  @override
  String get loginTitle => 'Sign in';

  @override
  String get usernameLabel => 'Username';

  @override
  String get passwordLabel => 'Password';

  @override
  String get loginButton => 'Sign in';

  @override
  String get loginErrorInvalidCredentials => 'Invalid username or password';

  @override
  String get loginErrorGeneric => 'Something went wrong. Please try again.';

  @override
  String get usernameValidation =>
      'Use 3-30 lowercase letters, digits, \'.\', \'_\', or \'-\'';

  @override
  String get passwordValidation => 'Password is required';

  @override
  String get logoutTooltip => 'Sign out';

  @override
  String get roleAdmin => 'Admin';

  @override
  String get roleManager => 'Manager';

  @override
  String get roleMember => 'Member';
}
