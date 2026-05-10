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

  @override
  String get userDetailScreenTitle => 'Chi tiết người dùng';

  @override
  String get userDetailDisplayNameLabel => 'Tên hiển thị';

  @override
  String get userDetailIsActiveLabel => 'Đang hoạt động';

  @override
  String get userDetailSaveButton => 'Lưu thay đổi';

  @override
  String get userDetailNotFound => 'Không tìm thấy người dùng';

  @override
  String get userDetailLoadError => 'Không thể tải người dùng';

  @override
  String get userUpdatedSuccess => 'Đã cập nhật người dùng';

  @override
  String get userUpdateErrorGeneric =>
      'Không thể cập nhật người dùng. Vui lòng thử lại.';

  @override
  String get userUpdateErrorSelfDeactivate =>
      'Bạn không thể vô hiệu hóa tài khoản của chính mình.';

  @override
  String get userListTileInactiveChip => 'Đã vô hiệu';

  @override
  String get activitiesScreenTitle => 'Hoạt động';

  @override
  String get activitiesTooltip => 'Hoạt động';

  @override
  String get activitiesEmptyDay => 'Không có hoạt động trong ngày này';

  @override
  String get activitiesLoadError => 'Không thể tải hoạt động';

  @override
  String get activityFormatMonth => 'Tháng';

  @override
  String get activityFormatWeek => 'Tuần';

  @override
  String get activityCreateTitle => 'Tạo hoạt động';

  @override
  String get activityEditTitle => 'Sửa hoạt động';

  @override
  String get activityFieldTitle => 'Tiêu đề';

  @override
  String get activityFieldDescription => 'Mô tả';

  @override
  String get activityFieldStartAt => 'Bắt đầu';

  @override
  String get activityFieldEndAt => 'Kết thúc';

  @override
  String get activityValidationTitleRequired => 'Tiêu đề là bắt buộc';

  @override
  String get activityValidationEndAfterStart =>
      'Thời gian kết thúc phải sau thời gian bắt đầu';

  @override
  String get activitySaveButton => 'Lưu';

  @override
  String get activityCreateButton => 'Tạo';

  @override
  String get activityCreateSuccess => 'Đã tạo hoạt động';

  @override
  String get activityUpdateSuccess => 'Đã cập nhật hoạt động';

  @override
  String get activityDeleteConfirmTitle => 'Xóa hoạt động?';

  @override
  String get activityDeleteConfirmBody => 'Hành động này không thể hoàn tác.';

  @override
  String get activityDeleteConfirmButton => 'Xóa';

  @override
  String get activityDeleteCancelButton => 'Hủy';

  @override
  String get activityDeleteSuccess => 'Đã xóa hoạt động';

  @override
  String activityDetailParticipantsHeading(int count) {
    return 'Đã tham gia ($count)';
  }

  @override
  String get activityDetailNoParticipants => 'Chưa có ai tham gia';

  @override
  String activityDetailCreatedBy(String name) {
    return 'Tạo bởi $name';
  }

  @override
  String get activityDetailJoinedBadge => 'Bạn đã tham gia';

  @override
  String get activityDetailNotJoinedBadge => 'Chưa tham gia';

  @override
  String get activityDetailJoinButton => 'Tham gia';

  @override
  String get activityDetailLeaveButton => 'Rời';

  @override
  String get activityDetailEditButton => 'Sửa';

  @override
  String get activityDetailDeleteButton => 'Xóa';

  @override
  String get activityDetailPastBanner => 'Hoạt động này đã diễn ra';

  @override
  String get activityDetailLoadError => 'Không thể tải hoạt động';

  @override
  String get activityDetailNotFound => 'Không tìm thấy hoạt động';

  @override
  String get activityJoinSuccess => 'Đã tham gia';

  @override
  String get activityLeaveSuccess => 'Đã rời';

  @override
  String get activityErrorPastJoin => 'Không thể tham gia hoạt động đã diễn ra';

  @override
  String get activityErrorGeneric => 'Đã xảy ra lỗi. Vui lòng thử lại.';

  @override
  String get activityRetryButton => 'Thử lại';

  @override
  String get navHomeLabel => 'Trang chủ';

  @override
  String get navActivitiesLabel => 'Hoạt động';

  @override
  String get navUsersLabel => 'Người dùng';

  @override
  String get activityFieldType => 'Loại hoạt động';

  @override
  String get activityTypeBadmintonPlay => 'Đánh cầu';

  @override
  String get activityTypeParty => 'Đi nhậu';

  @override
  String get activityTypeOther => 'Khác';

  @override
  String get activityValidationTitleRequiredOther =>
      'Cần nhập tiêu đề khi loại là \'Khác\'';

  @override
  String get activityErrorTitleEditNotAllowed =>
      'Chỉ có thể sửa tiêu đề khi loại là \'Khác\'';
}
