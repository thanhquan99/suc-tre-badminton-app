// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Vietnamese (`vi`).
class AppLocalizationsVi extends AppLocalizations {
  AppLocalizationsVi([String locale = 'vi']) : super(locale);

  @override
  String get appTitle => 'Câu lạc bộ Cầu lông';

  @override
  String get homeWelcome => 'Chào mừng đến với ứng dụng quản lý CLB Cầu lông';

  @override
  String get languageTooltip => 'Ngôn ngữ';

  @override
  String get loginTitle => 'Đăng nhập';

  @override
  String get usernameLabel => 'Tên đăng nhập';

  @override
  String get passwordLabel => 'Mật khẩu';

  @override
  String get loginButton => 'Đăng nhập';

  @override
  String get loginErrorInvalidCredentials =>
      'Tên đăng nhập hoặc mật khẩu không đúng';

  @override
  String get loginErrorGeneric => 'Đã xảy ra lỗi. Vui lòng thử lại.';

  @override
  String get usernameValidation =>
      'Dùng 3-30 ký tự thường, số, \'.\', \'_\' hoặc \'-\'';

  @override
  String get passwordValidation => 'Vui lòng nhập mật khẩu';

  @override
  String get logoutTooltip => 'Đăng xuất';

  @override
  String get roleAdmin => 'Quản trị viên';

  @override
  String get roleManager => 'Quản lý';

  @override
  String get roleMember => 'Thành viên';
}
