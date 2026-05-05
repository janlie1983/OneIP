import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/models/checklist_progress_model.dart';
import '../../domain/models/permit_item_model.dart';

String _itemStatusLabel(AppLocalizations l, String s) {
  switch (s) {
    case 'pending':
      return l.itemStatusPending;
    case 'in_progress':
      return l.itemStatusInProgress;
    case 'done':
      return l.itemStatusDone;
    case 'skipped':
      return l.itemStatusSkipped;
    default:
      return s;
  }
}

Color _statusColor(String s) {
  switch (s) {
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

IconData _statusIcon(String s) {
  switch (s) {
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

class PermitItemTile extends StatelessWidget {
  final PermitItem item;
  final String currentStatus;
  final ValueChanged<String> onStatusChanged;

  const PermitItemTile({
    super.key,
    required this.item,
    required this.currentStatus,
    required this.onStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final isDone = currentStatus == 'done';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(
          color: isDone
              ? AppColors.success.withValues(alpha: 0.4)
              : AppColors.border,
        ),
      ),
      color: isDone ? AppColors.success.withValues(alpha: 0.04) : Colors.white,
      child: ExpansionTile(
        leading: Icon(
          item.categoryIcon,
          size: 22,
          color: isDone ? AppColors.success : AppColors.navy,
        ),
        title: Text(
          item.title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isDone ? AppColors.textSecondary : AppColors.navy,
            decoration: isDone ? TextDecoration.lineThrough : null,
          ),
        ),
        subtitle: Row(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 4),
              padding:
                  const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: _statusColor(currentStatus).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(_statusIcon(currentStatus),
                      size: 11, color: _statusColor(currentStatus)),
                  const SizedBox(width: 3),
                  Text(
                    _itemStatusLabel(l, currentStatus),
                    style: TextStyle(
                      fontSize: 11,
                      color: _statusColor(currentStatus),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 6),
            if (!item.isRequired)
              Container(
                margin: const EdgeInsets.only(top: 4),
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  l.permitItemNotRequired,
                  style: const TextStyle(
                      fontSize: 11, color: AppColors.textSecondary),
                ),
              ),
          ],
        ),
        childrenPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
          if (item.description != null)
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                item.description!,
                style: const TextStyle(
                    fontSize: 13, color: AppColors.textSecondary),
              ),
            ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.access_time,
                  size: 14, color: AppColors.textSecondary),
              const SizedBox(width: 4),
              Text(
                l.permitDayEstimate(item.estimatedDays),
                style: const TextStyle(
                    fontSize: 12, color: AppColors.textSecondary),
              ),
              const SizedBox(width: 16),
              const Icon(Icons.account_balance_wallet_outlined,
                  size: 14, color: AppColors.textSecondary),
              const SizedBox(width: 4),
              Text(
                item.formattedFee,
                style: const TextStyle(
                    fontSize: 12, color: AppColors.textSecondary),
              ),
              if (item.authority != null) ...[
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    item.authority!,
                    style: const TextStyle(
                        fontSize: 11, color: AppColors.textSecondary),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 12),
          _StatusButtons(
            currentStatus: currentStatus,
            onStatusChanged: onStatusChanged,
          ),
        ],
      ),
    );
  }
}

class _StatusButtons extends StatelessWidget {
  final String currentStatus;
  final ValueChanged<String> onStatusChanged;

  const _StatusButtons({
    required this.currentStatus,
    required this.onStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final statuses = [
      ('pending', l.itemStatusPending, Icons.radio_button_unchecked),
      ('in_progress', l.itemStatusInProgress, Icons.timelapse),
      ('done', l.itemStatusDone, Icons.check_circle),
      ('skipped', l.itemStatusSkipped, Icons.remove_circle_outline),
    ];

    return Wrap(
      spacing: 6,
      children: statuses.map((entry) {
        final (value, label, icon) = entry;
        final isSelected = currentStatus == value;
        final color = ChecklistProgress(
          id: '',
          checklistId: '',
          itemId: '',
          status: value,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ).statusColor;

        return GestureDetector(
          onTap: () => onStatusChanged(value),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: isSelected
                  ? color.withValues(alpha: 0.15)
                  : Colors.transparent,
              border: Border.all(
                color: isSelected ? color : AppColors.border,
                width: isSelected ? 1.5 : 1,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon,
                    size: 14,
                    color: isSelected ? color : AppColors.textSecondary),
                const SizedBox(width: 4),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.normal,
                    color: isSelected ? color : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
