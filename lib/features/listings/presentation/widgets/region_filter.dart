import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../domain/models/listing_model.dart';

class RegionFilter extends StatelessWidget {
  final List<Listing> listings;
  final String? selected;
  final ValueChanged<String?> onSelected;

  const RegionFilter({
    super.key,
    required this.listings,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final regions = [
      _RegionItem(null, 'Tất cả', listings.length),
      _RegionItem('North', 'Miền Bắc',
          listings.where((l) => l.region == 'North').length),
      _RegionItem('Central', 'Miền Trung',
          listings.where((l) => l.region == 'Central').length),
      _RegionItem('South', 'Miền Nam',
          listings.where((l) => l.region == 'South').length),
    ];

    return Container(
      color: AppColors.backgroundLight,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: regions
              .map((r) => _RegionChip(
                    item: r,
                    isSelected: selected == r.region,
                    onTap: () => onSelected(r.region),
                  ))
              .toList(),
        ),
      ),
    );
  }
}

class _RegionItem {
  final String? region;
  final String label;
  final int count;
  const _RegionItem(this.region, this.label, this.count);
}

class _RegionChip extends StatelessWidget {
  final _RegionItem item;
  final bool isSelected;
  final VoidCallback onTap;

  const _RegionChip({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.navy : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.navy : AppColors.border,
          ),
        ),
        child: Text(
          '${item.label} (${item.count})',
          style: TextStyle(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            color: isSelected ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
