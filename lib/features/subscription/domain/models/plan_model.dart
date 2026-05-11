String _formatVnd(int amount) {
  if (amount == 0) return '0đ';
  final str = amount.toString();
  final buffer = StringBuffer();
  for (int i = 0; i < str.length; i++) {
    if (i > 0 && (str.length - i) % 3 == 0) buffer.write('.');
    buffer.write(str[i]);
  }
  return '${buffer.toString()}đ';
}

class PlanModel {
  final String id;
  final String name;
  final double priceUsd;
  final int priceVnd;
  final String billingPeriod;
  final int maxChecklists;
  final int maxAlerts;
  final int maxSeats;
  final bool hasPdfExport;
  final bool hasRealTimeData;
  final bool hasMarketReport;
  final bool hasApiAccess;
  final List<String> featuresVi;
  final List<String> featuresEn;
  final bool isActive;

  const PlanModel({
    required this.id,
    required this.name,
    required this.priceUsd,
    required this.priceVnd,
    required this.billingPeriod,
    required this.maxChecklists,
    required this.maxAlerts,
    required this.maxSeats,
    required this.hasPdfExport,
    required this.hasRealTimeData,
    required this.hasMarketReport,
    required this.hasApiAccess,
    required this.featuresVi,
    required this.featuresEn,
    required this.isActive,
  });

  bool get isFree => name == 'free';
  bool get isPro => name == 'pro';
  bool get isEnterprise => name == 'enterprise';

  String get priceLabel =>
      isFree ? 'Miễn phí' : '\$${priceUsd.toInt()}/tháng';

  String get priceLabelVnd =>
      isFree ? 'Miễn phí' : '${_formatVnd(priceVnd)}/tháng';

  factory PlanModel.fromMap(Map<String, dynamic> map) {
    List<String> parseArray(dynamic value) {
      if (value == null) return [];
      if (value is List) return value.cast<String>();
      return [];
    }

    return PlanModel(
      id: map['id'] as String,
      name: map['name'] as String,
      priceUsd: (map['price_usd'] as num).toDouble(),
      priceVnd: (map['price_vnd'] as num).toInt(),
      billingPeriod: map['billing_period'] as String? ?? 'monthly',
      maxChecklists: (map['max_checklists'] as num?)?.toInt() ?? 1,
      maxAlerts: (map['max_alerts'] as num?)?.toInt() ?? 2,
      maxSeats: (map['max_seats'] as num?)?.toInt() ?? 1,
      hasPdfExport: map['has_pdf_export'] as bool? ?? false,
      hasRealTimeData: map['has_real_time_data'] as bool? ?? false,
      hasMarketReport: map['has_market_report'] as bool? ?? false,
      hasApiAccess: map['has_api_access'] as bool? ?? false,
      featuresVi: parseArray(map['features_vi']),
      featuresEn: parseArray(map['features_en']),
      isActive: map['is_active'] as bool? ?? true,
    );
  }
}
