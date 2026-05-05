// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Vietnamese (`vi`).
class AppLocalizationsVi extends AppLocalizations {
  AppLocalizationsVi([String locale = 'vi']) : super(locale);

  @override
  String get appName => 'OneIP';

  @override
  String get appTagline => 'Nền tảng thông minh cho KCN Việt Nam';

  @override
  String get navSiteSelection => 'Chọn địa điểm';

  @override
  String get navLeaseTracker => 'Giá thuê';

  @override
  String get navPermitChecklist => 'Giấy phép';

  @override
  String get navProfile => 'Hồ sơ';

  @override
  String get authLogin => 'Đăng nhập';

  @override
  String get authRegister => 'Đăng ký';

  @override
  String get authEmail => 'Email';

  @override
  String get authPassword => 'Mật khẩu';

  @override
  String get authConfirmPassword => 'Xác nhận mật khẩu';

  @override
  String get authForgotPassword => 'Quên mật khẩu?';

  @override
  String get authLoginSubtitle => 'Đăng nhập để tiếp tục';

  @override
  String get authNoAccount => 'Chưa có tài khoản?';

  @override
  String get authHaveAccount => 'Đã có tài khoản?';

  @override
  String get authContinueGoogle => 'Tiếp tục với Google';

  @override
  String get authOr => 'hoặc';

  @override
  String get authFullName => 'Họ và tên';

  @override
  String get authCompany => 'Tên công ty';

  @override
  String get authRole => 'Vai trò';

  @override
  String get authRoleInvestor => 'Nhà đầu tư FDI';

  @override
  String get authRoleBroker => 'Môi giới BĐS';

  @override
  String get authRoleTenant => 'Chủ thuê KCN';

  @override
  String get authRoleDeveloper => 'Developer KCN';

  @override
  String get authRoleOther => 'Khác';

  @override
  String get authSendResetLink => 'Gửi link đặt lại mật khẩu';

  @override
  String get authLogout => 'Đăng xuất';

  @override
  String get siteSelectionTitle => 'Tìm Khu Công Nghiệp';

  @override
  String get siteSelectionSubtitle => 'Chọn địa điểm FDI lý tưởng';

  @override
  String get siteSelectionIndustry => 'Ngành công nghiệp';

  @override
  String get siteSelectionArea => 'Diện tích cần thuê';

  @override
  String get siteSelectionHeadcount => 'Số lượng nhân sự';

  @override
  String get siteSelectionRegion => 'Khu vực ưu tiên';

  @override
  String get siteSelectionPriority => 'Yếu tố ưu tiên';

  @override
  String get siteSelectionBudget => 'Ngân sách tối đa (tùy chọn)';

  @override
  String get siteSelectionSearch => 'Tìm kiếm';

  @override
  String get siteSelectionSearchAgain => 'Tìm kiếm lại';

  @override
  String siteSelectionResults(int count) {
    return 'Tìm thấy $count khu công nghiệp phù hợp';
  }

  @override
  String get siteSelectionNoResults =>
      'Không tìm thấy KCN phù hợp. Hãy điều chỉnh tiêu chí tìm kiếm.';

  @override
  String get siteSelectionViewDetail => 'Xem chi tiết';

  @override
  String get siteSelectionCompare => 'So sánh';

  @override
  String get siteSelectionContact => 'Liên hệ tư vấn';

  @override
  String get siteSelectionSave => 'Lưu kết quả';

  @override
  String get regionAll => 'Tất cả';

  @override
  String get regionNorth => 'Miền Bắc';

  @override
  String get regionCentral => 'Miền Trung';

  @override
  String get regionSouth => 'Miền Nam';

  @override
  String get industryElectronics => 'Điện tử';

  @override
  String get industryAutoParts => 'Linh kiện ô tô';

  @override
  String get industryGarment => 'May mặc & Giày dép';

  @override
  String get industryFoodProcessing => 'Chế biến thực phẩm';

  @override
  String get industryHeavy => 'Công nghiệp nặng';

  @override
  String get industryLogistics => 'Logistics';

  @override
  String get industryPetrochemical => 'Hóa dầu';

  @override
  String get industryHighTech => 'Công nghệ cao';

  @override
  String get industryManufacturing => 'Sản xuất';

  @override
  String get industryOther => 'Khác';

  @override
  String get priorityInfra => 'Hạ tầng';

  @override
  String get priorityLabor => 'Lao động';

  @override
  String get priorityLogistics => 'Logistics';

  @override
  String get priorityPrice => 'Giá thuê';

