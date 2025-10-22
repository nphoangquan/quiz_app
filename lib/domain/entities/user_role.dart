/// Enum định nghĩa các vai trò người dùng trong hệ thống
enum UserRole {
  /// Người dùng thường
  user,

  /// Quản trị viên
  admin,
}

extension UserRoleExtension on UserRole {
  /// Chuyển đổi từ string sang UserRole
  static UserRole fromString(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return UserRole.admin;
      case 'user':
      default:
        return UserRole.user;
    }
  }

  /// Chuyển đổi UserRole sang string
  String get value {
    switch (this) {
      case UserRole.admin:
        return 'admin';
      case UserRole.user:
        return 'user';
    }
  }

  /// Kiểm tra có phải admin không
  bool get isAdmin => this == UserRole.admin;

  /// Kiểm tra có phải user thường không
  bool get isUser => this == UserRole.user;

  /// Tên hiển thị bằng tiếng Việt
  String get displayName {
    switch (this) {
      case UserRole.admin:
        return 'Quản trị viên';
      case UserRole.user:
        return 'Người dùng';
    }
  }

  /// Mô tả vai trò
  String get description {
    switch (this) {
      case UserRole.admin:
        return 'Có quyền truy cập Dashboard và quản lý hệ thống';
      case UserRole.user:
        return 'Người dùng thường, có thể tạo và chơi quiz';
    }
  }

  /// Danh sách quyền hạn
  List<String> get permissions {
    switch (this) {
      case UserRole.admin:
        return [
          'Truy cập Dashboard',
          'Quản lý Categories',
          'Xem thống kê hệ thống',
          'Tất cả quyền của User',
        ];
      case UserRole.user:
        return [
          'Tạo quiz',
          'Chơi quiz',
          'Xem thống kê cá nhân',
          'Quản lý quiz của mình',
        ];
    }
  }
}
