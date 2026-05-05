class RateAlert {
  final String? id;
  final String userId;
  final String? zoneName;
  final String? province;
  final String? region;
  final String? assetType;
  final double thresholdPriceUsd;
  final String direction; // 'above' | 'below'
  final bool isActive;
  final DateTime? lastTriggeredAt;
  final DateTime? createdAt;

  const RateAlert({
    this.id,
    required this.userId,
    this.zoneName,
    this.province,
    this.region,
    this.assetType,
    required this.thresholdPriceUsd,
    required this.direction,
    this.isActive = true,
    this.lastTriggeredAt,
    this.createdAt,
  });

  String get directionLabel =>
      direction == 'above' ? 'Khi giá vượt' : 'Khi giá xuống dưới';

  String get scopeLabel {
    if (zoneName != null) return zoneName!;
    if (province != null) return province!;
    if (region != null) {
      return const {
            'North': 'Miền Bắc',
            'Central': 'Miền Trung',
            'South': 'Miền Nam',
          }[region] ??
          region!;
    }
    return 'Tất cả thị trường';
  }

  String get assetTypeLabel => const {
        'factory': 'Nhà xưởng',
        'warehouse': 'Kho bãi',
        'land': 'Đất KCN',
        'office': 'Văn phòng',
      }[assetType] ??
      (assetType ?? 'Tất cả loại');

  factory RateAlert.fromMap(Map<String, dynamic> map) {
    return RateAlert(
      id: map['id'] as String?,
      userId: map['user_id'] as String,
      zoneName: map['zone_name'] as String?,
      province: map['province'] as String?,
      region: map['region'] as String?,
      assetType: map['asset_type'] as String?,
      thresholdPriceUsd: (map['threshold_price_usd'] as num).toDouble(),
      direction: map['direction'] as String,
      isActive: map['is_active'] as bool? ?? true,
      lastTriggeredAt: map['last_triggered_at'] != null
          ? DateTime.parse(map['last_triggered_at'] as String)
          : null,
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toInsertMap() {
    return {
      'user_id': userId,
      if (zoneName != null) 'zone_name': zoneName,
      if (province != null) 'province': province,
      if (region != null) 'region': region,
      if (assetType != null) 'asset_type': assetType,
      'threshold_price_usd': thresholdPriceUsd,
      'direction': direction,
      'is_active': isActive,
    };
  }
}