  @override
  String get priorityTax => 'Ưu đãi thuế';

  @override
  String get zoneLeasePrice => 'Giá thuê';

  @override
  String get zoneAvailableArea => 'Diện tích trống';

  @override
  String get zoneSeaport => 'Cảng biển';

  @override
  String get zoneAirport => 'Sân bay';

  @override
  String get zoneOccupancy => 'Tỷ lệ lấp đầy';

  @override
  String zoneTaxIncentive(int years) {
    return 'Ưu đãi thuế $years năm';
  }

  @override
  String get zoneOverallScore => 'Điểm tổng hợp';

  @override
  String get zoneInfraScore => 'Hạ tầng';

  @override
  String get zoneLaborScore => 'Lao động';

  @override
  String get zoneLogisticsScore => 'Logistics';

  @override
  String get leaseTrackerTitle => 'Theo dõi giá thuê KCN';

  @override
  String get leaseTrackerMarket => 'Thị Trường';

  @override
  String get leaseTrackerAlerts => 'Price Alerts';

  @override
  String get leaseTrackerMarketOverview => 'Tổng quan thị trường';

  @override
  String get leaseTrackerChart => 'Biểu đồ giá theo thời gian';

  @override
  String get leaseTrackerTable => 'Bảng giá hiện tại';

  @override
  String get leaseTrackerNews => 'Tin tức thị trường';

  @override
  String get leaseTrackerAvgPrice => 'Giá trung bình';

  @override
  String get leaseTrackerNoAlerts => 'Chưa có alert nào. Tạo alert đầu tiên!';

  @override
  String get leaseTrackerCreateAlert => 'Tạo Alert';

  @override
  String get leaseTrackerFreeDelay =>
      'Dữ liệu miễn phí có độ trễ 30 ngày. Nâng cấp Pro để nhận số liệu thời gian thực.';

  @override
  String get leaseTrackerUpgrade => 'Nâng cấp';

  @override
  String get leaseTrackerPriceAbove => 'Khi giá vượt';

  @override
  String get leaseTrackerPriceBelow => 'Khi giá xuống dưới';

  @override
  String get assetFactory => 'Nhà xưởng';

  @override
  String get assetWarehouse => 'Kho bãi';

  @override
  String get assetLand => 'Đất KCN';

  @override
  String get assetOffice => 'Văn phòng';

  @override
  String get permitTitle => 'Quản lý Giấy phép KCN';

  @override
  String get permitCreateNew => 'Tạo checklist mới';

  @override
  String get permitChooseType => 'Chọn loại thủ tục';

  @override
  String get permitNoChecklist => 'Chưa có checklist nào';

  @override
  String get permitNoChecklistSub =>
      'Tạo checklist thủ tục để theo dõi tiến độ xin giấy phép KCN của bạn.';

  @override
  String get permitCreateChecklist => 'Tạo Checklist';

  @override
  String get permitProjectName => 'Tên dự án';

  @override
  String get permitCompanyName => 'Tên công ty';

  @override
  String get permitProvince => 'Tỉnh/thành phố';

  @override
  String get permitInvestment => 'Vốn đầu tư dự kiến (USD)';

  @override
  String get permitProgress => 'Tiến độ';

  @override
  String permitTotalSteps(int count) {
    return 'Tổng $count bước';
  }

  @override
  String permitCompleted(int count) {
    return 'Hoàn thành $count';
  }

  @override
  String get permitExportPDF => 'Xuất PDF';

  @override
  String get permitShare => 'Chia sẻ';

  @override
  String get statusPending => 'Chờ xử lý';

  @override
  String get statusInProgress => 'Đang thực hiện';

  @override
  String get statusDone => 'Hoàn thành';

  @override
  String get statusSkipped => 'Bỏ qua';

  @override
  String get statusBlocked => 'Bị chặn';

  @override
  String get difficultyEasy => 'Đơn giản';

  @override
  String get difficultyMedium => 'Trung bình';

  @override
  String get difficultyComplex => 'Phức tạp';

  @override
  String get profileTitle => 'Hồ sơ';

  @override
  String get profilePlan => 'Gói hiện tại';

  @override
  String get profilePlanFree => 'Miễn phí';

  @override
  String get profilePlanPro => 'Pro';

  @override
  String get profilePlanEnterprise => 'Enterprise';

  @override
  String get profileUpgrade => 'Nâng cấp lên Pro';

  @override
  String get profileLanguage => 'Ngôn ngữ / Language';

