// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Vietnamese (`vi`).
class AppLocalizationsVi extends AppLocalizations {
  AppLocalizationsVi([String locale = 'vi']) : super(locale);

  @override
  String get appTitle => 'Quiz App';

  @override
  String get welcome => 'Chào buổi chiều!';

  @override
  String get searchHint => 'Tìm kiếm quiz, chủ đề...';

  @override
  String get categories => 'Danh mục';

  @override
  String get recent => 'Gần đây';

  @override
  String get popular => 'Phổ biến';

  @override
  String get viewAll => 'Xem tất cả';

  @override
  String get home => 'Trang chủ';

  @override
  String get discover => 'Khám phá';

  @override
  String get createQuiz => 'Tạo quiz';

  @override
  String get profile => 'Cá nhân';

  @override
  String get settings => 'Cài đặt';

  @override
  String get interface => 'Giao diện';

  @override
  String get darkMode => 'Chế độ tối';

  @override
  String get darkModeDesc => 'Bật/tắt giao diện tối';

  @override
  String get language => 'Ngôn ngữ';

  @override
  String get languageDesc => 'Thay đổi ngôn ngữ ứng dụng';

  @override
  String get account => 'Tài khoản';

  @override
  String get signOut => 'Đăng xuất';

  @override
  String get signOutDesc => 'Thoát khỏi tài khoản hiện tại';

  @override
  String get deleteAccount => 'Xóa tài khoản';

  @override
  String get deleteAccountDesc => 'Xóa vĩnh viễn tài khoản và dữ liệu';

  @override
  String get appInfo => 'Quiz App';

  @override
  String get version => 'Phiên bản 1.0.0';

  @override
  String get all => 'Tất cả';

  @override
  String get newest => 'Mới nhất';

  @override
  String get programming => 'Lập trình';

  @override
  String get mathematics => 'Toán học';

  @override
  String get science => 'Khoa học';

  @override
  String get history => 'Lịch sử';

  @override
  String get languageSubject => 'Ngôn ngữ';

  @override
  String get geography => 'Địa lý';

  @override
  String get sports => 'Thể thao';

  @override
  String get entertainment => 'Giải trí';

  @override
  String get general => 'Tổng hợp';

  @override
  String get easy => 'Dễ';

  @override
  String get medium => 'Trung bình';

  @override
  String get hard => 'Khó';

  @override
  String get backToHome => 'Về trang chủ';

  @override
  String get noQuizFound => 'Không tìm thấy quiz nào';

  @override
  String get tryChangeFilter => 'Thử thay đổi bộ lọc hoặc từ khóa tìm kiếm';

  @override
  String get clearFilters => 'Xóa bộ lọc';

  @override
  String get apply => 'Áp dụng';

  @override
  String get difficulty => 'Độ khó';

  @override
  String get category => 'Danh mục';

  @override
  String get advancedFilter => 'Bộ lọc nâng cao';

  @override
  String question(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count câu',
      one: '1 câu',
    );
    return '$_temp0';
  }

  @override
  String attempt(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count',
      one: '1',
      zero: '0',
    );
    return '$_temp0';
  }

  @override
  String get selectLanguage => 'Chọn ngôn ngữ';
}
