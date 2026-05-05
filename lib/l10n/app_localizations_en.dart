// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'OneIP';

  @override
  String get appTagline =>
      'The Intelligence Layer for Vietnam Industrial Zones';

  @override
  String get navSiteSelection => 'Site Selection';

  @override
  String get navLeaseTracker => 'Lease Rates';

  @override
  String get navPermitChecklist => 'Permits';

  @override
  String get navProfile => 'Profile';

  @override
  String get authLogin => 'Sign In';

  @override
  String get authRegister => 'Sign Up';

  @override
  String get authEmail => 'Email';

  @override
  String get authPassword => 'Password';

  @override
  String get authConfirmPassword => 'Confirm Password';

  @override
  String get authForgotPassword => 'Forgot password?';

  @override
  String get authLoginSubtitle => 'Sign in to continue';

  @override
  String get authNoAccount => 'Don\'t have an account?';

  @override
  String get authHaveAccount => 'Already have an account?';

  @override
  String get authContinueGoogle => 'Continue with Google';

  @override
  String get authOr => 'or';

  @override
  String get authFullName => 'Full Name';

  @override
  String get authCompany => 'Company Name';

  @override
  String get authRole => 'Role';

  @override
  String get authRoleInvestor => 'FDI Investor';

  @override
  String get authRoleBroker => 'Real Estate Broker';

  @override
  String get authRoleTenant => 'Industrial Tenant';

  @override
  String get authRoleDeveloper => 'IZ Developer';

  @override
  String get authRoleOther => 'Other';

  @override
  String get authSendResetLink => 'Send Reset Link';

  @override
  String get authLogout => 'Sign Out';

  @override
  String get siteSelectionTitle => 'Find Industrial Zone';

  @override
  String get siteSelectionSubtitle => 'Select your ideal FDI location';

  @override
  String get siteSelectionIndustry => 'Industry';

  @override
  String get siteSelectionArea => 'Required Area';

  @override
  String get siteSelectionHeadcount => 'Headcount';

  @override
  String get siteSelectionRegion => 'Preferred Region';

  @override
  String get siteSelectionPriority => 'Priority Factors';

  @override
  String get siteSelectionBudget => 'Max Budget (optional)';

  @override
  String get siteSelectionSearch => 'Search';

  @override
  String get siteSelectionSearchAgain => 'Search Again';

  @override
  String siteSelectionResults(int count) {
    return 'Found $count matching industrial zones';
  }

  @override
  String get siteSelectionNoResults =>
      'No matching zones found. Try adjusting your criteria.';

  @override
  String get siteSelectionViewDetail => 'View Detail';

  @override
  String get siteSelectionCompare => 'Compare';

  @override
  String get siteSelectionContact => 'Contact Advisor';

  @override
  String get siteSelectionSave => 'Save Results';

  @override
  String get regionAll => 'All';

  @override
  String get regionNorth => 'North';

  @override
  String get regionCentral => 'Central';

  @override
  String get regionSouth => 'South';

  @override
  String get industryElectronics => 'Electronics';

  @override
  String get industryAutoParts => 'Auto Parts';

  @override
  String get industryGarment => 'Garment & Footwear';

  @override
  String get industryFoodProcessing => 'Food Processing';

  @override
  String get industryHeavy => 'Heavy Industry';

  @override
  String get industryLogistics => 'Logistics';

  @override
  String get industryPetrochemical => 'Petrochemical';

  @override
  String get industryHighTech => 'High-Tech';

  @override
  String get industryManufacturing => 'Manufacturing';

  @override
  String get industryOther => 'Other';

  @override
  String get priorityInfra => 'Infrastructure';

  @override
  String get priorityLabor => 'Labor';

  @override
  String get priorityLogistics => 'Logistics';

  @override
  String get priorityPrice => 'Lease Price';

  @override
  String get priorityTax => 'Tax Incentives';

  @override
  String get zoneLeasePrice => 'Lease Price';

  @override
  String get zoneAvailableArea => 'Available Area';

  @override
  String get zoneSeaport => 'Seaport';

  @override
  String get zoneAirport => 'Airport';

  @override
  String get zoneOccupancy => 'Occupancy Rate';

  @override
  String zoneTaxIncentive(int years) {
    return '$years-year tax incentive';
  }

  @override
  String get zoneOverallScore => 'Overall Score';

  @override
  String get zoneInfraScore => 'Infrastructure';

  @override
  String get zoneLaborScore => 'Labor';

  @override
  String get zoneLogisticsScore => 'Logistics';

  @override
  String get leaseTrackerTitle => 'IZ Lease Rate Tracker';

  @override
  String get leaseTrackerMarket => 'Market';

  @override
  String get leaseTrackerAlerts => 'Price Alerts';

  @override
  String get leaseTrackerMarketOverview => 'Market Overview';

  @override
  String get leaseTrackerChart => 'Price Trend Chart';

  @override
  String get leaseTrackerTable => 'Current Rate Table';

  @override
  String get leaseTrackerNews => 'Market Insights';

  @override
  String get leaseTrackerAvgPrice => 'Average Price';

  @override
  String get leaseTrackerNoAlerts => 'No alerts yet. Create your first alert!';

  @override
  String get leaseTrackerCreateAlert => 'Create Alert';

  @override
  String get leaseTrackerFreeDelay =>
      'Free data has 30-day delay. Upgrade to Pro for real-time data.';

  @override
  String get leaseTrackerUpgrade => 'Upgrade';

  @override
  String get leaseTrackerPriceAbove => 'When price exceeds';

  @override
  String get leaseTrackerPriceBelow => 'When price drops below';

  @override
  String get assetFactory => 'Factory';

  @override
  String get assetWarehouse => 'Warehouse';

  @override
  String get assetLand => 'IZ Land';

  @override
  String get assetOffice => 'Office';

  @override
  String get permitTitle => 'KCN Permit Manager';

  @override
  String get permitCreateNew => 'Create New Checklist';

  @override
  String get permitChooseType => 'Choose Procedure Type';

  @override
  String get permitNoChecklist => 'No checklists yet';

  @override
  String get permitNoChecklistSub =>
      'Create a permit checklist to track your KCN licensing progress.';

  @override
  String get permitCreateChecklist => 'Create Checklist';

  @override
  String get permitProjectName => 'Project Name';

  @override
  String get permitCompanyName => 'Company Name';

  @override
  String get permitProvince => 'Province / City';

  @override
  String get permitInvestment => 'Estimated Investment (USD)';

  @override
  String get permitProgress => 'Progress';

  @override
  String permitTotalSteps(int count) {
    return '$count total steps';
  }

  @override
  String permitCompleted(int count) {
    return '$count completed';
  }

  @override
  String get permitExportPDF => 'Export PDF';

  @override
  String get permitShare => 'Share';

  @override
  String get statusPending => 'Pending';

  @override
  String get statusInProgress => 'In Progress';

  @override
  String get statusDone => 'Completed';

  @override
  String get statusSkipped => 'Skipped';

  @override
  String get statusBlocked => 'Blocked';

  @override
  String get difficultyEasy => 'Simple';

  @override
  String get difficultyMedium => 'Medium';

  @override
  String get difficultyComplex => 'Complex';

  @override
  String get profileTitle => 'Profile';

  @override
  String get profilePlan => 'Current Plan';

  @override
  String get profilePlanFree => 'Free';

  @override
  String get profilePlanPro => 'Pro';

  @override
  String get profilePlanEnterprise => 'Enterprise';

  @override
  String get profileUpgrade => 'Upgrade to Pro';

  @override
  String get profileLanguage => 'Ngôn ngữ / Language';

  @override
  String get profileAccountInfo => 'Account Info';

  @override
  String get profileChangePassword => 'Change Password';

  @override
  String get profileLogout => 'Sign Out';

  @override
  String get planFree => 'Free';

  @override
  String get planPro => 'Pro';

  @override
  String get planEnterprise => 'Enterprise';

  @override
  String get planUpgradeTitle => 'Upgrade to Pro';

  @override
  String get planUpgradeSubtitle => 'Unlock all OneIP features';

  @override
  String get planUpgradeButton => 'Upgrade Now';

  @override
  String get commonSave => 'Save';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonConfirm => 'Confirm';

  @override
  String get commonDelete => 'Delete';

  @override
  String get commonEdit => 'Edit';

  @override
  String get commonClose => 'Close';

  @override
  String get commonSearch => 'Search';

  @override
  String get commonFilter => 'Filter';

  @override
  String get commonSort => 'Sort';

  @override
  String get commonRetry => 'Retry';

  @override
  String get commonLoading => 'Loading...';

  @override
  String get commonError => 'Something went wrong';

  @override
  String get commonNoData => 'No data available';

  @override
  String get commonNoLimit => 'Unlimited';

  @override
  String get commonPerson => 'people';

  @override
  String get commonPerYear => '/year';

  @override
  String get commonUSD => 'USD';

  @override
  String get commonKm => 'km';

  @override
  String get commonHa => 'ha';

  @override
  String get commonM2 => 'm²';

  @override
  String get commonContact => 'Contact';

  @override
  String get commonAvailable => 'Available';

  @override
  String get commonNotAvailable => 'Not available';

  @override
  String get compareMaxZones => 'Max 3 zones to compare';

  @override
  String get compareRemovedMessage => 'Removed from comparison';

  @override
  String get compareAddedMessage => 'Added to comparison';

  @override
  String get compareViewAction => 'View comparison';

  @override
  String get compareRemoveTooltip => 'Remove from comparison';

  @override
  String get compareAddTooltip => 'Add to comparison';

  @override
  String compareTitle(int count) {
    return 'Compare $count IZs';
  }

  @override
  String get compareClearAll => 'Clear all';

  @override
  String get compareSaveResult => 'Save comparison';

  @override
  String get compareEmptyTitle => 'No zones to compare';

  @override
  String get compareEmptySubtitle => 'Add zones from search results to compare';

  @override
  String get compareBackToSearch => 'Back to search';

  @override
  String get compareSavedSuccess => 'Saved successfully!';

  @override
  String get compareSavedError => 'Could not save. Please try again.';

  @override
  String get compareLoginRequired => 'Please sign in to save results';

  @override
  String get compareCriteria => 'Criteria';

  @override
  String get compareProvinceRow => 'Province';

  @override
  String get compareRegionRow => 'Region';

  @override
  String get compareInfraScoreRow => 'Infra Score';

  @override
  String get compareLaborScoreRow => 'Labor Score';

  @override
  String get compareLogisticsScoreRow => 'Logistics Score';

  @override
  String get comparePriceRow => 'Lease Price (USD/m²/yr)';

  @override
  String get compareAreaRow => 'Available Area (ha)';

  @override
  String get compareOccupancyRow => 'Occupancy (%)';

  @override
  String get compareTaxRow => 'Tax Incentive (yrs)';

  @override
  String get compareSeaportRow => 'To seaport (km)';

  @override
  String get compareAirportRow => 'To airport (km)';

  @override
  String get compareDeveloperRow => 'Developer';

  @override
  String get zoneDetailTitle => 'IZ Detail';

  @override
  String zoneEstablishedYear(int year) {
    return 'Est. $year';
  }

  @override
  String get contactLeadSuccess => 'Consultation request received!';

  @override
  String get contactLeadError => 'Could not send request. Please try again.';

  @override
  String get tabOverview => 'Overview';

  @override
  String get tabInfraUtilities => 'Infrastructure & Utilities';

  @override
  String get tabLocationLogistics => 'Location & Logistics';

  @override
  String get zoneGeneralInfo => 'General Info';

  @override
  String get zonePriceIncentives => 'Price & Incentives';

  @override
  String get zoneProvinceLabel => 'Province/City';

  @override
  String get zoneRegionLabel => 'Region';

  @override
  String get zoneDeveloperLabel => 'Developer';

  @override
  String get zoneDeveloperNationalityLabel => 'Developer Nationality';

  @override
  String get zoneTotalAreaLabel => 'Total Area';

  @override
  String get zoneAvailableAreaLabel => 'Available Area';

  @override
  String get zoneOccupancyLabel => 'Occupancy Rate';

  @override
  String get zoneMinLeaseAreaLabel => 'Min Lease Area';

  @override
  String get zoneLeasePriceLabel => 'Land Lease Price';

  @override
  String get zoneServiceFeeLabel => 'Service Fee';

  @override
  String get zoneTaxIncentiveLabel => 'Tax Incentive';

  @override
  String get zoneTaxRateLabel => 'Preferential Tax Rate';

  @override
  String get zoneContactSection => 'Contact';

  @override
  String get zoneEmailLabel => 'Email';

  @override
  String get zoneWebsiteLabel => 'Website';

  @override
  String get zoneScoresTitle => 'Assessment Scores';

  @override
  String get zoneInfraDesc => 'Roads, utilities, telecom';

  @override
  String get zoneLaborDesc => 'Labor supply, regional skills';

  @override
  String get zoneLogisticsDesc => 'Seaport, airport, transport';

  @override
  String get zoneIndustriesTitle => 'Suitable Industries';

  @override
  String get zoneCertificationsTitle => 'Certifications';

  @override
  String get zoneDistancesTitle => 'Transport Distances';

  @override
  String get zoneSeaportDistLabel => 'To nearest seaport';

  @override
  String get zoneAirportDistLabel => 'To nearest airport';

  @override
  String get zoneHanoiLabel => 'To Hanoi';

  @override
  String get zoneHcmLabel => 'To Ho Chi Minh City';

  @override
  String get zoneMapComingSoon => 'Map coming soon';

  @override
  String get zoneLogisticsTitle => 'Logistics Assessment';

  @override
  String get zoneSeaportConnection => 'Seaport access';

  @override
  String get zoneAirportConnection => 'Airport access';

  @override
  String get zoneLogisticsOverall => 'Overall logistics score';

  @override
  String get zoneNoInfo => 'No information';

  @override
  String get zoneLogisticsOverallDesc => 'Based on overall assessment';

  @override
  String zoneSeaportKmDesc(String distance) {
    return '$distance km to nearest seaport';
  }

  @override
  String zoneAirportKmDesc(String distance) {
    return '$distance km to airport';
  }

  @override
  String get zoneUtilitiesTitle => 'Utilities';

  @override
  String get zoneUtilitiesPower => 'Power';

  @override
  String get zoneUtilitiesWater => 'Water supply';

  @override
  String get zoneUtilitiesWastewater => 'Wastewater treatment';

  @override
  String get zoneUtilitiesFiber => 'Fiber internet';

  @override
  String get leaseTrackerRegion => 'Region';

  @override
  String get leaseTrackerAssetType => 'Asset Type';

  @override
  String get leaseTrackerCreateFirstAlert => 'Create First Alert';

  @override
  String get leaseTrackerAlertZoneName => 'Zone Name (optional)';

  @override
  String get leaseTrackerAlertZoneHint => 'e.g. VSIP Bac Ninh';

  @override
  String get leaseTrackerAlertThreshold => 'Threshold price (USD/m²/yr)';

  @override
  String get leaseTrackerAlertDirection => 'Trigger when';

  @override
  String get leaseTrackerAlertCreate => 'Create Price Alert';

  @override
  String get leaseTrackerAlertSave => 'Create Alert';

  @override
  String get leaseTrackerAlertInvalidThreshold =>
      'Please enter a valid threshold price';

  @override
  String get leaseTrackerAlertError =>
      'Could not create alert. Please try again.';

  @override
  String get leaseTrackerFreeLimitTitle => 'Free Tier Limit';

  @override
  String get leaseTrackerFreeLimitContent =>
      'Free accounts can create up to 2 price alerts.\nUpgrade to Pro for unlimited alerts.';

  @override
  String get leaseTrackerLoginPromptTitle => 'Sign in to create Price Alerts';

  @override
  String get leaseTrackerLoginPromptSub =>
      'Get notified when IZ lease rates change according to your criteria.';

  @override
  String get leaseTrackerNoAlertsTitle => 'No alerts yet';

  @override
  String get leaseTrackerNoAlertsSub =>
      'Create your first alert to get notified when prices change.';

  @override
  String leaseTrackerKcnCount(int count) {
    return '$count IZ';
  }

  @override
  String get leaseTrackerStable => 'Stable';

  @override
  String get leaseTrackerMin => 'Min';

  @override
  String get leaseTrackerMax => 'Max';

  @override
  String get insightPremiumContent => 'Premium Content';

  @override
  String get insightPremiumUpgradePrompt => 'Upgrade to read full report';

  @override
  String get insightUpgradePro => 'Upgrade to Pro';

  @override
  String get insightCollapse => 'Collapse ▲';

  @override
  String get insightExpand => 'Read more ▼';

  @override
  String get alertDeleteTitle => 'Delete Alert';

  @override
  String get alertDeleteContent => 'Do you want to delete this price alert?';

  @override
  String alertLastTriggered(String date) {
    return 'Last triggered: $date';
  }

  @override
  String get tableHeaderZone => 'IZ';

  @override
  String get tableHeaderPrice => 'Price (USD)';

  @override
  String get tableHeaderChange => 'Change';

  @override
  String get tableHeaderSource => 'Source';

  @override
  String get permitDeleteTitle => 'Delete checklist';

  @override
  String get permitDeleteContent =>
      'This checklist will be archived and hidden. Are you sure?';

  @override
  String get permitFreeTierLimit =>
      'Free plan supports 1 checklist. Upgrade to Pro for unlimited.';

  @override
  String get permitUpgradePrompt => 'Upgrade to Pro to use this feature';

  @override
  String get permitProjectNameLabel => 'Project Name *';

  @override
  String get permitProjectNameHint => 'e.g. Samsung Factory Bac Ninh';

  @override
  String get permitProjectNameValidation => 'Please enter a project name';

  @override
  String get permitCompanyNameHint => 'e.g. Samsung Electronics Vietnam';

  @override
  String get permitProvinceHint => 'e.g. Bac Ninh';

  @override
  String permitDayEstimate(int days) {
    return '~$days days';
  }

  @override
  String permitStepCount(int count) {
    return '$count steps';
  }

  @override
  String permitStepDetail(int days, int steps) {
    return '~$days days · $steps procedure steps';
  }

  @override
  String get permitCompletedCongrats =>
      'Congratulations! You have completed all required procedures.';

  @override
  String get permitUpgradePdf => 'Upgrade to Pro to export PDF';

  @override
  String permitStepsCompleted(int done, int total) {
    return '$done / $total steps completed';
  }

  @override
  String permitInProgressCount(int count) {
    return '$count in progress';
  }

  @override
  String permitSkippedCount(int count) {
    return '$count skipped';
  }

  @override
  String get permitItemNotRequired => 'Optional';

  @override
  String get itemStatusPending => 'Not Started';

  @override
  String get itemStatusInProgress => 'In Progress';

  @override
  String get itemStatusDone => 'Done';

  @override
  String get itemStatusSkipped => 'Skip';
}