  @override
  String get profileAccountInfo => 'Thông tin tài khoản';

  @override
  String get profileChangePassword => 'Đổi mật khẩu';

  @override
  String get profileLogout => 'Đăng xuất';

  @override
  String get planFree => 'Miễn phí';

  @override
  String get planPro => 'Pro';

  @override
  String get planEnterprise => 'Enterprise';

  @override
  String get planUpgradeTitle => 'Nâng cấp lên Pro';

  @override
  String get planUpgradeSubtitle => 'Mở khóa toàn bộ tính năng OneIP';

  @override
  String get planUpgradeButton => 'Nâng cấp ngay';

  @override
  String get commonSave => 'Lưu';

  @override
  String get commonCancel => 'Hủy';

  @override
  String get commonConfirm => 'Xác nhận';

  @override
  String get commonDelete => 'Xóa';

  @override
  String get commonEdit => 'Chỉnh sửa';

  @override
  String get commonClose => 'Đóng';

  @override
  String get commonSearch => 'Tìm kiếm';

  @override
  String get commonFilter => 'Lọc';

  @override
  String get commonSort => 'Sắp xếp';

  @override
  String get commonRetry => 'Thử lại';

  @override
  String get commonLoading => 'Đang tải...';

  @override
  String get commonError => 'Đã xảy ra lỗi';

  @override
  String get commonNoData => 'Không có dữ liệu';

  @override
  String get commonNoLimit => 'Không giới hạn';

  @override
  String get commonPerson => 'người';

  @override
  String get commonPerYear => '/năm';

  @override
  String get commonUSD => 'USD';

  @override
  String get commonKm => 'km';

  @override
  String get commonHa => 'ha';

  @override
  String get commonM2 => 'm²';

  @override
  String get commonContact => 'Liên hệ';

  @override
  String get commonAvailable => 'Có sẵn';

  @override
  String get commonNotAvailable => 'Không có';

  @override
  String get compareMaxZones => 'Tối đa 3 khu để so sánh';

  @override
  String get compareRemovedMessage => 'Đã bỏ khỏi danh sách so sánh';

  @override
  String get compareAddedMessage => 'Đã thêm vào so sánh';

  @override
  String get compareViewAction => 'Xem so sánh';

  @override
  String get compareRemoveTooltip => 'Bỏ so sánh';

  @override
  String get compareAddTooltip => 'Thêm so sánh';

  @override
  String compareTitle(int count) {
    return 'So sánh $count KCN';
  }

  @override
  String get compareClearAll => 'Xóa tất cả';

  @override
  String get compareSaveResult => 'Lưu kết quả so sánh';

  @override
  String get compareEmptyTitle => 'Chưa có KCN để so sánh';

  @override
  String get compareEmptySubtitle =>
      'Thêm KCN vào danh sách so sánh từ kết quả tìm kiếm';

  @override
  String get compareBackToSearch => 'Quay lại tìm kiếm';

  @override
  String get compareSavedSuccess => 'Đã lưu kết quả thành công!';

  @override
  String get compareSavedError => 'Không thể lưu. Vui lòng thử lại.';

  @override
  String get compareLoginRequired => 'Vui lòng đăng nhập để lưu kết quả';

  @override
  String get compareCriteria => 'Tiêu chí';

  @override
  String get compareProvinceRow => 'Tỉnh';

  @override
  String get compareRegionRow => 'Vùng';

  @override
  String get compareInfraScoreRow => 'Điểm hạ tầng';

  @override
  String get compareLaborScoreRow => 'Điểm lao động';

  @override
  String get compareLogisticsScoreRow => 'Điểm logistics';

  @override
  String get comparePriceRow => 'Giá thuê (USD/m²/năm)';

  @override
  String get compareAreaRow => 'Diện tích trống (ha)';

  @override
  String get compareOccupancyRow => 'Tỷ lệ lấp đầy (%)';

  @override
  String get compareTaxRow => 'Ưu đãi thuế (năm)';

  @override
  String get compareSeaportRow => 'Đến cảng biển (km)';

  @override
  String get compareAirportRow => 'Đến sân bay (km)';

  @override
  String get compareDeveloperRow => 'Chủ đầu tư';

  @override
  String get zoneDetailTitle => 'Chi tiết KCN';

  @override
  String zoneEstablishedYear(int year) {
    return 'Thành lập $year';
  }

  @override
  String get contactLeadSuccess => 'Yêu cầu tư vấn đã được ghi nhận!';

  @override
  String get contactLeadError => 'Không thể gửi yêu cầu. Vui lòng thử lại.';

