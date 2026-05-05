import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class UserChecklist {
  final String id;
  final String userId;
  final String templateId;
  final String projectName;
  final String? companyName;
  final String? province;
  final String status;
  final int completedItems;
  final int totalItems;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserChecklist({
    required this.id,
    required this.userId,
    required this.templateId,
    required this.projectName,
    this.companyName,
    this.province,
    required this.status,
    required this.completedItems,
    required this.totalItems,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserChecklist.fromMap(Map<String, dynamic> map) {
    return UserChecklist(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      templateId: map['template_id'] as String,
      projectName: map['project_name'] as String,
      companyName: map['company_name'] as String?,
      province: map['province'] as String?,
      status: map['status'] as String? ?? 'active',
      completedItems: map['completed_items'] as int? ?? 0,
      totalItems: map['total_items'] as int? ?? 0,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  double get progressPercent =>
      totalItems == 0 ? 0 : completedItems / totalItems;

  String get statusLabel {
    switch (status) {
      case 'active':
        return 'Đang thực hiện';
      case 'completed':
        return 'Hoàn thành';
      case 'archived':
        return 'Đã lưu trữ';
      default:
        return status;
    }
  }

  Color get statusColor {
    switch (status) {
      case 'active':
        return AppColors.navy;
      case 'completed':
        return AppColors.success;
      case 'archived':
        return AppColors.textSecondary;
      default:
        return AppColors.textSecondary;
    }
  }
}
