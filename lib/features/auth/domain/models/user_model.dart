enum UserRole {
  superAdmin,
  admin,
  moderator,
  propertyOwner,
  broker,
  corporate,
  sme,
  guest;

  String get value => switch (this) {
        UserRole.superAdmin => 'super_admin',
        UserRole.admin => 'admin',
        UserRole.moderator => 'moderator',
        UserRole.propertyOwner => 'property_owner',
        UserRole.broker => 'broker',
        UserRole.corporate => 'corporate',
        UserRole.sme => 'sme',
        UserRole.guest => 'guest',
      };

  String get labelVi => switch (this) {
        UserRole.superAdmin => 'Quản trị hệ thống',
        UserRole.admin => 'Quản trị viên',
        UserRole.moderator => 'Kiểm duyệt viên',
        UserRole.propertyOwner => 'Chủ KCN / Kho xưởng',
        UserRole.broker => 'Môi giới BĐS',
        UserRole.corporate => 'Doanh nghiệp FDI',
        UserRole.sme => 'Doanh nghiệp vừa nhỏ',
        UserRole.guest => 'Khách',
      };

  String get labelEn => switch (this) {
        UserRole.superAdmin => 'Super Admin',
        UserRole.admin => 'Admin',
        UserRole.moderator => 'Moderator',
        UserRole.propertyOwner => 'Property Owner',
        UserRole.broker => 'Broker / Agency',
        UserRole.corporate => 'Corporate / FDI',
        UserRole.sme => 'SME / Individual',
        UserRole.guest => 'Guest',
      };

  bool get isAdmin => [
        UserRole.superAdmin,
        UserRole.admin,
        UserRole.moderator,
      ].contains(this);

  bool get isSupply => [
        UserRole.propertyOwner,
        UserRole.broker,
      ].contains(this);

  bool get isDemand => [
        UserRole.corporate,
        UserRole.sme,
        UserRole.guest,
      ].contains(this);

  static UserRole fromString(String value) => UserRole.values.firstWhere(
        (r) => r.value == value,
        orElse: () => UserRole.guest,
      );
}

class UserModel {
  final String id;
  final String email;
  final String? fullName;
  final UserRole role;
  final DateTime? roleSelectedAt;
  final bool isVerified;
  final DateTime? verifiedAt;
  final String kycStatus;
  final String? phone;
  final String? avatarUrl;
  final String? bio;
  final String? companyName;
  final String? companySize;
  final String? taxCode;
  final DateTime createdAt;

  const UserModel({
    required this.id,
    required this.email,
    this.fullName,
    this.role = UserRole.guest,
    this.roleSelectedAt,
    this.isVerified = false,
    this.verifiedAt,
    this.kycStatus = 'none',
    this.phone,
    this.avatarUrl,
    this.bio,
    this.companyName,
    this.companySize,
    this.taxCode,
    required this.createdAt,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] as String,
      email: map['email'] as String,
      fullName: map['full_name'] as String?,
      role: UserRole.fromString(map['role'] as String? ?? 'guest'),
      roleSelectedAt: map['role_selected_at'] != null
          ? DateTime.parse(map['role_selected_at'] as String)
          : null,
      isVerified: map['is_verified'] as bool? ?? false,
      verifiedAt: map['verified_at'] != null
          ? DateTime.parse(map['verified_at'] as String)
          : null,
      kycStatus: map['kyc_status'] as String? ?? 'none',
      phone: map['phone'] as String?,
      avatarUrl: map['avatar_url'] as String?,
      bio: map['bio'] as String?,
      companyName: map['company_name'] as String?,
      companySize: map['company_size'] as String?,
      taxCode: map['tax_code'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'role': role.value,
      'role_selected_at': roleSelectedAt?.toIso8601String(),
      'is_verified': isVerified,
      'verified_at': verifiedAt?.toIso8601String(),
      'kyc_status': kycStatus,
      'phone': phone,
      'avatar_url': avatarUrl,
      'bio': bio,
      'company_name': companyName,
      'company_size': companySize,
      'tax_code': taxCode,
      'created_at': createdAt.toIso8601String(),
    };
  }

  UserModel copyWith({
    String? fullName,
    UserRole? role,
    DateTime? roleSelectedAt,
    bool? isVerified,
    DateTime? verifiedAt,
    String? kycStatus,
    String? phone,
    String? avatarUrl,
    String? bio,
    String? companyName,
    String? companySize,
    String? taxCode,
  }) {
    return UserModel(
      id: id,
      email: email,
      fullName: fullName ?? this.fullName,
      role: role ?? this.role,
      roleSelectedAt: roleSelectedAt ?? this.roleSelectedAt,
      isVerified: isVerified ?? this.isVerified,
      verifiedAt: verifiedAt ?? this.verifiedAt,
      kycStatus: kycStatus ?? this.kycStatus,
      phone: phone ?? this.phone,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      bio: bio ?? this.bio,
      companyName: companyName ?? this.companyName,
      companySize: companySize ?? this.companySize,
      taxCode: taxCode ?? this.taxCode,
      createdAt: createdAt,
    );
  }
}