  @override
  String get tabOverview => 'Tổng quan';

  @override
  String get tabInfraUtilities => 'Hạ tầng & Tiện ích';

  @override
  String get tabLocationLogistics => 'Vị trí & Logistics';

  @override
  String get zoneGeneralInfo => 'Thông tin chung';

  @override
  String get zonePriceIncentives => 'Giá & Ưu đãi';

  @override
  String get zoneProvinceLabel => 'Tỉnh/Thành phố';

  @override
  String get zoneRegionLabel => 'Vùng';

  @override
  String get zoneDeveloperLabel => 'Chủ đầu tư';

  @override
  String get zoneDeveloperNationalityLabel => 'Quốc tịch CĐT';

  @override
  String get zoneTotalAreaLabel => 'Tổng diện tích';

  @override
  String get zoneAvailableAreaLabel => 'Diện tích còn trống';

  @override
  String get zoneOccupancyLabel => 'Tỷ lệ lấp đầy';

  @override
  String get zoneMinLeaseAreaLabel => 'Diện tích thuê tối thiểu';

  @override
  String get zoneLeasePriceLabel => 'Giá thuê đất';

  @override
  String get zoneServiceFeeLabel => 'Phí dịch vụ';

  @override
  String get zoneTaxIncentiveLabel => 'Ưu đãi thuế';

  @override
  String get zoneTaxRateLabel => 'Thuế suất ưu đãi';

  @override
  String get zoneContactSection => 'Liên hệ';

  @override
  String get zoneEmailLabel => 'Email';

  @override
  String get zoneWebsiteLabel => 'Website';

  @override
  String get zoneScoresTitle => 'Điểm đánh giá';

  @override
  String get zoneInfraDesc => 'Đường sá, điện nước, viễn thông';

  @override
  String get zoneLaborDesc => 'Nguồn lao động, tay nghề khu vực';

  @override
  String get zoneLogisticsDesc => 'Cảng biển, sân bay, giao thông';

  @override
  String get zoneIndustriesTitle => 'Ngành công nghiệp phù hợp';

  @override
  String get zoneCertificationsTitle => 'Chứng nhận';

  @override
  String get zoneDistancesTitle => 'Khoảng cách vận chuyển';

  @override
  String get zoneSeaportDistLabel => 'Đến cảng biển gần nhất';

  @override
  String get zoneAirportDistLabel => 'Đến sân bay gần nhất';

  @override
  String get zoneHanoiLabel => 'Đến Hà Nội';

  @override
  String get zoneHcmLabel => 'Đến TP.HCM';

  @override
  String get zoneMapComingSoon => 'Bản đồ sẽ được cập nhật';

  @override
  String get zoneLogisticsTitle => 'Đánh giá Logistics';

  @override
  String get zoneSeaportConnection => 'Kết nối cảng biển';

  @override
  String get zoneAirportConnection => 'Kết nối sân bay';

  @override
  String get zoneLogisticsOverall => 'Điểm Logistics tổng thể';

  @override
  String get zoneNoInfo => 'Không có thông tin';

  @override
  String get zoneLogisticsOverallDesc => 'Dựa trên đánh giá tổng hợp';

  @override
  String zoneSeaportKmDesc(String distance) {
    return '$distance km đến cảng gần nhất';
  }

  @override
  String zoneAirportKmDesc(String distance) {
    return '$distance km đến sân bay';
  }

  @override
  String get zoneUtilitiesTitle => 'Tiện ích';

  @override
  String get zoneUtilitiesPower => 'Điện';

  @override
  String get zoneUtilitiesWater => 'Nước sạch';

  @override
  String get zoneUtilitiesWastewater => 'Xử lý nước thải';

  @override
  String get zoneUtilitiesFiber => 'Internet cáp quang';

  @override
  String get leaseTrackerRegion => 'Khu vực';

  @override
  String get leaseTrackerAssetType => 'Loại tài sản';

  @override
  String get leaseTrackerCreateFirstAlert => 'Tạo Alert đầu tiên';

  @override
  String get leaseTrackerAlertZoneName => 'Tên KCN (tùy chọn)';

  @override
  String get leaseTrackerAlertZoneHint => 'Ví dụ: VSIP Bac Ninh';

  @override
  String get leaseTrackerAlertThreshold => 'Giá ngưỡng (USD/m²/năm)';

  @override
  String get leaseTrackerAlertDirection => 'Kích hoạt khi';

  @override
  String get leaseTrackerAlertCreate => 'Tạo Price Alert';

