import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PermitItem {
  final String id;
  final String templateId;
  final String category;
  final String title;
  final String? description;
  final String? authority;
  final int estimatedDays;
  final int? feeVnd;
  final bool isRequired;
  final int sortOrder;

  const PermitItem({
    required this.id,
    required this.templateId,
    required this.category,
    required this.title,
    this.description,
    this.authority,
    required this.estimatedDays,
    this.feeVnd,
    required this.isRequired,
    required this.sortOrder,
  });

  factory PermitItem.fromMap(Map<String, dynamic> map) {
    return PermitItem(
      id: map['id'] as String,
      templateId: map['template_id'] as String,
      category: map['category'] as String,
      title: map['title'] as String,
      description: map['description'] as String?,
      authority: map['authority'] as String?,
      estimatedDays: map['estimated_days'] as int? ?? 7,
      feeVnd: map['fee_vnd'] as int?,
      isRequired: map['is_required'] as bool? ?? true,
      sortOrder: map['sort_order'] as int? ?? 0,
    );
  }

  String get categoryLabel {
    switch (category) {
      case 'registration':
        return 'Đăng ký';
      case 'environment':
        return 'Môi trường';
      case 'fire_safety':
        return 'PCCC';
      case 'construction':
        return 'Xây dựng';
      case 'labor':
        return 'Lao động';
      case 'tax':
        return 'Thuế';
      default:
        return category;
    }
  }

  IconData get categoryIcon {
    switch (category) {
      case 'registration':
        return Icons.how_to_reg_outlined;
      case 'environment':
        return Icons.eco_outlined;
      case 'fire_safety':
        return Icons.local_fire_department_outlined;
      case 'construction':
        return Icons.construction_outlined;
      case 'labor':
        return Icons.people_outline;
      case 'tax':
        return Icons.receipt_long_outlined;
      default:
        return Icons.task_outlined;
    }
  }

  String get formattedFee {
    if (feeVnd == null || feeVnd == 0) return 'Miễn phí';
    final formatter = NumberFormat('#,##0', 'vi_VN');
    return '${formatter.format(feeVnd)} VND';
  }
}
