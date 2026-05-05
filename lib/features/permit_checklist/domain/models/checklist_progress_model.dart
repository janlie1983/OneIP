import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class ChecklistProgress {
  final String id;
  final String checklistId;
  final String itemId;
  final String status;
  final String? notes;
  final DateTime? completedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ChecklistProgress({
    required this.id,
    required this.checklistId,
    required this.itemId,
    required this.status,
    this.notes,
    this.completedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ChecklistProgress.fromMap(Map<String, dynamic> map) {
    return ChecklistProgress(
      id: map['id'] as String,
      checklistId: map['checklist_id'] as String,
      itemId: map['item_id'] as String,
      status: map['status'] as String? ?? 'pending',
      notes: map['notes'] as String?,
      completedAt: map['completed_at'] != null
          ? DateTime.parse(map['completed_at'] as String)
          : null,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  Map<String, dynamic> toUpsertMap() {
    return {
      'checklist_id': checklistId,
      'item_id': itemId,
      'status': status,
      if (notes != null) 'notes': notes,
      if (completedAt != null) 'completed_at': completedAt!.toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    };
  }

  String get statusLabel {
    switch (status) {
      case 'pending':
        return 'Chưa làm';
      case 'in_progress':
        return 'Đang thực hiện';
      case 'done':
        return 'Hoàn thành';
      case 'skipped':
        return 'Bỏ qua';
      default:
        return status;
    }
  }

  Color get statusColor {
    switch (status) {
      case 'pending':
        return AppColors.textSecondary;
      case 'in_progress':
        return AppColors.gold;
      case 'done':
        return AppColors.success;
      case 'skipped':
        return AppColors.border;
      default:
        return AppColors.textSecondary;
    }
  }

  IconData get statusIcon {
    switch (status) {
      case 'pending':
        return Icons.radio_button_unchecked;
      case 'in_progress':
        return Icons.timelapse;
      case 'done':
        return Icons.check_circle;
      case 'skipped':
        return Icons.remove_circle_outline;
      default:
        return Icons.radio_button_unchecked;
    }
  }
}
