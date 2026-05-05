class UserModel {
  final String id;
  final String email;
  final String? fullName;
  final String? companyName;
  final String? role;
  final DateTime createdAt;

  const UserModel({
    required this.id,
    required this.email,
    this.fullName,
    this.companyName,
    this.role,
    required this.createdAt,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] as String,
      email: map['email'] as String,
      fullName: map['full_name'] as String?,
      companyName: map['company_name'] as String?,
      role: map['role'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'company_name': companyName,
      'role': role,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
