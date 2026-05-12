import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../domain/models/listing_model.dart';

class AssetTypeTabs extends ConsumerWidget {
  final List<Listing> listings;
  final String? selected;
  final ValueChanged<String?> onSelected;

  const AssetTypeTabs({
    super.key,
    required this.listings,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tabs = [
      _TabItem(null, 'Tất cả', Icons.apps, listings.length),
      _TabItem('rbf', 'Nhà xưởng', Icons.factory,
          listings.where((l) => l.assetType == 'rbf').length),
      _TabItem('rbw', 'Kho', Icons.warehouse,
          listings.where((l) => l.assetType == 'rbw').length),
      _TabItem('land', 'Đất KCN', Icons.landscape,
          listings.where((l) => l.assetType == 'land').length),
      _TabItem('office', 'Văn phòng', Icons.business,
          listings.where((l) => l.assetType == 'office').length),
    ];

    return Container(
      color: Colors.white,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: tabs
              .map((tab) => _Tab(
                    item: tab,
                    isSelected: selected == tab.type,
                    onTap: () => onSelected(tab.type),
                  ))
              .toList(),
        ),
      ),
    );
  }
}

class _TabItem {
  final String? type;
  final String label;
  final IconData icon;
  final int count;
  const _TabItem(this.type, this.label, this.icon, this.count);
}

class _Tab extends StatelessWidget {
  final _TabItem item;
  final bool isSelected;
  final VoidCallback onTap;

  const _Tab({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isSelected ? AppColors.gold : Colors.transparent,
              width: 2.5,
            ),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              item.icon,
              size: 16,
              color: isSelected ? AppColors.navy : AppColors.textSecondary,
            ),
            const SizedBox(width: 6),
            Text(
              item.label,
              style: TextStyle(
                fontSize: 13,
                fontWeight:
                    isSelected ? FontWeight.w700 : FontWeight.w400,
                color: isSelected ? AppColors.navy : AppColors.textSecondary,
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.navy
                    : AppColors.border,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '${item.count}',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