  @override
  String get leaseTrackerAlertSave => 'Tạo Alert';

  @override
  String get leaseTrackerAlertInvalidThreshold =>
      'Vui lòng nhập giá ngưỡng hợp lệ';

  @override
  String get leaseTrackerAlertError => 'Không thể tạo alert. Vui lòng thử lại.';

  @override
  String get leaseTrackerFreeLimitTitle => 'Giới hạn Free';

  @override
  String get leaseTrackerFreeLimitContent =>
      'Tài khoản miễn phí chỉ được tạo tối đa 2 price alerts.\nNâng cấp Pro để tạo không giới hạn.';

  @override
  String get leaseTrackerLoginPromptTitle => 'Đăng nhập để tạo Price Alerts';

  @override
  String get leaseTrackerLoginPromptSub =>
      'Nhận thông báo khi giá thuê KCN thay đổi theo tiêu chí bạn quan tâm.';

  @override
  String get leaseTrackerNoAlertsTitle => 'Chưa có alert nào';

  @override
  String get leaseTrackerNoAlertsSub =>
      'Tạo alert đầu tiên để nhận thông báo khi giá thay đổi.';

  @override
  String leaseTrackerKcnCount(int count) {
    return '$count KCN';
  }

  @override
  String get leaseTrackerStable => 'Ổn định';

  @override
  String get leaseTrackerMin => 'Min';

  @override
  String get leaseTrackerMax => 'Max';

  @override
  String get insightPremiumContent => 'Nội dung Premium';

  @override
  String get insightPremiumUpgradePrompt => 'Nâng cấp để đọc báo cáo đầy đủ';

  @override
  String get insightUpgradePro => 'Nâng cấp Pro';

  @override
  String get insightCollapse => 'Thu gọn ▲';

  @override
  String get insightExpand => 'Xem thêm ▼';

  @override
  String get alertDeleteTitle => 'Xóa Alert';

  @override
  String get alertDeleteContent => 'Bạn có muốn xóa alert giá này không?';

  @override
  String alertLastTriggered(String date) {
    return 'Kích hoạt lần cuối: $date';
  }

  @override
  String get tableHeaderZone => 'KCN';

  @override
  String get tableHeaderPrice => 'Giá (USD)';

  @override
  String get tableHeaderChange => 'Thay đổi';

  @override
  String get tableHeaderSource => 'Nguồn';

  @override
  String get permitDeleteTitle => 'Xóa checklist';

  @override
  String get permitDeleteContent =>
      'Checklist này sẽ bị lưu trữ và không hiển thị nữa. Bạn có chắc không?';

  @override
  String get permitFreeTierLimit =>
      'Gói miễn phí chỉ hỗ trợ 1 checklist. Nâng cấp Pro để tạo không giới hạn.';

  @override
  String get permitUpgradePrompt => 'Nâng cấp Pro để sử dụng tính năng này';

  @override
  String get permitProjectNameLabel => 'Tên dự án *';

  @override
  String get permitProjectNameHint => 'VD: Nhà máy Samsung Bắc Ninh';

  @override
  String get permitProjectNameValidation => 'Vui lòng nhập tên dự án';

  @override
  String get permitCompanyNameHint => 'VD: Samsung Electronics Vietnam';

  @override
  String get permitProvinceHint => 'VD: Bắc Ninh';

  @override
  String permitDayEstimate(int days) {
    return '~$days ngày';
  }

  @override
  String permitStepCount(int count) {
    return '$count bước';
  }

  @override
  String permitStepDetail(int days, int steps) {
    return '~$days ngày · $steps bước thủ tục';
  }

  @override
  String get permitCompletedCongrats =>
      'Chúc mừng! Bạn đã hoàn thành tất cả thủ tục bắt buộc.';

  @override
  String get permitUpgradePdf => 'Nâng cấp Pro để xuất PDF';

  @override
  String permitStepsCompleted(int done, int total) {
    return '$done / $total bước hoàn thành';
  }

  @override
  String permitInProgressCount(int count) {
    return '$count đang làm';
  }

  @override
  String permitSkippedCount(int count) {
    return '$count bỏ qua';
  }

  @override
  String get permitItemNotRequired => 'Không bắt buộc';

  @override
  String get itemStatusPending => 'Chưa làm';

  @override
  String get itemStatusInProgress => 'Đang làm';

  @override
  String get itemStatusDone => 'Xong';

  @override
  String get itemStatusSkipped => 'Bỏ qua';
}
