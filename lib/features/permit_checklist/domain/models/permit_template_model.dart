import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class PermitTemplate {
  final String id;
  final String name;
  final String? description;
  final String category;
  final String difficulty;
  final bool isPremium;
  final int estimatedDays;
  final int totalItems;
  final DateTime createdAt;

  const PermitTemplate({
    required this.id,
    required this.name,
    this.description,
    required this.category,
    required this.difficulty,
    required this.isPremium,
    required this.estimatedDays,
    required this.totalItems,
    required this.createdAt,
  });

  factory PermitTemplate.fromMap(Map<String, dynamic> map) {
    return PermitTemplate(
      id: map['id'] as String,
      name: map['name'] as String,
      description: map['description'] as String?,
      category: map['category'] as String,
      difficulty: map['difficulty'] as String? ?? 'medium',
      isPremium: map['is_premium'] as bool? ?? false,
      estimatedDays: map['estimated_days'] as int? ?? 90,
      totalItems: map['total_items'] as int? ?? 0,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  String get categoryLabel {
    switch (category) {
      case 'factory_lease':
        return 'Thuê nhà xưởng';
      case 'land_use':
        return 'Quyền sử dụng đất';
      case 'eps':
        return 'EPS / Môi trường';
      case 'full_package':
        return 'Trọn gói FDI';
      default:
        return category;
    }
  }

  String get difficultyLabel {
    switch (difficulty) {
      case 'easy':
        return 'Đơn giản';
      case 'medium':
        return 'Trung bình';
      case 'hard':
        return 'Phức tạp';
      default:
        return difficulty;
    }
  }

  Color get difficultyColor {
    switch (difficulty) {
      case 'easy':
        return AppColors.success;
      case 'medium':
        return AppColors.gold;
      case 'hard':
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }

  IconData get categoryIcon {
    switch (category) {
      case 'factory_lease':
        return Icons.warehouse_outlined;
      case 'land_use':
        return Icons.terrain_outlined;
      case 'eps':
        return Icons.eco_outlined;
      case 'full_package':
        return Icons.account_balance_outlined;
      default:
        return Icons.description_outlined;
    }
  }
}
