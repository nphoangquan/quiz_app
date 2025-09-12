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
/// import 'l10n/app_localizations.dart';
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
    Locale('vi'),
  ];

  /// The title of the application
  ///
  /// In vi, this message translates to:
  /// **'Quiz App'**
  String get appTitle;

  /// Welcome greeting
  ///
  /// In vi, this message translates to:
  /// **'Chào buổi chiều!'**
  String get welcome;

  /// Search bar placeholder text
  ///
  /// In vi, this message translates to:
  /// **'Tìm kiếm quiz, chủ đề...'**
  String get searchHint;

  /// Categories section title
  ///
  /// In vi, this message translates to:
  /// **'Danh mục'**
  String get categories;

  /// Recent section title
  ///
  /// In vi, this message translates to:
  /// **'Gần đây'**
  String get recent;

  /// Popular section title
  ///
  /// In vi, this message translates to:
  /// **'Phổ biến'**
  String get popular;

  /// View all button text
  ///
  /// In vi, this message translates to:
  /// **'Xem tất cả'**
  String get viewAll;

  /// Home tab label
  ///
  /// In vi, this message translates to:
  /// **'Trang chủ'**
  String get home;

  /// Discover tab label
  ///
  /// In vi, this message translates to:
  /// **'Khám phá'**
  String get discover;

  /// Create quiz tab label
  ///
  /// In vi, this message translates to:
  /// **'Tạo quiz'**
  String get createQuiz;

  /// Profile tab label
  ///
  /// In vi, this message translates to:
  /// **'Cá nhân'**
  String get profile;

  /// Settings screen title
  ///
  /// In vi, this message translates to:
  /// **'Cài đặt'**
  String get settings;

  /// Interface settings section
  ///
  /// In vi, this message translates to:
  /// **'Giao diện'**
  String get interface;

  /// Dark mode setting
  ///
  /// In vi, this message translates to:
  /// **'Chế độ tối'**
  String get darkMode;

  /// Dark mode setting description
  ///
  /// In vi, this message translates to:
  /// **'Bật/tắt giao diện tối'**
  String get darkModeDesc;

  /// Language setting
  ///
  /// In vi, this message translates to:
  /// **'Ngôn ngữ'**
  String get language;

  /// Language setting description
  ///
  /// In vi, this message translates to:
  /// **'Thay đổi ngôn ngữ ứng dụng'**
  String get languageDesc;

  /// Account settings section
  ///
  /// In vi, this message translates to:
  /// **'Tài khoản'**
  String get account;

  /// Sign out button
  ///
  /// In vi, this message translates to:
  /// **'Đăng xuất'**
  String get signOut;

  /// Sign out description
  ///
  /// In vi, this message translates to:
  /// **'Thoát khỏi tài khoản hiện tại'**
  String get signOutDesc;

  /// Delete account button
  ///
  /// In vi, this message translates to:
  /// **'Xóa tài khoản'**
  String get deleteAccount;

  /// Delete account description
  ///
  /// In vi, this message translates to:
  /// **'Xóa vĩnh viễn tài khoản và dữ liệu'**
  String get deleteAccountDesc;

  /// App info section
  ///
  /// In vi, this message translates to:
  /// **'Quiz App'**
  String get appInfo;

  /// App version
  ///
  /// In vi, this message translates to:
  /// **'Phiên bản 1.0.0'**
  String get version;

  /// All filter option
  ///
  /// In vi, this message translates to:
  /// **'Tất cả'**
  String get all;

  /// Newest sort option
  ///
  /// In vi, this message translates to:
  /// **'Mới nhất'**
  String get newest;

  /// Programming category
  ///
  /// In vi, this message translates to:
  /// **'Lập trình'**
  String get programming;

  /// Mathematics category
  ///
  /// In vi, this message translates to:
  /// **'Toán học'**
  String get mathematics;

  /// Science category
  ///
  /// In vi, this message translates to:
  /// **'Khoa học'**
  String get science;

  /// History category
  ///
  /// In vi, this message translates to:
  /// **'Lịch sử'**
  String get history;

  /// Language subject category
  ///
  /// In vi, this message translates to:
  /// **'Ngôn ngữ'**
  String get languageSubject;

  /// Geography category
  ///
  /// In vi, this message translates to:
  /// **'Địa lý'**
  String get geography;

  /// Sports category
  ///
  /// In vi, this message translates to:
  /// **'Thể thao'**
  String get sports;

  /// Entertainment category
  ///
  /// In vi, this message translates to:
  /// **'Giải trí'**
  String get entertainment;

  /// General category
  ///
  /// In vi, this message translates to:
  /// **'Tổng hợp'**
  String get general;

  /// Easy difficulty
  ///
  /// In vi, this message translates to:
  /// **'Dễ'**
  String get easy;

  /// Medium difficulty
  ///
  /// In vi, this message translates to:
  /// **'Trung bình'**
  String get medium;

  /// Hard difficulty
  ///
  /// In vi, this message translates to:
  /// **'Khó'**
  String get hard;

  /// Back to home button
  ///
  /// In vi, this message translates to:
  /// **'Về trang chủ'**
  String get backToHome;

  /// No quiz found message
  ///
  /// In vi, this message translates to:
  /// **'Không tìm thấy quiz nào'**
  String get noQuizFound;

  /// Try change filter message
  ///
  /// In vi, this message translates to:
  /// **'Thử thay đổi bộ lọc hoặc từ khóa tìm kiếm'**
  String get tryChangeFilter;

  /// Clear filters button
  ///
  /// In vi, this message translates to:
  /// **'Xóa bộ lọc'**
  String get clearFilters;

  /// Apply button
  ///
  /// In vi, this message translates to:
  /// **'Áp dụng'**
  String get apply;

  /// Difficulty label
  ///
  /// In vi, this message translates to:
  /// **'Độ khó'**
  String get difficulty;

  /// Category label
  ///
  /// In vi, this message translates to:
  /// **'Danh mục'**
  String get category;

  /// Advanced filter tooltip
  ///
  /// In vi, this message translates to:
  /// **'Bộ lọc nâng cao'**
  String get advancedFilter;

  /// Question count
  ///
  /// In vi, this message translates to:
  /// **'{count, plural, =1{1 câu} other{{count} câu}}'**
  String question(int count);

  /// Attempt count
  ///
  /// In vi, this message translates to:
  /// **'{count, plural, =0{0} =1{1} other{{count}}}'**
  String attempt(int count);

  /// Select language dialog title
  ///
  /// In vi, this message translates to:
  /// **'Chọn ngôn ngữ'**
  String get selectLanguage;
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
    'that was used.',
  );
}
