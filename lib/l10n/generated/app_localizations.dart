import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_vi.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('vi')
  ];

  /// Application title shown in the AppBar and OS task switcher
  ///
  /// In en, this message translates to:
  /// **'Badminton Club'**
  String get appTitle;

  /// Welcome message on the HomeScreen body
  ///
  /// In en, this message translates to:
  /// **'Welcome to Badminton Club Tracker'**
  String get homeWelcome;

  /// Tooltip for the globe icon that opens the language switcher
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageTooltip;

  /// Title of the login screen
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get loginTitle;

  /// Label for the username input field on the login screen
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get usernameLabel;

  /// Label for the password input field on the login screen
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get passwordLabel;

  /// Submit button on the login screen
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get loginButton;

  /// Error shown when the server rejects login credentials
  ///
  /// In en, this message translates to:
  /// **'Invalid username or password'**
  String get loginErrorInvalidCredentials;

  /// Fallback error shown when login fails for non-credential reasons (network, server)
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get loginErrorGeneric;

  /// Validation hint for the username input field
  ///
  /// In en, this message translates to:
  /// **'Use 3-30 lowercase letters, digits, \'.\', \'_\', or \'-\''**
  String get usernameValidation;

  /// Validation hint for the password input field
  ///
  /// In en, this message translates to:
  /// **'Password is required'**
  String get passwordValidation;

  /// Tooltip for the logout icon in the HomeScreen AppBar
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get logoutTooltip;

  /// Role label for admin users
  ///
  /// In en, this message translates to:
  /// **'Admin'**
  String get roleAdmin;

  /// Role label for manager users
  ///
  /// In en, this message translates to:
  /// **'Manager'**
  String get roleManager;

  /// Role label for member users
  ///
  /// In en, this message translates to:
  /// **'Member'**
  String get roleMember;

  /// Tooltip for the people icon in the HomeScreen AppBar (admin only)
  ///
  /// In en, this message translates to:
  /// **'User management'**
  String get userManagementTooltip;

  /// AppBar title for the admin users screen
  ///
  /// In en, this message translates to:
  /// **'Users'**
  String get usersScreenTitle;

  /// Hint text for the search input on the admin users screen
  ///
  /// In en, this message translates to:
  /// **'Search by name or username'**
  String get usersSearchHint;

  /// Option in the role filter that matches any role
  ///
  /// In en, this message translates to:
  /// **'All roles'**
  String get usersRoleFilterAll;

  /// Empty-state message on the admin users list
  ///
  /// In en, this message translates to:
  /// **'No users found'**
  String get usersEmpty;

  /// Error message when the users list fails to load
  ///
  /// In en, this message translates to:
  /// **'Failed to load users'**
  String get usersLoadError;

  /// Pagination indicator: current page out of total pages
  ///
  /// In en, this message translates to:
  /// **'Page {current} of {total}'**
  String usersPaginationInfo(int current, int total);

  /// Title of the create-user dialog
  ///
  /// In en, this message translates to:
  /// **'Create new user'**
  String get createUserTitle;

  /// Label for the displayName field in the create-user dialog
  ///
  /// In en, this message translates to:
  /// **'Display name'**
  String get createUserDisplayNameLabel;

  /// Validation message when displayName is empty
  ///
  /// In en, this message translates to:
  /// **'Display name is required'**
  String get createUserDisplayNameValidation;

  /// Label for the role selector in the create-user dialog
  ///
  /// In en, this message translates to:
  /// **'Role'**
  String get createUserRoleLabel;

  /// Submit button of the create-user dialog
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get createUserSubmitButton;

  /// Cancel button of the create-user dialog
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get createUserCancelButton;

  /// Generic error when creating a user fails
  ///
  /// In en, this message translates to:
  /// **'Could not create user. Please try again.'**
  String get createUserErrorGeneric;

  /// Title of the credentials modal shown after a user is created
  ///
  /// In en, this message translates to:
  /// **'User credentials'**
  String get credentialsModalTitle;

  /// Warning banner inside the credentials modal
  ///
  /// In en, this message translates to:
  /// **'This password will not be shown again. Copy it now.'**
  String get credentialsModalWarning;

  /// Button that copies both username and password to the clipboard
  ///
  /// In en, this message translates to:
  /// **'Copy credentials'**
  String get credentialsModalCopyButton;

  /// Button that dismisses the credentials modal
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get credentialsModalDoneButton;

  /// Snackbar shown after the admin copies the credentials
  ///
  /// In en, this message translates to:
  /// **'Credentials copied'**
  String get credentialsCopiedSnackbar;

  /// Snackbar shown after a user is created (currently unused; reserved for future UX)
  ///
  /// In en, this message translates to:
  /// **'User created'**
  String get createUserSuccess;

  /// AppBar title for the admin user detail screen
  ///
  /// In en, this message translates to:
  /// **'User detail'**
  String get userDetailScreenTitle;

  /// Label for the editable displayName field on the user detail screen
  ///
  /// In en, this message translates to:
  /// **'Display name'**
  String get userDetailDisplayNameLabel;

  /// Label for the isActive switch on the user detail screen
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get userDetailIsActiveLabel;

  /// Save button on the user detail screen
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get userDetailSaveButton;

  /// Error message when the user detail fails with 404
  ///
  /// In en, this message translates to:
  /// **'User not found'**
  String get userDetailNotFound;

  /// Error message when the user detail fails to load
  ///
  /// In en, this message translates to:
  /// **'Failed to load user'**
  String get userDetailLoadError;

  /// Snackbar shown after a user is successfully updated
  ///
  /// In en, this message translates to:
  /// **'User updated'**
  String get userUpdatedSuccess;

  /// Generic error when updating a user fails
  ///
  /// In en, this message translates to:
  /// **'Could not update user. Please try again.'**
  String get userUpdateErrorGeneric;

  /// Error shown when an admin tries to deactivate their own account
  ///
  /// In en, this message translates to:
  /// **'You can\'t deactivate your own account.'**
  String get userUpdateErrorSelfDeactivate;

  /// Chip label shown on the list tile for users with isActive=false
  ///
  /// In en, this message translates to:
  /// **'Inactive'**
  String get userListTileInactiveChip;

  /// AppBar title for the activities calendar screen
  ///
  /// In en, this message translates to:
  /// **'Activities'**
  String get activitiesScreenTitle;

  /// Tooltip for the calendar icon in the HomeScreen AppBar
  ///
  /// In en, this message translates to:
  /// **'Activities'**
  String get activitiesTooltip;

  /// Agenda empty-state when the selected day has no activities
  ///
  /// In en, this message translates to:
  /// **'No activities on this day'**
  String get activitiesEmptyDay;

  /// Error message when the activities list fails to load
  ///
  /// In en, this message translates to:
  /// **'Failed to load activities'**
  String get activitiesLoadError;

  /// Calendar format toggle label — month view
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get activityFormatMonth;

  /// Calendar format toggle label — week view
  ///
  /// In en, this message translates to:
  /// **'Week'**
  String get activityFormatWeek;

  /// AppBar title for the activity create screen
  ///
  /// In en, this message translates to:
  /// **'New activity'**
  String get activityCreateTitle;

  /// AppBar title for the activity edit screen
  ///
  /// In en, this message translates to:
  /// **'Edit activity'**
  String get activityEditTitle;

  /// Label for the title field on the activity form
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get activityFieldTitle;

  /// Label for the description field on the activity form
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get activityFieldDescription;

  /// Label for the startAt picker on the activity form
  ///
  /// In en, this message translates to:
  /// **'Starts at'**
  String get activityFieldStartAt;

  /// Label for the endAt picker on the activity form
  ///
  /// In en, this message translates to:
  /// **'Ends at'**
  String get activityFieldEndAt;

  /// Validation message when title is empty
  ///
  /// In en, this message translates to:
  /// **'Title is required'**
  String get activityValidationTitleRequired;

  /// Validation message when endAt <= startAt
  ///
  /// In en, this message translates to:
  /// **'End time must be after start time'**
  String get activityValidationEndAfterStart;

  /// Save button on the activity edit form
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get activitySaveButton;

  /// Create button on the activity create form
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get activityCreateButton;

  /// Snackbar shown after an activity is created
  ///
  /// In en, this message translates to:
  /// **'Activity created'**
  String get activityCreateSuccess;

  /// Snackbar shown after an activity is updated
  ///
  /// In en, this message translates to:
  /// **'Activity updated'**
  String get activityUpdateSuccess;

  /// Title of the delete-activity confirm dialog
  ///
  /// In en, this message translates to:
  /// **'Delete activity?'**
  String get activityDeleteConfirmTitle;

  /// Body of the delete-activity confirm dialog
  ///
  /// In en, this message translates to:
  /// **'This cannot be undone.'**
  String get activityDeleteConfirmBody;

  /// Confirm button in the delete-activity dialog
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get activityDeleteConfirmButton;

  /// Cancel button in the delete-activity dialog
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get activityDeleteCancelButton;

  /// Snackbar shown after an activity is deleted
  ///
  /// In en, this message translates to:
  /// **'Activity deleted'**
  String get activityDeleteSuccess;

  /// Heading of the participants section on the activity detail
  ///
  /// In en, this message translates to:
  /// **'Joined ({count})'**
  String activityDetailParticipantsHeading(int count);

  /// Empty-state for the participants list
  ///
  /// In en, this message translates to:
  /// **'No one has joined yet'**
  String get activityDetailNoParticipants;

  /// Caption showing who created the activity
  ///
  /// In en, this message translates to:
  /// **'Created by {name}'**
  String activityDetailCreatedBy(String name);

  /// Badge label when the caller has joined
  ///
  /// In en, this message translates to:
  /// **'You\'re in'**
  String get activityDetailJoinedBadge;

  /// Badge label when the caller has not joined
  ///
  /// In en, this message translates to:
  /// **'Not joined'**
  String get activityDetailNotJoinedBadge;

  /// Join button on the activity detail
  ///
  /// In en, this message translates to:
  /// **'Join'**
  String get activityDetailJoinButton;

  /// Leave button on the activity detail
  ///
  /// In en, this message translates to:
  /// **'Leave'**
  String get activityDetailLeaveButton;

  /// Edit button on the activity detail (admin/manager)
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get activityDetailEditButton;

  /// Delete button on the activity detail (admin/manager)
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get activityDetailDeleteButton;

  /// Banner shown on the activity detail when startAt is in the past
  ///
  /// In en, this message translates to:
  /// **'This activity has already happened'**
  String get activityDetailPastBanner;

  /// Error message when the activity detail fails to load
  ///
  /// In en, this message translates to:
  /// **'Failed to load activity'**
  String get activityDetailLoadError;

  /// Error message when the activity detail returns 404
  ///
  /// In en, this message translates to:
  /// **'Activity not found'**
  String get activityDetailNotFound;

  /// Snackbar shown after a successful join
  ///
  /// In en, this message translates to:
  /// **'Joined activity'**
  String get activityJoinSuccess;

  /// Snackbar shown after a successful leave
  ///
  /// In en, this message translates to:
  /// **'Left activity'**
  String get activityLeaveSuccess;

  /// Error shown when the server rejects a join because the activity has started
  ///
  /// In en, this message translates to:
  /// **'You can\'t join a past activity'**
  String get activityErrorPastJoin;

  /// Generic activity-action error
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get activityErrorGeneric;

  /// Retry button on activity error states
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get activityRetryButton;

  /// Bottom navigation label for the home tab
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHomeLabel;

  /// Bottom navigation label for the activities tab
  ///
  /// In en, this message translates to:
  /// **'Activities'**
  String get navActivitiesLabel;

  /// Bottom navigation label for the admin users tab
  ///
  /// In en, this message translates to:
  /// **'Users'**
  String get navUsersLabel;

  /// Label for the activity type segmented selector on the form
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get activityFieldType;

  /// Label for the badminton_play activity type
  ///
  /// In en, this message translates to:
  /// **'Badminton'**
  String get activityTypeBadmintonPlay;

  /// Label for the party activity type
  ///
  /// In en, this message translates to:
  /// **'Party'**
  String get activityTypeParty;

  /// Label for the other activity type
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get activityTypeOther;

  /// Validation when type=other and title is empty
  ///
  /// In en, this message translates to:
  /// **'Title is required when type is \'Other\''**
  String get activityValidationTitleRequiredOther;

  /// Error mapped from server 400 when caller tries to edit title on a built-in type row
  ///
  /// In en, this message translates to:
  /// **'Title can only be edited for type \'Other\''**
  String get activityErrorTitleEditNotAllowed;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'vi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'vi':
      return AppLocalizationsVi();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
