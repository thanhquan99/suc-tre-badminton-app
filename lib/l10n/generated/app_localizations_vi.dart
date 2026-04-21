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

  @override
  String get userManagementTooltip => 'Quản lý người dùng';

  @override
  String get usersScreenTitle => 'Người dùng';

  @override
  String get usersSearchHint => 'Tìm theo tên hoặc tên đăng nhập';

  @override
  String get usersRoleFilterAll => 'Tất cả vai trò';

  @override
  String get usersEmpty => 'Không tìm thấy người dùng';

  @override
  String get usersLoadError => 'Không thể tải danh sách người dùng';

  @override
  String usersPaginationInfo(int current, int total) {
    return 'Trang $current / $total';
  }

  @override
  String get createUserTitle => 'Tạo người dùng mới';

  @override
  String get createUserDisplayNameLabel => 'Tên hiển thị';

  @override
  String get createUserDisplayNameValidation => 'Vui lòng nhập tên hiển thị';

  @override
  String get createUserRoleLabel => 'Vai trò';

  @override
  String get createUserSubmitButton => 'Tạo';

  @override
  String get createUserCancelButton => 'Huỷ';

  @override
  String get createUserErrorGeneric =>
      'Không thể tạo người dùng. Vui lòng thử lại.';

  @override
  String get credentialsModalTitle => 'Thông tin đăng nhập';

  @override
  String get credentialsModalWarning =>
      'Mật khẩu này sẽ không hiển thị lại. Vui lòng sao chép ngay.';

  @override
  String get credentialsModalCopyButton => 'Sao chép';

  @override
  String get credentialsModalDoneButton => 'Xong';

  @override
  String get credentialsCopiedSnackbar => 'Đã sao chép thông tin đăng nhập';

  @override
  String get createUserSuccess => 'Đã tạo người dùng';
}
