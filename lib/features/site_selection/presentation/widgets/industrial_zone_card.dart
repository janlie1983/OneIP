import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/models/industrial_zone_model.dart';
import '../providers/site_selection_provider.dart';

class IndustrialZoneCard extends ConsumerWidget {
  final IndustrialZone zone;
  final double score;
  final VoidCallback onTap;
  final int animationIndex;

  const IndustrialZoneCard({
    super.key,
    required this.zone,
    required this.score,
    required this.onTap,
    this.animationIndex = 0,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final compareZones = ref.watch(compareZonesProvider);
    final isComparing = compareZones.any((z) => z.id == zone.id);

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 350 + animationIndex * 80),
      curve: Curves.easeOut,
      builder: (context, value, child) => Opacity(
        opacity: value,
        child: Transform.translate(
          offset: Offset(0, (1 - value) * 24),
          child: child,
        ),
      ),
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context, ref, isComparing, compareZones),
                const SizedBox(height: 12),
                _buildScoreBars(),
                const SizedBox(height: 12),
                _buildStatsRow(),
                const SizedBox(height: 10),
                _buildIndustriesRow(),
                const SizedBox(height: 12),
                _buildFooter(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, WidgetRef ref, bool isComparing,
      List<IndustrialZone> compareZones) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                zone.name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.navy,
                ),
              ),
              const SizedBox(height: 4),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: [
                  _Badge(label: zone.province, color: AppColors.navy),
                  _Badge(label: _regionLabel(zone.region), color: AppColors.textSecondary),
                  if ((zone.taxIncentiveYears ?? 0) >= 10)
                    _TaxBadge(years: zone.taxIncentiveYears!),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        _ScoreCircle(score: score),
        const SizedBox(width: 4),
        _CompareButton(
          isComparing: isComparing,
          onTap: () {
            final notifier = ref.read(compareZonesProvider.notifier);
            if (isComparing) {
              notifier.state = compareZones.where((z) => z.id != zone.id).toList();
            } else if (compareZones.length < 3) {
              notifier.state = [...compareZones, zone];
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Tối đa 3 khu để so sánh'),
                  backgroundColor: AppColors.warning,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          },
        ),
      ],
    );
  }

  Widget _buildScoreBars() {
    return Column(
      children: [
        _ScoreBar(label: 'Hạ tầng', value: zone.infraScore ?? 0, color: AppColors.navy),
        const SizedBox(height: 5),
        _ScoreBar(label: 'Lao động', value: zone.laborScore ?? 0, color: AppColors.gold),
        const SizedBox(height: 5),
        _ScoreBar(label: 'Logistics', value: zone.logisticsScore ?? 0, color: AppColors.info),
      ],
    );
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        _StatChip(
          icon: Icons.attach_money,
          label: zone.leasePriceUsd != null
              ? '\$${zone.leasePriceUsd!.toStringAsFixed(0)}/m²/n'
              : 'Liên hệ',
        ),
        const SizedBox(width: 6),
        _StatChip(
          icon: Icons.crop_square,
          label: zone.availableAreaHa != null
              ? '${zone.availableAreaHa!.toStringAsFixed(0)} ha'
              : '-',
        ),
        const SizedBox(width: 6),
        _StatChip(
          icon: Icons.directions_boat,
          label: zone.distanceToSeaportKm != null
              ? '${zone.distanceToSeaportKm!.toStringAsFixed(0)} km'
              : '-',
        ),
      ],
    );
  }

  Widget _buildIndustriesRow() {
    if (zone.industriesSupported.isEmpty) return const SizedBox.shrink();
    return SizedBox(
      height: 26,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: zone.industriesSupported.length,
        separatorBuilder: (_, _) => const SizedBox(width: 6),
        itemBuilder: (context, i) => Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.backgroundLight,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.border),
          ),
          child: Text(
            zone.industriesSupported[i],
            style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
          ),
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Row(
      children: [
        if (zone.developer != null)
          Expanded(
            child: Text(
              zone.developer!,
              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        TextButton(
          onPressed: onTap,
          style: TextButton.styleFrom(
            foregroundColor: AppColors.navy,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Xem chi tiết', style: TextStyle(fontSize: 13)),
              SizedBox(width: 4),
              Icon(Icons.arrow_forward_ios, size: 11),
            ],
          ),
        ),
      ],
    );
  }

  String _regionLabel(String region) {
    switch (region) {
      case 'North':
        return 'Miền Bắc';
      case 'Central':
        return 'Miền Trung';
      case 'South':
        return 'Miền Nam';
      default:
        return region;
    }
  }
}

// ── Sub-widgets ───────────────────────────────────────────────────────────────

class _Badge extends StatelessWidget {
  final String label;
  final Color color;
  const _Badge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w500),
      ),
    );
  }
}

class _TaxBadge extends StatelessWidget {
  final int years;
  const _TaxBadge({required this.years});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.gold.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.gold, width: 0.8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star, size: 10, color: AppColors.gold),
          const SizedBox(width: 3),
          Text(
            'UT ${years}n',
            style: const TextStyle(
              fontSize: 10,
              color: AppColors.gold,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _ScoreCircle extends StatelessWidget {
  final double score;
  const _ScoreCircle({required this.score});

  @override
  Widget build(BuildContext context) {
    final color = score >= 7
        ? AppColors.success
        : score >= 5
            ? AppColors.warning
            : AppColors.error;

    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: 52,
          height: 52,
          child: CircularProgressIndicator(
            value: score / 10,
            strokeWidth: 5,
            backgroundColor: AppColors.border,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              score.toStringAsFixed(1),
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
            const Text('/10', style: TextStyle(fontSize: 9, color: AppColors.textSecondary)),
          ],
        ),
      ],
    );
  }
}

class _CompareButton extends StatelessWidget {
  final bool isComparing;
  final VoidCallback onTap;
  const _CompareButton({required this.isComparing, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: isComparing
              ? AppColors.gold.withValues(alpha: 0.15)
              : AppColors.backgroundLight,
          shape: BoxShape.circle,
          border: Border.all(
            color: isComparing ? AppColors.gold : AppColors.border,
          ),
        ),
        child: Icon(
          isComparing ? Icons.compare_arrows : Icons.add,
          size: 16,
          color: isComparing ? AppColors.gold : AppColors.textSecondary,
        ),
      ),
    );
  }
}

class _ScoreBar extends StatelessWidget {
  final String label;
  final int value;
  final Color color;

  const _ScoreBar({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 58,
          child: Text(
            label,
            style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
          ),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: value / 10,
              backgroundColor: AppColors.border,
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 6,
            ),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          '$value',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _StatChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.backgroundLight,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 12, color: AppColors.navy),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.navy,
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
