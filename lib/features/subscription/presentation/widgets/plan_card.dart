import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/models/plan_model.dart';

class PlanCard extends StatelessWidget {
  final PlanModel plan;
  final bool isCurrentPlan;
  final bool isSelected;
  final bool isRecommended;
  final VoidCallback onSelect;

  const PlanCard({
    super.key,
    required this.plan,
    required this.isCurrentPlan,
    required this.isSelected,
    required this.onSelect,
    this.isRecommended = false,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor = isSelected || isRecommended
        ? AppColors.gold
        : AppColors.border;
    final bgColor = isSelected
        ? AppColors.navy.withValues(alpha: 0.04)
        : Colors.white;

    return GestureDetector(
      onTap: onSelect,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        width: 200,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: borderColor,
            width: isSelected || isRecommended ? 2 : 1,
          ),
          boxShadow: isRecommended
              ? [
                  BoxShadow(
                    color: AppColors.gold.withValues(alpha: 0.15),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isRecommended) _PopularBadge(),
            if (!isRecommended) const SizedBox(height: 22),
            const SizedBox(height: 8),
            Text(
              plan.name.toUpperCase(),
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
                color: isRecommended ? AppColors.gold : AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              plan.priceLabel,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.navy,
              ),
            ),
            if (!plan.isFree)
              Text(
                plan.priceLabelVnd,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),
            ...plan.featuresVi.take(5).map(
                  (f) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.check_circle_rounded,
                          size: 14,
                          color: isRecommended ? AppColors.gold : AppColors.navy,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            f,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: isCurrentPlan
                  ? OutlinedButton(
                      onPressed: null,
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.border),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                      child: const Text(
                        'Gói hiện tại',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    )
                  : ElevatedButton(
                      onPressed: onSelect,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isRecommended
                            ? AppColors.gold
                            : AppColors.navy,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        elevation: 0,
                      ),
                      child: Text(
                        isSelected ? 'Đã chọn' : 'Chọn gói',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PopularBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.gold,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Text(
        'Phổ biến nhất',
        style: TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
