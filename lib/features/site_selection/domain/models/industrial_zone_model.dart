class IndustrialZone {
  final String id;
  final String name;
  final String province;
  final String region;
  final double? totalAreaHa;
  final double? availableAreaHa;
  final double? leasePriceUsd;
  final double? serviceFeeUsd;
  final int? infraScore;
  final int? laborScore;
  final int? logisticsScore;
  final int? taxIncentiveYears;
  final double? taxIncentiveRate;
  final List<String> industriesSupported;
  final double? distanceToSeaportKm;
  final double? distanceToAirportKm;
  final double? distanceToHanoiKm;
  final double? distanceToHcmKm;
  final String? developer;
  final String? developerNationality;
  final int? establishedYear;
  final double? occupancyRate;
  final double? minLeaseAreaM2;
  final String? utilitiesPowerKv;
  final bool utilitiesWater;
  final bool utilitiesWastewater;
  final bool fiberInternet;
  final List<String> certifications;
  final String? imageUrl;
  final String? website;
  final String? contactEmail;
  final bool isFeatured;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const IndustrialZone({
    required this.id,
    required this.name,
    required this.province,
    required this.region,
    this.totalAreaHa,
    this.availableAreaHa,
    this.leasePriceUsd,
    this.serviceFeeUsd,
    this.infraScore,
    this.laborScore,
    this.logisticsScore,
    this.taxIncentiveYears,
    this.taxIncentiveRate,
    this.industriesSupported = const [],
    this.distanceToSeaportKm,
    this.distanceToAirportKm,
    this.distanceToHanoiKm,
    this.distanceToHcmKm,
    this.developer,
    this.developerNationality,
    this.establishedYear,
    this.occupancyRate,
    this.minLeaseAreaM2,
    this.utilitiesPowerKv,
    this.utilitiesWater = true,
    this.utilitiesWastewater = true,
    this.fiberInternet = true,
    this.certifications = const [],
    this.imageUrl,
    this.website,
    this.contactEmail,
    this.isFeatured = false,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  double get overallScore =>
      ((infraScore ?? 0) + (laborScore ?? 0) + (logisticsScore ?? 0)) / 3;

  factory IndustrialZone.fromMap(Map<String, dynamic> map) {
    return IndustrialZone(
      id: map['id'] as String,
      name: map['name'] as String,
      province: map['province'] as String,
      region: map['region'] as String,
      totalAreaHa: (map['total_area_ha'] as num?)?.toDouble(),
      availableAreaHa: (map['available_area_ha'] as num?)?.toDouble(),
      leasePriceUsd: (map['lease_price_usd'] as num?)?.toDouble(),
      serviceFeeUsd: (map['service_fee_usd'] as num?)?.toDouble(),
      infraScore: map['infra_score'] as int?,
      laborScore: map['labor_score'] as int?,
      logisticsScore: map['logistics_score'] as int?,
      taxIncentiveYears: map['tax_incentive_years'] as int?,
      taxIncentiveRate: (map['tax_incentive_rate'] as num?)?.toDouble(),
      industriesSupported: (map['industries_supported'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      distanceToSeaportKm: (map['distance_to_seaport_km'] as num?)?.toDouble(),
      distanceToAirportKm: (map['distance_to_airport_km'] as num?)?.toDouble(),
      distanceToHanoiKm: (map['distance_to_hanoi_km'] as num?)?.toDouble(),
      distanceToHcmKm: (map['distance_to_hcm_km'] as num?)?.toDouble(),
      developer: map['developer'] as String?,
      developerNationality: map['developer_nationality'] as String?,
      establishedYear: map['established_year'] as int?,
      occupancyRate: (map['occupancy_rate'] as num?)?.toDouble(),
      minLeaseAreaM2: (map['min_lease_area_m2'] as num?)?.toDouble(),
      utilitiesPowerKv: map['utilities_power_kv'] as String?,
      utilitiesWater: map['utilities_water'] as bool? ?? true,
      utilitiesWastewater: map['utilities_wastewater'] as bool? ?? true,
      fiberInternet: map['fiber_internet'] as bool? ?? true,
      certifications: (map['certifications'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      imageUrl: map['image_url'] as String?,
      website: map['website'] as String?,
      contactEmail: map['contact_email'] as String?,
      isFeatured: map['is_featured'] as bool? ?? false,
      isActive: map['is_active'] as bool? ?? true,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'province': province,
      'region': region,
      'total_area_ha': totalAreaHa,
      'available_area_ha': availableAreaHa,
      'lease_price_usd': leasePriceUsd,
      'service_fee_usd': serviceFeeUsd,
      'infra_score': infraScore,
      'labor_score': laborScore,
      'logistics_score': logisticsScore,
      'tax_incentive_years': taxIncentiveYears,
      'tax_incentive_rate': taxIncentiveRate,
      'industries_supported': industriesSupported,
      'distance_to_seaport_km': distanceToSeaportKm,
      'distance_to_airport_km': distanceToAirportKm,
      'distance_to_hanoi_km': distanceToHanoiKm,
      'distance_to_hcm_km': distanceToHcmKm,
      'developer': developer,
      'developer_nationality': developerNationality,
      'established_year': establishedYear,
      'occupancy_rate': occupancyRate,
      'min_lease_area_m2': minLeaseAreaM2,
      'utilities_power_kv': utilitiesPowerKv,
      'utilities_water': utilitiesWater,
      'utilities_wastewater': utilitiesWastewater,
      'fiber_internet': fiberInternet,
      'certifications': certifications,
      'image_url': imageUrl,
      'website': website,
      'contact_email': contactEmail,
      'is_featured': isFeatured,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
