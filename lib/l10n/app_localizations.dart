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

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
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
    Locale('vi'),
    Locale('en'),
  ];

  /// No description provided for @appName.
  ///
  /// In vi, this message translates to:
  /// **'OneIP'**
  String get appName;

  /// No description provided for @appTagline.
  ///
  /// In vi, this message translates to:
  /// **'Nền tảng thông minh cho KCN Việt Nam'**
  String get appTagline;

  /// No description provided for @navSiteSelection.
  ///
  /// In vi, this message translates to:
  /// **'Chọn địa điểm'**
  String get navSiteSelection;

  /// No description provided for @navLeaseTracker.
  ///
  /// In vi, this message translates to:
  /// **'Giá thuê'**
  String get navLeaseTracker;

  /// No description provided for @navPermitChecklist.
  ///
  /// In vi, this message translates to:
  /// **'Giấy phép'**
  String get navPermitChecklist;

  /// No description provided for @navProfile.
  ///
  /// In vi, this message translates to:
  /// **'Hồ sơ'**
  String get navProfile;

  /// No description provided for @authLogin.
  ///
  /// In vi, this message translates to:
  /// **'Đăng nhập'**
  String get authLogin;

  /// No description provided for @authRegister.
  ///
  /// In vi, this message translates to:
  /// **'Đăng ký'**
  String get authRegister;

  /// No description provided for @authEmail.
  ///
  /// In vi, this message translates to:
  /// **'Email'**
  String get authEmail;

  /// No description provided for @authPassword.
  ///
  /// In vi, this message translates to:
  /// **'Mật khẩu'**
  String get authPassword;

  /// No description provided for @authConfirmPassword.
  ///
  /// In vi, this message translates to:
  /// **'Xác nhận mật khẩu'**
  String get authConfirmPassword;

  /// No description provided for @authForgotPassword.
  ///
  /// In vi, this message translates to:
  /// **'Quên mật khẩu?'**
  String get authForgotPassword;

  /// No description provided for @authLoginSubtitle.
  ///
  /// In vi, this message translates to:
  /// **'Đăng nhập để tiếp tục'**
  String get authLoginSubtitle;

  /// No description provided for @authNoAccount.
  ///
  /// In vi, this message translates to:
  /// **'Chưa có tài khoản?'**
  String get authNoAccount;

  /// No description provided for @authHaveAccount.
  ///
  /// In vi, this message translates to:
  /// **'Đã có tài khoản?'**
  String get authHaveAccount;

  /// No description provided for @authContinueGoogle.
  ///
  /// In vi, this message translates to:
  /// **'Tiếp tục với Google'**
  String get authContinueGoogle;

  /// No description provided for @authOr.
  ///
  /// In vi, this message translates to:
  /// **'hoặc'**
  String get authOr;

  /// No description provided for @authFullName.
  ///
  /// In vi, this message translates to:
  /// **'Họ và tên'**
  String get authFullName;

  /// No description provided for @authCompany.
  ///
  /// In vi, this message translates to:
  /// **'Tên công ty'**
  String get authCompany;

  /// No description provided for @authRole.
  ///
  /// In vi, this message translates to:
  /// **'Vai trò'**
  String get authRole;

  /// No description provided for @authRoleInvestor.
  ///
  /// In vi, this message translates to:
  /// **'Nhà đầu tư FDI'**
  String get authRoleInvestor;

  /// No description provided for @authRoleBroker.
  ///
  /// In vi, this message translates to:
  /// **'Môi giới BĐS'**
  String get authRoleBroker;

  /// No description provided for @authRoleTenant.
  ///
  /// In vi, this message translates to:
  /// **'Chủ thuê KCN'**
  String get authRoleTenant;

  /// No description provided for @authRoleDeveloper.
  ///
  /// In vi, this message translates to:
  /// **'Developer KCN'**
  String get authRoleDeveloper;

  /// No description provided for @authRoleOther.
  ///
  /// In vi, this message translates to:
  /// **'Khác'**
  String get authRoleOther;

  /// No description provided for @authSendResetLink.
  ///
  /// In vi, this message translates to:
  /// **'Gửi link đặt lại mật khẩu'**
  String get authSendResetLink;

  /// No description provided for @authLogout.
  ///
  /// In vi, this message translates to:
  /// **'Đăng xuất'**
  String get authLogout;

  /// No description provided for @siteSelectionTitle.
  ///
  /// In vi, this message translates to:
  /// **'Tìm Khu Công Nghiệp'**
  String get siteSelectionTitle;

  /// No description provided for @siteSelectionSubtitle.
  ///
  /// In vi, this message translates to:
  /// **'Chọn địa điểm FDI lý tưởng'**
  String get siteSelectionSubtitle;

  /// No description provided for @siteSelectionIndustry.
  ///
  /// In vi, this message translates to:
  /// **'Ngành công nghiệp'**
  String get siteSelectionIndustry;

  /// No description provided for @siteSelectionArea.
  ///
  /// In vi, this message translates to:
  /// **'Diện tích cần thuê'**
  String get siteSelectionArea;

  /// No description provided for @siteSelectionHeadcount.
  ///
  /// In vi, this message translates to:
  /// **'Số lượng nhân sự'**
  String get siteSelectionHeadcount;

  /// No description provided for @siteSelectionRegion.
  ///
  /// In vi, this message translates to:
  /// **'Khu vực ưu tiên'**
  String get siteSelectionRegion;

  /// No description provided for @siteSelectionPriority.
  ///
  /// In vi, this message translates to:
  /// **'Yếu tố ưu tiên'**
  String get siteSelectionPriority;

  /// No description provided for @siteSelectionBudget.
  ///
  /// In vi, this message translates to:
  /// **'Ngân sách tối đa (tùy chọn)'**
  String get siteSelectionBudget;

  /// No description provided for @siteSelectionSearch.
  ///
  /// In vi, this message translates to:
  /// **'Tìm kiếm'**
  String get siteSelectionSearch;

  /// No description provided for @siteSelectionSearchAgain.
  ///
  /// In vi, this message translates to:
  /// **'Tìm kiếm lại'**
  String get siteSelectionSearchAgain;

  /// No description provided for @siteSelectionResults.
  ///
  /// In vi, this message translates to:
  /// **'Tìm thấy {count} khu công nghiệp phù hợp'**
  String siteSelectionResults(int count);

  /// No description provided for @siteSelectionNoResults.
  ///
  /// In vi, this message translates to:
  /// **'Không tìm thấy KCN phù hợp. Hãy điều chỉnh tiêu chí tìm kiếm.'**
  String get siteSelectionNoResults;

  /// No description provided for @siteSelectionViewDetail.
  ///
  /// In vi, this message translates to:
  /// **'Xem chi tiết'**
  String get siteSelectionViewDetail;

  /// No description provided for @siteSelectionCompare.
  ///
  /// In vi, this message translates to:
  /// **'So sánh'**
  String get siteSelectionCompare;

  /// No description provided for @siteSelectionContact.
  ///
  /// In vi, this message translates to:
  /// **'Liên hệ tư vấn'**
  String get siteSelectionContact;

  /// No description provided for @siteSelectionSave.
  ///
  /// In vi, this message translates to:
  /// **'Lưu kết quả'**
  String get siteSelectionSave;

  /// No description provided for @regionAll.
  ///
  /// In vi, this message translates to:
  /// **'Tất cả'**
  String get regionAll;

  /// No description provided for @regionNorth.
  ///
  /// In vi, this message translates to:
  /// **'Miền Bắc'**
  String get regionNorth;

  /// No description provided for @regionCentral.
  ///
  /// In vi, this message translates to:
  /// **'Miền Trung'**
  String get regionCentral;

  /// No description provided for @regionSouth.
  ///
  /// In vi, this message translates to:
  /// **'Miền Nam'**
  String get regionSouth;

  /// No description provided for @industryElectronics.
  ///
  /// In vi, this message translates to:
  /// **'Điện tử'**
  String get industryElectronics;

  /// No description provided for @industryAutoParts.
  ///
  /// In vi, this message translates to:
  /// **'Linh kiện ô tô'**
  String get industryAutoParts;

  /// No description provided for @industryGarment.
  ///
  /// In vi, this message translates to:
  /// **'May mặc & Giày dép'**
  String get industryGarment;

  /// No description provided for @industryFoodProcessing.
  ///
  /// In vi, this message translates to:
  /// **'Chế biến thực phẩm'**
  String get industryFoodProcessing;

  /// No description provided for @industryHeavy.
  ///
  /// In vi, this message translates to:
  /// **'Công nghiệp nặng'**
  String get industryHeavy;

  /// No description provided for @industryLogistics.
  ///
  /// In vi, this message translates to:
  /// **'Logistics'**
  String get industryLogistics;

  /// No description provided for @industryPetrochemical.
  ///
  /// In vi, this message translates to:
  /// **'Hóa dầu'**
  String get industryPetrochemical;

  /// No description provided for @industryHighTech.
  ///
  /// In vi, this message translates to:
  /// **'Công nghệ cao'**
  String get industryHighTech;

  /// No description provided for @industryManufacturing.
  ///
  /// In vi, this message translates to:
  /// **'Sản xuất'**
  String get industryManufacturing;

  /// No description provided for @industryOther.
  ///
  /// In vi, this message translates to:
  /// **'Khác'**
  String get industryOther;

  /// No description provided for @priorityInfra.
  ///
  /// In vi, this message translates to:
  /// **'Hạ tầng'**
  String get priorityInfra;

  /// No description provided for @priorityLabor.
  ///
  /// In vi, this message translates to:
  /// **'Lao động'**
  String get priorityLabor;

  /// No description provided for @priorityLogistics.
  ///
  /// In vi, this message translates to:
  /// **'Logistics'**
  String get priorityLogistics;

  /// No description provided for @priorityPrice.
  ///
  /// In vi, this message translates to:
  /// **'Giá thuê'**
  String get priorityPrice;

  /// No description provided for @priorityTax.
  ///
  /// In vi, this message translates to:
  /// **'Ưu đãi thuế'**
  String get priorityTax;

  /// No description provided for @zoneLeasePrice.
  ///
  /// In vi, this message translates to:
  /// **'Giá thuê'**
  String get zoneLeasePrice;

  /// No description provided for @zoneAvailableArea.
  ///
  /// In vi, this message translates to:
  /// **'Diện tích trống'**
  String get zoneAvailableArea;

  /// No description provided for @zoneSeaport.
  ///
  /// In vi, this message translates to:
  /// **'Cảng biển'**
  String get zoneSeaport;

  /// No description provided for @zoneAirport.
  ///
  /// In vi, this message translates to:
  /// **'Sân bay'**
  String get zoneAirport;

  /// No description provided for @zoneOccupancy.
  ///
  /// In vi, this message translates to:
  /// **'Tỷ lệ lấp đầy'**
  String get zoneOccupancy;

  /// No description provided for @zoneTaxIncentive.
  ///
  /// In vi, this message translates to:
  /// **'Ưu đãi thuế {years} năm'**
  String zoneTaxIncentive(int years);

  /// No description provided for @zoneOverallScore.
  ///
  /// In vi, this message translates to:
  /// **'Điểm tổng hợp'**
  String get zoneOverallScore;

  /// No description provided for @zoneInfraScore.
  ///
  /// In vi, this message translates to:
  /// **'Hạ tầng'**
  String get zoneInfraScore;

  /// No description provided for @zoneLaborScore.
  ///
  /// In vi, this message translates to:
  /// **'Lao động'**
  String get zoneLaborScore;

  /// No description provided for @zoneLogisticsScore.
  ///
  /// In vi, this message translates to:
  /// **'Logistics'**
  String get zoneLogisticsScore;

  /// No description provided for @leaseTrackerTitle.
  ///
  /// In vi, this message translates to:
  /// **'Theo dõi giá thuê KCN'**
  String get leaseTrackerTitle;

  /// No description provided for @leaseTrackerMarket.
  ///
  /// In vi, this message translates to:
  /// **'Thị Trường'**
  String get leaseTrackerMarket;

  /// No description provided for @leaseTrackerAlerts.
  ///
  /// In vi, this message translates to:
  /// **'Price Alerts'**
  String get leaseTrackerAlerts;

  /// No description provided for @leaseTrackerMarketOverview.
  ///
  /// In vi, this message translates to:
  /// **'Tổng quan thị trường'**
  String get leaseTrackerMarketOverview;

  /// No description provided for @leaseTrackerChart.
  ///
  /// In vi, this message translates to:
  /// **'Biểu đồ giá theo thời gian'**
  String get leaseTrackerChart;

  /// No description provided for @leaseTrackerTable.
  ///
  /// In vi, this message translates to:
  /// **'Bảng giá hiện tại'**
  String get leaseTrackerTable;

  /// No description provided for @leaseTrackerNews.
  ///
  /// In vi, this message translates to:
  /// **'Tin tức thị trường'**
  String get leaseTrackerNews;

  /// No description provided for @leaseTrackerAvgPrice.
  ///
  /// In vi, this message translates to:
  /// **'Giá trung bình'**
  String get leaseTrackerAvgPrice;

  /// No description provided for @leaseTrackerNoAlerts.
  ///
  /// In vi, this message translates to:
  /// **'Chưa có alert nào. Tạo alert đầu tiên!'**
  String get leaseTrackerNoAlerts;

  /// No description provided for @leaseTrackerCreateAlert.
  ///
  /// In vi, this message translates to:
  /// **'Tạo Alert'**
  String get leaseTrackerCreateAlert;

  /// No description provided for @leaseTrackerFreeDelay.
  ///
  /// In vi, this message translates to:
  /// **'Dữ liệu miễn phí có độ trễ 30 ngày. Nâng cấp Pro để nhận số liệu thời gian thực.'**
  String get leaseTrackerFreeDelay;

  /// No description provided for @leaseTrackerUpgrade.
  ///
  /// In vi, this message translates to:
  /// **'Nâng cấp'**
  String get leaseTrackerUpgrade;

  /// No description provided for @leaseTrackerPriceAbove.
  ///
  /// In vi, this message translates to:
  /// **'Khi giá vượt'**
  String get leaseTrackerPriceAbove;

  /// No description provided for @leaseTrackerPriceBelow.
  ///
  /// In vi, this message translates to:
  /// **'Khi giá xuống dưới'**
  String get leaseTrackerPriceBelow;

  /// No description provided for @assetFactory.
  ///
  /// In vi, this message translates to:
  /// **'Nhà xưởng'**
  String get assetFactory;

  /// No description provided for @assetWarehouse.
  ///
  /// In vi, this message translates to:
  /// **'Kho bãi'**
  String get assetWarehouse;

  /// No description provided for @assetLand.
  ///
  /// In vi, this message translates to:
  /// **'Đất KCN'**
  String get assetLand;

  /// No description provided for @assetOffice.
  ///
  /// In vi, this message translates to:
  /// **'Văn phòng'**
  String get assetOffice;

  /// No description provided for @permitTitle.
  ///
  /// In vi, this message translates to:
  /// **'Quản lý Giấy phép KCN'**
  String get permitTitle;

  /// No description provided for @permitCreateNew.
  ///
  /// In vi, this message translates to:
  /// **'Tạo checklist mới'**
  String get permitCreateNew;

  /// No description provided for @permitChooseType.
  ///
  /// In vi, this message translates to:
  /// **'Chọn loại thủ tục'**
  String get permitChooseType;

  /// No description provided for @permitNoChecklist.
  ///
  /// In vi, this message translates to:
  /// **'Chưa có checklist nào'**
  String get permitNoChecklist;

  /// No description provided for @permitNoChecklistSub.
  ///
  /// In vi, this message translates to:
  /// **'Tạo checklist thủ tục để theo dõi tiến độ xin giấy phép KCN của bạn.'**
  String get permitNoChecklistSub;

  /// No description provided for @permitCreateChecklist.
  ///
  /// In vi, this message translates to:
  /// **'Tạo Checklist'**
  String get permitCreateChecklist;

  /// No description provided for @permitProjectName.
  ///
  /// In vi, this message translates to:
  /// **'Tên dự án'**
  String get permitProjectName;

  /// No description provided for @permitCompanyName.
  ///
  /// In vi, this message translates to:
  /// **'Tên công ty'**
  String get permitCompanyName;

  /// No description provided for @permitProvince.
  ///
  /// In vi, this message translates to:
  /// **'Tỉnh/thành phố'**
  String get permitProvince;

  /// No description provided for @permitInvestment.
  ///
  /// In vi, this message translates to:
  /// **'Vốn đầu tư dự kiến (USD)'**
  String get permitInvestment;

  /// No description provided for @permitProgress.
  ///
  /// In vi, this message translates to:
  /// **'Tiến độ'**
  String get permitProgress;

  /// No description provided for @permitTotalSteps.
  ///
  /// In vi, this message translates to:
  /// **'Tổng {count} bước'**
  String permitTotalSteps(int count);

  /// No description provided for @permitCompleted.
  ///
  /// In vi, this message translates to:
  /// **'Hoàn thành {count}'**
  String permitCompleted(int count);

  /// No description provided for @permitExportPDF.
  ///
  /// In vi, this message translates to:
  /// **'Xuất PDF'**
  String get permitExportPDF;

  /// No description provided for @permitShare.
  ///
  /// In vi, this message translates to:
  /// **'Chia sẻ'**
  String get permitShare;

  /// No description provided for @statusPending.
  ///
  /// In vi, this message translates to:
  /// **'Chờ xử lý'**
  String get statusPending;

  /// No description provided for @statusInProgress.
  ///
  /// In vi, this message translates to:
  /// **'Đang thực hiện'**
  String get statusInProgress;

  /// No description provided for @statusDone.
  ///
  /// In vi, this message translates to:
  /// **'Hoàn thành'**
  String get statusDone;

  /// No description provided for @statusSkipped.
  ///
  /// In vi, this message translates to:
  /// **'Bỏ qua'**
  String get statusSkipped;

  /// No description provided for @statusBlocked.
  ///
  /// In vi, this message translates to:
  /// **'Bị chặn'**
  String get statusBlocked;

  /// No description provided for @difficultyEasy.
  ///
  /// In vi, this message translates to:
  /// **'Đơn giản'**
  String get difficultyEasy;

  /// No description provided for @difficultyMedium.
  ///
  /// In vi, this message translates to:
  /// **'Trung bình'**
  String get difficultyMedium;

  /// No description provided for @difficultyComplex.
  ///
  /// In vi, this message translates to:
  /// **'Phức tạp'**
  String get difficultyComplex;

  /// No description provided for @profileTitle.
  ///
  /// In vi, this message translates to:
  /// **'Hồ sơ'**
  String get profileTitle;

  /// No description provided for @profilePlan.
  ///
  /// In vi, this message translates to:
  /// **'Gói hiện tại'**
  String get profilePlan;

  /// No description provided for @profilePlanFree.
  ///
  /// In vi, this message translates to:
  /// **'Miễn phí'**
  String get profilePlanFree;

  /// No description provided for @profilePlanPro.
  ///
  /// In vi, this message translates to:
  /// **'Pro'**
  String get profilePlanPro;

  /// No description provided for @profilePlanEnterprise.
  ///
  /// In vi, this message translates to:
  /// **'Enterprise'**
  String get profilePlanEnterprise;

  /// No description provided for @profileUpgrade.
  ///
  /// In vi, this message translates to:
  /// **'Nâng cấp lên Pro'**
  String get profileUpgrade;

  /// No description provided for @profileLanguage.
  ///
  /// In vi, this message translates to:
  /// **'Ngôn ngữ / Language'**
  String get profileLanguage;

  /// No description provided for @profileAccountInfo.
  ///
  /// In vi, this message translates to:
  /// **'Thông tin tài khoản'**
  String get profileAccountInfo;

  /// No description provided for @profileChangePassword.
  ///
  /// In vi, this message translates to:
  /// **'Đổi mật khẩu'**
  String get profileChangePassword;

  /// No description provided for @profileLogout.
  ///
  /// In vi, this message translates to:
  /// **'Đăng xuất'**
  String get profileLogout;

  /// No description provided for @planFree.
  ///
  /// In vi, this message translates to:
  /// **'Miễn phí'**
  String get planFree;

  /// No description provided for @planPro.
  ///
  /// In vi, this message translates to:
  /// **'Pro'**
  String get planPro;

  /// No description provided for @planEnterprise.
  ///
  /// In vi, this message translates to:
  /// **'Enterprise'**
  String get planEnterprise;

  /// No description provided for @planUpgradeTitle.
  ///
  /// In vi, this message translates to:
  /// **'Nâng cấp lên Pro'**
  String get planUpgradeTitle;

  /// No description provided for @planUpgradeSubtitle.
  ///
  /// In vi, this message translates to:
  /// **'Mở khóa toàn bộ tính năng OneIP'**
  String get planUpgradeSubtitle;

  /// No description provided for @planUpgradeButton.
  ///
  /// In vi, this message translates to:
  /// **'Nâng cấp ngay'**
  String get planUpgradeButton;

  /// No description provided for @commonSave.
  ///
  /// In vi, this message translates to:
  /// **'Lưu'**
  String get commonSave;

  /// No description provided for @commonCancel.
  ///
  /// In vi, this message translates to:
  /// **'Hủy'**
  String get commonCancel;

  /// No description provided for @commonConfirm.
  ///
  /// In vi, this message translates to:
  /// **'Xác nhận'**
  String get commonConfirm;

  /// No description provided for @commonDelete.
  ///
  /// In vi, this message translates to:
  /// **'Xóa'**
  String get commonDelete;

  /// No description provided for @commonEdit.
  ///
  /// In vi, this message translates to:
  /// **'Chỉnh sửa'**
  String get commonEdit;

  /// No description provided for @commonClose.
  ///
  /// In vi, this message translates to:
  /// **'Đóng'**
  String get commonClose;

  /// No description provided for @commonSearch.
  ///
  /// In vi, this message translates to:
  /// **'Tìm kiếm'**
  String get commonSearch;

  /// No description provided for @commonFilter.
  ///
  /// In vi, this message translates to:
  /// **'Lọc'**
  String get commonFilter;

  /// No description provided for @commonSort.
  ///
  /// In vi, this message translates to:
  /// **'Sắp xếp'**
  String get commonSort;

  /// No description provided for @commonRetry.
  ///
  /// In vi, this message translates to:
  /// **'Thử lại'**
  String get commonRetry;

  /// No description provided for @commonLoading.
  ///
  /// In vi, this message translates to:
  /// **'Đang tải...'**
  String get commonLoading;

  /// No description provided for @commonError.
  ///
  /// In vi, this message translates to:
  /// **'Đã xảy ra lỗi'**
  String get commonError;

  /// No description provided for @commonNoData.
  ///
  /// In vi, this message translates to:
  /// **'Không có dữ liệu'**
  String get commonNoData;

  /// No description provided for @commonNoLimit.
  ///
  /// In vi, this message translates to:
  /// **'Không giới hạn'**
  String get commonNoLimit;

  /// No description provided for @commonPerson.
  ///
  /// In vi, this message translates to:
  /// **'người'**
  String get commonPerson;

  /// No description provided for @commonPerYear.
  ///
  /// In vi, this message translates to:
  /// **'/năm'**
  String get commonPerYear;

  /// No description provided for @commonUSD.
  ///
  /// In vi, this message translates to:
  /// **'USD'**
  String get commonUSD;

  /// No description provided for @commonKm.
  ///
  /// In vi, this message translates to:
  /// **'km'**
  String get commonKm;

  /// No description provided for @commonHa.
  ///
  /// In vi, this message translates to:
  /// **'ha'**
  String get commonHa;

  /// No description provided for @commonM2.
  ///
  /// In vi, this message translates to:
  /// **'m²'**
  String get commonM2;

  /// No description provided for @commonContact.
  ///
  /// In vi, this message translates to:
  /// **'Liên hệ'**
  String get commonContact;

  /// No description provided for @commonAvailable.
  ///
  /// In vi, this message translates to:
  /// **'Có sẵn'**
  String get commonAvailable;

  /// No description provided for @commonNotAvailable.
  ///
  /// In vi, this message translates to:
  /// **'Không có'**
  String get commonNotAvailable;

  /// No description provided for @compareMaxZones.
  ///
  /// In vi, this message translates to:
  /// **'Tối đa 3 khu để so sánh'**
  String get compareMaxZones;

  /// No description provided for @compareRemovedMessage.
  ///
  /// In vi, this message translates to:
  /// **'Đã bỏ khỏi danh sách so sánh'**
  String get compareRemovedMessage;

  /// No description provided for @compareAddedMessage.
  ///
  /// In vi, this message translates to:
  /// **'Đã thêm vào so sánh'**
  String get compareAddedMessage;

  /// No description provided for @compareViewAction.
  ///
  /// In vi, this message translates to:
  /// **'Xem so sánh'**
  String get compareViewAction;

  /// No description provided for @compareRemoveTooltip.
  ///
  /// In vi, this message translates to:
  /// **'Bỏ so sánh'**
  String get compareRemoveTooltip;

  /// No description provided for @compareAddTooltip.
  ///
  /// In vi, this message translates to:
  /// **'Thêm so sánh'**
  String get compareAddTooltip;

  /// No description provided for @compareTitle.
  ///
  /// In vi, this message translates to:
  /// **'So sánh {count} KCN'**
  String compareTitle(int count);

  /// No description provided for @compareClearAll.
  ///
  /// In vi, this message translates to:
  /// **'Xóa tất cả'**
  String get compareClearAll;

  /// No description provided for @compareSaveResult.
  ///
  /// In vi, this message translates to:
  /// **'Lưu kết quả so sánh'**
  String get compareSaveResult;

  /// No description provided for @compareEmptyTitle.
  ///
  /// In vi, this message translates to:
  /// **'Chưa có KCN để so sánh'**
  String get compareEmptyTitle;

  /// No description provided for @compareEmptySubtitle.
  ///
  /// In vi, this message translates to:
  /// **'Thêm KCN vào danh sách so sánh từ kết quả tìm kiếm'**
  String get compareEmptySubtitle;

  /// No description provided for @compareBackToSearch.
  ///
  /// In vi, this message translates to:
  /// **'Quay lại tìm kiếm'**
  String get compareBackToSearch;

  /// No description provided for @compareSavedSuccess.
  ///
  /// In vi, this message translates to:
  /// **'Đã lưu kết quả thành công!'**
  String get compareSavedSuccess;

  /// No description provided for @compareSavedError.
  ///
  /// In vi, this message translates to:
  /// **'Không thể lưu. Vui lòng thử lại.'**
  String get compareSavedError;

  /// No description provided for @compareLoginRequired.
  ///
  /// In vi, this message translates to:
  /// **'Vui lòng đăng nhập để lưu kết quả'**
  String get compareLoginRequired;

  /// No description provided for @compareCriteria.
  ///
  /// In vi, this message translates to:
  /// **'Tiêu chí'**
  String get compareCriteria;

  /// No description provided for @compareProvinceRow.
  ///
  /// In vi, this message translates to:
  /// **'Tỉnh'**
  String get compareProvinceRow;

  /// No description provided for @compareRegionRow.
  ///
  /// In vi, this message translates to:
  /// **'Vùng'**
  String get compareRegionRow;

  /// No description provided for @compareInfraScoreRow.
  ///
  /// In vi, this message translates to:
  /// **'Điểm hạ tầng'**
  String get compareInfraScoreRow;

  /// No description provided for @compareLaborScoreRow.
  ///
  /// In vi, this message translates to:
  /// **'Điểm lao động'**
  String get compareLaborScoreRow;

  /// No description provided for @compareLogisticsScoreRow.
  ///
  /// In vi, this message translates to:
  /// **'Điểm logistics'**
  String get compareLogisticsScoreRow;

  /// No description provided for @comparePriceRow.
  ///
  /// In vi, this message translates to:
  /// **'Giá thuê (USD/m²/năm)'**
  String get comparePriceRow;

  /// No description provided for @compareAreaRow.
  ///
  /// In vi, this message translates to:
  /// **'Diện tích trống (ha)'**
  String get compareAreaRow;

  /// No description provided for @compareOccupancyRow.
  ///
  /// In vi, this message translates to:
  /// **'Tỷ lệ lấp đầy (%)'**
  String get compareOccupancyRow;

  /// No description provided for @compareTaxRow.
  ///
  /// In vi, this message translates to:
  /// **'Ưu đãi thuế (năm)'**
  String get compareTaxRow;

  /// No description provided for @compareSeaportRow.
  ///
  /// In vi, this message translates to:
  /// **'Đến cảng biển (km)'**
  String get compareSeaportRow;

  /// No description provided for @compareAirportRow.
  ///
  /// In vi, this message translates to:
  /// **'Đến sân bay (km)'**
  String get compareAirportRow;

  /// No description provided for @compareDeveloperRow.
  ///
  /// In vi, this message translates to:
  /// **'Chủ đầu tư'**
  String get compareDeveloperRow;

  /// No description provided for @zoneDetailTitle.
  ///
  /// In vi, this message translates to:
  /// **'Chi tiết KCN'**
  String get zoneDetailTitle;

  /// No description provided for @zoneEstablishedYear.
  ///
  /// In vi, this message translates to:
  /// **'Thành lập {year}'**
  String zoneEstablishedYear(int year);

  /// No description provided for @contactLeadSuccess.
  ///
  /// In vi, this message translates to:
  /// **'Yêu cầu tư vấn đã được ghi nhận!'**
  String get contactLeadSuccess;

  /// No description provided for @contactLeadError.
  ///
  /// In vi, this message translates to:
  /// **'Không thể gửi yêu cầu. Vui lòng thử lại.'**
  String get contactLeadError;

  /// No description provided for @tabOverview.
  ///
  /// In vi, this message translates to:
  /// **'Tổng quan'**
  String get tabOverview;

  /// No description provided for @tabInfraUtilities.
  ///
  /// In vi, this message translates to:
  /// **'Hạ tầng & Tiện ích'**
  String get tabInfraUtilities;

  /// No description provided for @tabLocationLogistics.
  ///
  /// In vi, this message translates to:
  /// **'Vị trí & Logistics'**
  String get tabLocationLogistics;

  /// No description provided for @zoneGeneralInfo.
  ///
  /// In vi, this message translates to:
  /// **'Thông tin chung'**
  String get zoneGeneralInfo;

  /// No description provided for @zonePriceIncentives.
  ///
  /// In vi, this message translates to:
  /// **'Giá & Ưu đãi'**
  String get zonePriceIncentives;

  /// No description provided for @zoneProvinceLabel.
  ///
  /// In vi, this message translates to:
  /// **'Tỉnh/Thành phố'**
  String get zoneProvinceLabel;

  /// No description provided for @zoneRegionLabel.
  ///
  /// In vi, this message translates to:
  /// **'Vùng'**
  String get zoneRegionLabel;

  /// No description provided for @zoneDeveloperLabel.
  ///
  /// In vi, this message translates to:
  /// **'Chủ đầu tư'**
  String get zoneDeveloperLabel;

  /// No description provided for @zoneDeveloperNationalityLabel.
  ///
  /// In vi, this message translates to:
  /// **'Quốc tịch CĐT'**
  String get zoneDeveloperNationalityLabel;

  /// No description provided for @zoneTotalAreaLabel.
  ///
  /// In vi, this message translates to:
  /// **'Tổng diện tích'**
  String get zoneTotalAreaLabel;

  /// No description provided for @zoneAvailableAreaLabel.
  ///
  /// In vi, this message translates to:
  /// **'Diện tích còn trống'**
  String get zoneAvailableAreaLabel;

  /// No description provided for @zoneOccupancyLabel.
  ///
  /// In vi, this message translates to:
  /// **'Tỷ lệ lấp đầy'**
  String get zoneOccupancyLabel;

  /// No description provided for @zoneMinLeaseAreaLabel.
  ///
  /// In vi, this message translates to:
  /// **'Diện tích thuê tối thiểu'**
  String get zoneMinLeaseAreaLabel;

  /// No description provided for @zoneLeasePriceLabel.
  ///
  /// In vi, this message translates to:
  /// **'Giá thuê đất'**
  String get zoneLeasePriceLabel;

  /// No description provided for @zoneServiceFeeLabel.
  ///
  /// In vi, this message translates to:
  /// **'Phí dịch vụ'**
  String get zoneServiceFeeLabel;

  /// No description provided for @zoneTaxIncentiveLabel.
  ///
  /// In vi, this message translates to:
  /// **'Ưu đãi thuế'**
  String get zoneTaxIncentiveLabel;

  /// No description provided for @zoneTaxRateLabel.
  ///
  /// In vi, this message translates to:
  /// **'Thuế suất ưu đãi'**
  String get zoneTaxRateLabel;

  /// No description provided for @zoneContactSection.
  ///
  /// In vi, this message translates to:
  /// **'Liên hệ'**
  String get zoneContactSection;

  /// No description provided for @zoneEmailLabel.
  ///
  /// In vi, this message translates to:
  /// **'Email'**
  String get zoneEmailLabel;

  /// No description provided for @zoneWebsiteLabel.
  ///
  /// In vi, this message translates to:
  /// **'Website'**
  String get zoneWebsiteLabel;

  /// No description provided for @zoneScoresTitle.
  ///
  /// In vi, this message translates to:
  /// **'Điểm đánh giá'**
  String get zoneScoresTitle;

  /// No description provided for @zoneInfraDesc.
  ///
  /// In vi, this message translates to:
  /// **'Đường sá, điện nước, viễn thông'**
  String get zoneInfraDesc;

  /// No description provided for @zoneLaborDesc.
  ///
  /// In vi, this message translates to:
  /// **'Nguồn lao động, tay nghề khu vực'**
  String get zoneLaborDesc;

  /// No description provided for @zoneLogisticsDesc.
  ///
  /// In vi, this message translates to:
  /// **'Cảng biển, sân bay, giao thông'**
  String get zoneLogisticsDesc;

  /// No description provided for @zoneIndustriesTitle.
  ///
  /// In vi, this message translates to:
  /// **'Ngành công nghiệp phù hợp'**
  String get zoneIndustriesTitle;

  /// No description provided for @zoneCertificationsTitle.
  ///
  /// In vi, this message translates to:
  /// **'Chứng nhận'**
  String get zoneCertificationsTitle;

  /// No description provided for @zoneDistancesTitle.
  ///
  /// In vi, this message translates to:
  /// **'Khoảng cách vận chuyển'**
  String get zoneDistancesTitle;

  /// No description provided for @zoneSeaportDistLabel.
  ///
  /// In vi, this message translates to:
  /// **'Đến cảng biển gần nhất'**
  String get zoneSeaportDistLabel;

  /// No description provided for @zoneAirportDistLabel.
  ///
  /// In vi, this message translates to:
  /// **'Đến sân bay gần nhất'**
  String get zoneAirportDistLabel;

  /// No description provided for @zoneHanoiLabel.
  ///
  /// In vi, this message translates to:
  /// **'Đến Hà Nội'**
  String get zoneHanoiLabel;

  /// No description provided for @zoneHcmLabel.
  ///
  /// In vi, this message translates to:
  /// **'Đến TP.HCM'**
  String get zoneHcmLabel;

  /// No description provided for @zoneMapComingSoon.
  ///
  /// In vi, this message translates to:
  /// **'Bản đồ sẽ được cập nhật'**
  String get zoneMapComingSoon;

  /// No description provided for @zoneLogisticsTitle.
  ///
  /// In vi, this message translates to:
  /// **'Đánh giá Logistics'**
  String get zoneLogisticsTitle;

  /// No description provided for @zoneSeaportConnection.
  ///
  /// In vi, this message translates to:
  /// **'Kết nối cảng biển'**
  String get zoneSeaportConnection;

  /// No description provided for @zoneAirportConnection.
  ///
  /// In vi, this message translates to:
  /// **'Kết nối sân bay'**
  String get zoneAirportConnection;

  /// No description provided for @zoneLogisticsOverall.
  ///
  /// In vi, this message translates to:
  /// **'Điểm Logistics tổng thể'**
  String get zoneLogisticsOverall;

  /// No description provided for @zoneNoInfo.
  ///
  /// In vi, this message translates to:
  /// **'Không có thông tin'**
  String get zoneNoInfo;

  /// No description provided for @zoneLogisticsOverallDesc.
  ///
  /// In vi, this message translates to:
  /// **'Dựa trên đánh giá tổng hợp'**
  String get zoneLogisticsOverallDesc;

  /// No description provided for @zoneSeaportKmDesc.
  ///
  /// In vi, this message translates to:
  /// **'{distance} km đến cảng gần nhất'**
  String zoneSeaportKmDesc(String distance);

  /// No description provided for @zoneAirportKmDesc.
  ///
  /// In vi, this message translates to:
  /// **'{distance} km đến sân bay'**
  String zoneAirportKmDesc(String distance);

  /// No description provided for @zoneUtilitiesTitle.
  ///
  /// In vi, this message translates to:
  /// **'Tiện ích'**
  String get zoneUtilitiesTitle;

  /// No description provided for @zoneUtilitiesPower.
  ///
  /// In vi, this message translates to:
  /// **'Điện'**
  String get zoneUtilitiesPower;

  /// No description provided for @zoneUtilitiesWater.
  ///
  /// In vi, this message translates to:
  /// **'Nước sạch'**
  String get zoneUtilitiesWater;

  /// No description provided for @zoneUtilitiesWastewater.
  ///
  /// In vi, this message translates to:
  /// **'Xử lý nước thải'**
  String get zoneUtilitiesWastewater;

  /// No description provided for @zoneUtilitiesFiber.
  ///
  /// In vi, this message translates to:
  /// **'Internet cáp quang'**
  String get zoneUtilitiesFiber;

  /// No description provided for @leaseTrackerRegion.
  ///
  /// In vi, this message translates to:
  /// **'Khu vực'**
  String get leaseTrackerRegion;

  /// No description provided for @leaseTrackerAssetType.
  ///
  /// In vi, this message translates to:
  /// **'Loại tài sản'**
  String get leaseTrackerAssetType;

  /// No description provided for @leaseTrackerCreateFirstAlert.
  ///
  /// In vi, this message translates to:
  /// **'Tạo Alert đầu tiên'**
  String get leaseTrackerCreateFirstAlert;

  /// No description provided for @leaseTrackerAlertZoneName.
  ///
  /// In vi, this message translates to:
  /// **'Tên KCN (tùy chọn)'**
  String get leaseTrackerAlertZoneName;

  /// No description provided for @leaseTrackerAlertZoneHint.
  ///
  /// In vi, this message translates to:
  /// **'Ví dụ: VSIP Bac Ninh'**
  String get leaseTrackerAlertZoneHint;

  /// No description provided for @leaseTrackerAlertThreshold.
  ///
  /// In vi, this message translates to:
  /// **'Giá ngưỡng (USD/m²/năm)'**
  String get leaseTrackerAlertThreshold;

  /// No description provided for @leaseTrackerAlertDirection.
  ///
  /// In vi, this message translates to:
  /// **'Kích hoạt khi'**
  String get leaseTrackerAlertDirection;

  /// No description provided for @leaseTrackerAlertCreate.
  ///
  /// In vi, this message translates to:
  /// **'Tạo Price Alert'**
  String get leaseTrackerAlertCreate;

  /// No description provided for @leaseTrackerAlertSave.
  ///
  /// In vi, this message translates to:
  /// **'Tạo Alert'**
  String get leaseTrackerAlertSave;

  /// No description provided for @leaseTrackerAlertInvalidThreshold.
  ///
  /// In vi, this message translates to:
  /// **'Vui lòng nhập giá ngưỡng hợp lệ'**
  String get leaseTrackerAlertInvalidThreshold;

  /// No description provided for @leaseTrackerAlertError.
  ///
  /// In vi, this message translates to:
  /// **'Không thể tạo alert. Vui lòng thử lại.'**
  String get leaseTrackerAlertError;

  /// No description provided for @leaseTrackerFreeLimitTitle.
  ///
  /// In vi, this message translates to:
  /// **'Giới hạn Free'**
  String get leaseTrackerFreeLimitTitle;

  /// No description provided for @leaseTrackerFreeLimitContent.
  ///
  /// In vi, this message translates to:
  /// **'Tài khoản miễn phí chỉ được tạo tối đa 2 price alerts.\nNâng cấp Pro để tạo không giới hạn.'**
  String get leaseTrackerFreeLimitContent;

  /// No description provided for @leaseTrackerLoginPromptTitle.
  ///
  /// In vi, this message translates to:
  /// **'Đăng nhập để tạo Price Alerts'**
  String get leaseTrackerLoginPromptTitle;

  /// No description provided for @leaseTrackerLoginPromptSub.
  ///
  /// In vi, this message translates to:
  /// **'Nhận thông báo khi giá thuê KCN thay đổi theo tiêu chí bạn quan tâm.'**
  String get leaseTrackerLoginPromptSub;

  /// No description provided for @leaseTrackerNoAlertsTitle.
  ///
  /// In vi, this message translates to:
  /// **'Chưa có alert nào'**
  String get leaseTrackerNoAlertsTitle;

  /// No description provided for @leaseTrackerNoAlertsSub.
  ///
  /// In vi, this message translates to:
  /// **'Tạo alert đầu tiên để nhận thông báo khi giá thay đổi.'**
  String get leaseTrackerNoAlertsSub;

  /// No description provided for @leaseTrackerKcnCount.
  ///
  /// In vi, this message translates to:
  /// **'{count} KCN'**
  String leaseTrackerKcnCount(int count);

  /// No description provided for @leaseTrackerStable.
  ///
  /// In vi, this message translates to:
  /// **'Ổn định'**
  String get leaseTrackerStable;

  /// No description provided for @leaseTrackerMin.
  ///
  /// In vi, this message translates to:
  /// **'Min'**
  String get leaseTrackerMin;

  /// No description provided for @leaseTrackerMax.
  ///
  /// In vi, this message translates to:
  /// **'Max'**
  String get leaseTrackerMax;

  /// No description provided for @insightPremiumContent.
  ///
  /// In vi, this message translates to:
  /// **'Nội dung Premium'**
  String get insightPremiumContent;

  /// No description provided for @insightPremiumUpgradePrompt.
  ///
  /// In vi, this message translates to:
  /// **'Nâng cấp để đọc báo cáo đầy đủ'**
  String get insightPremiumUpgradePrompt;

  /// No description provided for @insightUpgradePro.
  ///
  /// In vi, this message translates to:
  /// **'Nâng cấp Pro'**
  String get insightUpgradePro;

  /// No description provided for @insightCollapse.
  ///
  /// In vi, this message translates to:
  /// **'Thu gọn ▲'**
  String get insightCollapse;

  /// No description provided for @insightExpand.
  ///
  /// In vi, this message translates to:
  /// **'Xem thêm ▼'**
  String get insightExpand;

  /// No description provided for @alertDeleteTitle.
  ///
  /// In vi, this message translates to:
  /// **'Xóa Alert'**
  String get alertDeleteTitle;

  /// No description provided for @alertDeleteContent.
  ///
  /// In vi, this message translates to:
  /// **'Bạn có muốn xóa alert giá này không?'**
  String get alertDeleteContent;

  /// No description provided for @alertLastTriggered.
  ///
  /// In vi, this message translates to:
  /// **'Kích hoạt lần cuối: {date}'**
  String alertLastTriggered(String date);

  /// No description provided for @tableHeaderZone.
  ///
  /// In vi, this message translates to:
  /// **'KCN'**
  String get tableHeaderZone;

  /// No description provided for @tableHeaderPrice.
  ///
  /// In vi, this message translates to:
  /// **'Giá (USD)'**
  String get tableHeaderPrice;

  /// No description provided for @tableHeaderChange.
  ///
  /// In vi, this message translates to:
  /// **'Thay đổi'**
  String get tableHeaderChange;

  /// No description provided for @tableHeaderSource.
  ///
  /// In vi, this message translates to:
  /// **'Nguồn'**
  String get tableHeaderSource;

  /// No description provided for @permitDeleteTitle.
  ///
  /// In vi, this message translates to:
  /// **'Xóa checklist'**
  String get permitDeleteTitle;

  /// No description provided for @permitDeleteContent.
  ///
  /// In vi, this message translates to:
  /// **'Checklist này sẽ bị lưu trữ và không hiển thị nữa. Bạn có chắc không?'**
  String get permitDeleteContent;

  /// No description provided for @permitFreeTierLimit.
  ///
  /// In vi, this message translates to:
  /// **'Gói miễn phí chỉ hỗ trợ 1 checklist. Nâng cấp Pro để tạo không giới hạn.'**
  String get permitFreeTierLimit;

  /// No description provided for @permitUpgradePrompt.
  ///
  /// In vi, this message translates to:
  /// **'Nâng cấp Pro để sử dụng tính năng này'**
  String get permitUpgradePrompt;

  /// No description provided for @permitProjectNameLabel.
  ///
  /// In vi, this message translates to:
  /// **'Tên dự án *'**
  String get permitProjectNameLabel;

  /// No description provided for @permitProjectNameHint.
  ///
  /// In vi, this message translates to:
  /// **'VD: Nhà máy Samsung Bắc Ninh'**
  String get permitProjectNameHint;

  /// No description provided for @permitProjectNameValidation.
  ///
  /// In vi, this message translates to:
  /// **'Vui lòng nhập tên dự án'**
  String get permitProjectNameValidation;

  /// No description provided for @permitCompanyNameHint.
  ///
  /// In vi, this message translates to:
  /// **'VD: Samsung Electronics Vietnam'**
  String get permitCompanyNameHint;

  /// No description provided for @permitProvinceHint.
  ///
  /// In vi, this message translates to:
  /// **'VD: Bắc Ninh'**
  String get permitProvinceHint;

  /// No description provided for @permitDayEstimate.
  ///
  /// In vi, this message translates to:
  /// **'~{days} ngày'**
  String permitDayEstimate(int days);

  /// No description provided for @permitStepCount.
  ///
  /// In vi, this message translates to:
  /// **'{count} bước'**
  String permitStepCount(int count);

  /// No description provided for @permitStepDetail.
  ///
  /// In vi, this message translates to:
  /// **'~{days} ngày · {steps} bước thủ tục'**
  String permitStepDetail(int days, int steps);

  /// No description provided for @permitCompletedCongrats.
  ///
  /// In vi, this message translates to:
  /// **'Chúc mừng! Bạn đã hoàn thành tất cả thủ tục bắt buộc.'**
  String get permitCompletedCongrats;

  /// No description provided for @permitUpgradePdf.
  ///
  /// In vi, this message translates to:
  /// **'Nâng cấp Pro để xuất PDF'**
  String get permitUpgradePdf;

  /// No description provided for @permitStepsCompleted.
  ///
  /// In vi, this message translates to:
  /// **'{done} / {total} bước hoàn thành'**
  String permitStepsCompleted(int done, int total);

  /// No description provided for @permitInProgressCount.
  ///
  /// In vi, this message translates to:
  /// **'{count} đang làm'**
  String permitInProgressCount(int count);

  /// No description provided for @permitSkippedCount.
  ///
  /// In vi, this message translates to:
  /// **'{count} bỏ qua'**
  String permitSkippedCount(int count);

  /// No description provided for @permitItemNotRequired.
  ///
  /// In vi, this message translates to:
  /// **'Không bắt buộc'**
  String get permitItemNotRequired;

  /// No description provided for @itemStatusPending.
  ///
  /// In vi, this message translates to:
  /// **'Chưa làm'**
  String get itemStatusPending;

  /// No description provided for @itemStatusInProgress.
  ///
  /// In vi, this message translates to:
  /// **'Đang làm'**
  String get itemStatusInProgress;

  /// No description provided for @itemStatusDone.
  ///
  /// In vi, this message translates to:
  /// **'Xong'**
  String get itemStatusDone;

  /// No description provided for @itemStatusSkipped.
  ///
  /// In vi, this message translates to:
  /// **'Bỏ qua'**
  String get itemStatusSkipped;
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
