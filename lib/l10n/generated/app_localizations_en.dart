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

  @override
  String get userManagementTooltip => 'User management';

  @override
  String get usersScreenTitle => 'Users';

  @override
  String get usersSearchHint => 'Search by name or username';

  @override
  String get usersRoleFilterAll => 'All roles';

  @override
  String get usersEmpty => 'No users found';

  @override
  String get usersLoadError => 'Failed to load users';

  @override
  String usersPaginationInfo(int current, int total) {
    return 'Page $current of $total';
  }

  @override
  String get createUserTitle => 'Create new user';

  @override
  String get createUserDisplayNameLabel => 'Display name';

  @override
  String get createUserDisplayNameValidation => 'Display name is required';

  @override
  String get createUserRoleLabel => 'Role';

  @override
  String get createUserSubmitButton => 'Create';

  @override
  String get createUserCancelButton => 'Cancel';

  @override
  String get createUserErrorGeneric =>
      'Could not create user. Please try again.';

  @override
  String get credentialsModalTitle => 'User credentials';

  @override
  String get credentialsModalWarning =>
      'This password will not be shown again. Copy it now.';

  @override
  String get credentialsModalCopyButton => 'Copy credentials';

  @override
  String get credentialsModalDoneButton => 'Done';

  @override
  String get credentialsCopiedSnackbar => 'Credentials copied';

  @override
  String get createUserSuccess => 'User created';
}
