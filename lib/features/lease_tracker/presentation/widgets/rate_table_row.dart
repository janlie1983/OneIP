import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/models/lease_rate_model.dart';

class RateTableHeader extends StatelessWidget {
  final String sortColumn;
  final bool sortAscending;
  final ValueChanged<String> onSort;

  const RateTableHeader({
    super.key,
    required this.sortColumn,
    required this.sortAscending,
    required this.onSort,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Container(
      color: AppColors.navy.withValues(alpha: 0.05),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: _HeaderCell(l.tableHeaderZone, 'zone', sortColumn, sortAscending, onSort),
          ),
          Expanded(
            flex: 2,
            child: _HeaderCell(l.tableHeaderPrice, 'price', sortColumn, sortAscending, onSort),
          ),
          Expanded(
            flex: 2,
            child: _HeaderCell(l.tableHeaderChange, 'change', sortColumn, sortAscending, onSort),
          ),
          Expanded(
            flex: 1,
            child: Text(
              l.tableHeaderSource,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderCell extends StatelessWidget {
  final String label;
  final String column;
  final String currentSort;
  final bool ascending;
  final ValueChanged<String> onSort;

  const _HeaderCell(
      this.label, this.column, this.currentSort, this.ascending, this.onSort);

  @override
  Widget build(BuildContext context) {
    final isActive = currentSort == column;
    return GestureDetector(
      onTap: () => onSort(column),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isActive ? AppColors.navy : AppColors.textSecondary,
            ),
          ),
          if (isActive) ...[
            const SizedBox(width: 2),
            Icon(
              ascending ? Icons.arrow_upward : Icons.arrow_downward,
              size: 12,
              color: AppColors.navy,
            ),
          ],
        ],
      ),
    );
  }
}

class RateTableRow extends StatelessWidget {
  final LeaseRate rate;
  final double? changeUsd;
  final bool isEven;

  const RateTableRow({
    super.key,
    required this.rate,
    this.changeUsd,
    this.isEven = false,
  });

  @override
  Widget build(BuildContext context) {
    Color? changeColor;
    String changeText = '-';
    if (changeUsd != null && changeUsd != 0) {
      changeColor = changeUsd! > 0 ? AppColors.error : AppColors.success;
      changeText = changeUsd! > 0
          ? '+\$${changeUsd!.toStringAsFixed(0)}'
          : '-\$${changeUsd!.abs().toStringAsFixed(0)}';
    } else if (changeUsd == 0) {
      changeText = '0';
    }

    return Container(
      color: isEven ? AppColors.backgroundLight : Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  rate.zoneName,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.navy,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '${rate.province} · ${rate.assetTypeLabel}',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '\$${rate.priceUsd.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.navy,
                  ),
                ),
                Text(
                  DateFormat('MM/yyyy').format(rate.recordedMonth),
                  style: const TextStyle(
                      fontSize: 10, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Row(
              children: [
                if (changeUsd != null && changeUsd != 0)
                  Icon(
                    changeUsd! > 0 ? Icons.arrow_upward : Icons.arrow_downward,
                    size: 12,
                    color: changeColor,
                  ),
                Text(
                  changeText,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: changeColor ?? AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.navy.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                rate.source,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: AppColors.navy,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
