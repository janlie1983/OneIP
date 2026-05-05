class LeaseRate {
  final String id;
  final String zoneName;
  final String province;
  final String region;
  final String assetType;
  final double priceUsd;
  final double? priceVndMillion;
  final DateTime recordedMonth;
  final String source;
  final bool isVerified;
  final String? notes;
  final DateTime createdAt;

  const LeaseRate({
    required this.id,
    required this.zoneName,
    required this.province,
    required this.region,
    required this.assetType,
    required this.priceUsd,
    this.priceVndMillion,
    required this.recordedMonth,
    required this.source,
    this.isVerified = false,
    this.notes,
    required this.createdAt,
  });

  String get formattedPrice => '\$${priceUsd.toStringAsFixed(0)}/m²/năm';

  String get assetTypeLabel => const {
        'factory': 'Nhà xưởng',
        'warehouse': 'Kho bãi',
        'land': 'Đất KCN',
        'office': 'Văn phòng',
      }[assetType] ??
      assetType;

  String get regionLabel => const {
        'North': 'Miền Bắc',
        'Central': 'Miền Trung',
        'South': 'Miền Nam',
      }[region] ??
      region;

  factory LeaseRate.fromMap(Map<String, dynamic> map) {
    return LeaseRate(
      id: map['id'] as String,
      zoneName: map['zone_name'] as String,
      province: map['province'] as String,
      region: map['region'] as String,
      assetType: map['asset_type'] as String,
      priceUsd: (map['price_usd'] as num).toDouble(),
      priceVndMillion: (map['price_vnd_million'] as num?)?.toDouble(),
      recordedMonth: DateTime.parse(map['recorded_month'] as String),
      source: map['source'] as String,
      isVerified: map['is_verified'] as bool? ?? false,
      notes: map['notes'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }
}
