import 'package:flutter/material.dart';

class Listing {
  final String id;
  final String? ownerId;
  final String? zoneId;
  final String title;
  final String? titleEn;
  final String? description;
  final String? descriptionEn;
  final String assetType;
  final String province;
  final String? district;
  final String region;
  final String? address;
  final double? latitude;
  final double? longitude;
  final double totalAreaM2;
  final double? officeAreaM2;
  final double? clearHeightM;
  final double? floorLoadCapacity;
  final int numberOfFloors;
  final int? yearBuilt;
  final double? leasePriceUsd;
  final int? leasePriceVnd;
  final int? minLeaseTermMonths;
  final bool isNegotiable;
  final DateTime? availableFrom;
  final double? availableAreaM2;
  final double? occupancyRate;
  final double? powerCapacityKva;
  final bool has3PhasePower;
  final bool hasWaterSupply;
  final bool hasWastewaterTreatment;
  final bool hasFiberInternet;
  final bool hasSecurity;
  final bool hasCanteen;
  final bool hasParking;
  final bool hasLoadingDock;
  final int? loadingDockCount;
  final List<String> images;
  final String? videoUrl;
  final String? floorPlanUrl;
  final String status;
  final bool isFeatured;
  final bool isVerified;
  final String? slug;
  final int viewCount;
  final int inquiryCount;
  final String? contactName;
  final String? contactPhone;
  final String? contactEmail;
  final String? contactZalo;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Listing({
    required this.id,
    this.ownerId,
    this.zoneId,
    required this.title,
    this.titleEn,
    this.description,
    this.descriptionEn,
    required this.assetType,
    required this.province,
    this.district,
    required this.region,
    this.address,
    this.latitude,
    this.longitude,
    required this.totalAreaM2,
    this.officeAreaM2,
    this.clearHeightM,
    this.floorLoadCapacity,
    this.numberOfFloors = 1,
    this.yearBuilt,
    this.leasePriceUsd,
    this.leasePriceVnd,
    this.minLeaseTermMonths,
    this.isNegotiable = true,
    this.availableFrom,
    this.availableAreaM2,
    this.occupancyRate,
    this.powerCapacityKva,
    this.has3PhasePower = true,
    this.hasWaterSupply = true,
    this.hasWastewaterTreatment = false,
    this.hasFiberInternet = true,
    this.hasSecurity = true,
    this.hasCanteen = false,
    this.hasParking = true,
    this.hasLoadingDock = false,
    this.loadingDockCount,
    this.images = const [],
    this.videoUrl,
    this.floorPlanUrl,
    this.status = 'draft',
    this.isFeatured = false,
    this.isVerified = false,
    this.slug,
    this.viewCount = 0,
    this.inquiryCount = 0,
    this.contactName,
    this.contactPhone,
    this.contactEmail,
    this.contactZalo,
    required this.createdAt,
    required this.updatedAt,
  });

  String get assetTypeLabel => switch (assetType) {
        'rbf' => 'Nhà xưởng xây sẵn',
        'rbw' => 'Kho xây sẵn',
        'land' => 'Đất KCN',
        'office' => 'Văn phòng nhà máy',
        _ => assetType,
      };

  String get assetTypeLabelEn => switch (assetType) {
        'rbf' => 'Ready Built Factory',
        'rbw' => 'Ready Built Warehouse',
        'land' => 'Industrial Land',
        'office' => 'Factory Office',
        _ => assetType,
      };

  String get regionLabel => switch (region) {
        'North' => 'Miền Bắc',
        'Central' => 'Miền Trung',
        'South' => 'Miền Nam',
        _ => region,
      };

  String get priceLabel => leasePriceUsd != null
      ? '\$${leasePriceUsd!.toStringAsFixed(0)}/m²/năm'
      : 'Liên hệ';

  Color get assetTypeColor => switch (assetType) {
        'rbf' => const Color(0xFF1B2A4A),
        'rbw' => const Color(0xFF2E7D32),
        'land' => const Color(0xFFF57C00),
        'office' => const Color(0xFF6A1B9A),
        _ => Colors.grey,
      };

  IconData get assetTypeIcon => switch (assetType) {
        'rbf' => Icons.factory,
        'rbw' => Icons.warehouse,
        'land' => Icons.landscape,
        'office' => Icons.business,
        _ => Icons.business,
      };

  factory Listing.fromMap(Map<String, dynamic> map) {
    return Listing(
      id: map['id'] as String,
      ownerId: map['owner_id'] as String?,
      zoneId: map['zone_id'] as String?,
      title: map['title'] as String,
      titleEn: map['title_en'] as String?,
      description: map['description'] as String?,
      descriptionEn: map['description_en'] as String?,
      assetType: map['asset_type'] as String,
      province: map['province'] as String,
      district: map['district'] as String?,
      region: map['region'] as String,
      address: map['address'] as String?,
      latitude: (map['latitude'] as num?)?.toDouble(),
      longitude: (map['longitude'] as num?)?.toDouble(),
      totalAreaM2: (map['total_area_m2'] as num).toDouble(),
      officeAreaM2: (map['office_area_m2'] as num?)?.toDouble(),
      clearHeightM: (map['clear_height_m'] as num?)?.toDouble(),
      floorLoadCapacity: (map['floor_load_capacity'] as num?)?.toDouble(),
      numberOfFloors: map['number_of_floors'] as int? ?? 1,
      yearBuilt: map['year_built'] as int?,
      leasePriceUsd: (map['lease_price_usd'] as num?)?.toDouble(),
      leasePriceVnd: map['lease_price_vnd'] as int?,
      minLeaseTermMonths: map['min_lease_term_months'] as int?,
      isNegotiable: map['is_negotiable'] as bool? ?? true,
      availableFrom: map['available_from'] != null
          ? DateTime.parse(map['available_from'] as String)
          : null,
      availableAreaM2: (map['available_area_m2'] as num?)?.toDouble(),
      occupancyRate: (map['occupancy_rate'] as num?)?.toDouble(),
      powerCapacityKva: (map['power_capacity_kva'] as num?)?.toDouble(),
      has3PhasePower: map['has_3_phase_power'] as bool? ?? true,
      hasWaterSupply: map['has_water_supply'] as bool? ?? true,
      hasWastewaterTreatment: map['has_wastewater_treatment'] as bool? ?? false,
      hasFiberInternet: map['has_fiber_internet'] as bool? ?? true,
      hasSecurity: map['has_security'] as bool? ?? true,
      hasCanteen: map['has_canteen'] as bool? ?? false,
      hasParking: map['has_parking'] as bool? ?? true,
      hasLoadingDock: map['has_loading_dock'] as bool? ?? false,
      loadingDockCount: map['loading_dock_count'] as int?,
      images: (map['images'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      videoUrl: map['video_url'] as String?,
      floorPlanUrl: map['floor_plan_url'] as String?,
      status: map['status'] as String? ?? 'draft',
      isFeatured: map['is_featured'] as bool? ?? false,
      isVerified: map['is_verified'] as bool? ?? false,
      slug: map['slug'] as String?,
      viewCount: map['view_count'] as int? ?? 0,
      inquiryCount: map['inquiry_count'] as int? ?? 0,
      contactName: map['contact_name'] as String?,
      contactPhone: map['contact_phone'] as String?,
      contactEmail: map['contact_email'] as String?,
      contactZalo: map['contact_zalo'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }
}
