import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/models/rate_alert_model.dart';
import '../providers/lease_tracker_provider.dart';

class AlertCard extends ConsumerWidget {
  final RateAlert alert;

  const AlertCard({super.key, required this.alert});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Dismissible(
      key: ValueKey(alert.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppColors.error.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete_outline, color: AppColors.error, size: 24),
      ),
      confirmDismiss: (_) => showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Xóa Alert'),
          content: const Text('Bạn có muốn xóa alert giá này không?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Hủy'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Xóa', style: TextStyle(color: AppColors.error)),
            ),
          ],
        ),
      ),
      onDismissed: (_) async {
        if (alert.id != null) {
          await ref
              .read(leaseTrackerRepositoryProvider)
              .deleteAlert(alert.id!);
          ref.invalidate(userAlertsProvider);
        }
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              _AlertIcon(direction: alert.direction, isActive: alert.isActive),
              const SizedBox(width: 12),
              Expanded(child: _AlertInfo(alert: alert)),
              _AlertToggle(alert: alert),
            ],
          ),
        ),
      ),
    );
  }
}

class _AlertIcon extends StatelessWidget {
  final String direction;
  final bool isActive;
  const _AlertIcon({required this.direction, required this.isActive});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: (isActive
                ? (direction == 'above' ? AppColors.error : AppColors.success)
                : AppColors.textSecondary)
            .withValues(alpha: 0.12),
        shape: BoxShape.circle,
      ),
      child: Icon(
        direction == 'above' ? Icons.notifications_active : Icons.notifications,
        size: 20,
        color: isActive
            ? (direction == 'above' ? AppColors.error : AppColors.success)
            : AppColors.textSecondary,
      ),
    );
  }
}

class _AlertInfo extends StatelessWidget {
  final RateAlert alert;
  const _AlertInfo({required this.alert});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          alert.scopeLabel,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppColors.navy,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          '${alert.assetTypeLabel} · ${alert.directionLabel} \$${alert.thresholdPriceUsd.toStringAsFixed(0)}/m²/năm',
          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
        if (alert.lastTriggeredAt != null) ...[
          const SizedBox(height: 2),
          Text(
            'Kích hoạt lần cuối: ${DateFormat('dd/MM/yyyy').format(alert.lastTriggeredAt!)}',
            style: const TextStyle(fontSize: 11, color: AppColors.gold),
          ),
        ],
      ],
    );
  }
}

class _AlertToggle extends ConsumerWidget {
  final RateAlert alert;
  const _AlertToggle({required this.alert});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Switch(
      value: alert.isActive,
      activeThumbColor: AppColors.navy,
      onChanged: alert.id == null
          ? null
          : (value) async {
              await ref
                  .read(leaseTrackerRepositoryProvider)
                  .toggleAlert(alert.id!, value);
              ref.invalidate(userAlertsProvider);
            },
    );
  }
}
