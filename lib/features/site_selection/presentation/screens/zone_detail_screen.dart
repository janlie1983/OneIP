import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/models/industrial_zone_model.dart';
import '../providers/site_selection_provider.dart';

String _regionLabel(AppLocalizations l, String region) {
  switch (region) {
    case 'North':
      return l.regionNorth;
    case 'Central':
      return l.regionCentral;
    case 'South':
      return l.regionSouth;
    default:
      return region;
  }
}

class ZoneDetailScreen extends ConsumerStatefulWidget {
  final String zoneId;
  final IndustrialZone? zone;

  const ZoneDetailScreen({
    super.key,
    required this.zoneId,
    this.zone,
  });

  @override
  ConsumerState<ZoneDetailScreen> createState() => _ZoneDetailScreenState();
}

class _ZoneDetailScreenState extends ConsumerState<ZoneDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _savingLead = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _saveContactLead(IndustrialZone zone) async {
    final l = AppLocalizations.of(context)!;
    setState(() => _savingLead = true);
    try {
      final repo = ref.read(siteSelectionRepositoryProvider);
      final user = ref.read(currentUserProvider);
      await repo.saveContactLead(user?.id, zone);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l.contactLeadSuccess),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (_) {
      if (mounted) {
        final l2 = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l2.contactLeadError),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _savingLead = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final zone = widget.zone ?? ref.watch(zoneByIdProvider(widget.zoneId));

    if (zone == null) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.navy,
          foregroundColor: Colors.white,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            onPressed: () => context.pop(),
          ),
          title: Text(l.zoneDetailTitle),
        ),
        body: const Center(child: CircularProgressIndicator(color: AppColors.navy)),
      );
    }

    final compareZones = ref.watch(compareZonesProvider);
    final isComparing = compareZones.any((z) => z.id == zone.id);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          _buildSliverAppBar(context, l, zone, isComparing, compareZones),
          SliverPersistentHeader(
            pinned: true,
            delegate: _TabBarDelegate(tabController: _tabController),
          ),
        ],
        body: TabBarView(
          controller: _tabController,
          children: [
            _OverviewTab(zone: zone),
            _InfrastructureTab(zone: zone),
            _LocationTab(zone: zone),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomBar(context, l, zone),
    );
  }

  Widget _buildSliverAppBar(
    BuildContext context,
    AppLocalizations l,
    IndustrialZone zone,
    bool isComparing,
    List<IndustrialZone> compareZones,
  ) {
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      backgroundColor: AppColors.navy,
      foregroundColor: Colors.white,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios),
        onPressed: () => context.pop(),
      ),
      actions: [
        IconButton(
          onPressed: () {
            final notifier = ref.read(compareZonesProvider.notifier);
            if (isComparing) {
              notifier.state = compareZones.where((z) => z.id != zone.id).toList();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(l.compareRemovedMessage),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            } else if (compareZones.length < 3) {
              notifier.state = [...compareZones, zone];
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(l.compareAddedMessage),
                  behavior: SnackBarBehavior.floating,
                  action: SnackBarAction(
                    label: l.compareViewAction,
                    onPressed: () => context.push('/zone-compare'),
                  ),
                ),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(l.compareMaxZones),
                  backgroundColor: AppColors.warning,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          },
          icon: Icon(
            isComparing ? Icons.compare_arrows : Icons.add_chart_outlined,
            color: isComparing ? AppColors.gold : Colors.white,
          ),
          tooltip: isComparing ? l.compareRemoveTooltip : l.compareAddTooltip,
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: _buildHeroImage(l, zone),
      ),
    );
  }

  Widget _buildHeroImage(AppLocalizations l, IndustrialZone zone) {
    return Stack(
      fit: StackFit.expand,
      children: [
        if (zone.imageUrl != null)
          Image.network(
            zone.imageUrl!,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => _gradientPlaceholder(),
          )
        else
          _gradientPlaceholder(),
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.transparent, Colors.black54],
            ),
          ),
        ),
        Positioned(
          left: 16,
          bottom: 16,
          right: 80,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                zone.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  shadows: [Shadow(blurRadius: 4, color: Colors.black38)],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                [
                  if (zone.developer != null) zone.developer!,
                  if (zone.establishedYear != null)
                    l.zoneEstablishedYear(zone.establishedYear!),
                ].join(' • '),
                style: const TextStyle(color: Colors.white70, fontSize: 13),
              ),
            ],
          ),
        ),
        Positioned(
          right: 16,
          bottom: 16,
          child: _LargeScoreCircle(score: zone.overallScore),
        ),
      ],
    );
  }

  Widget _gradientPlaceholder() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.navy, Color(0xFF2C4A7A)],
        ),
      ),
      child: const Center(
        child: Icon(Icons.location_city, size: 80, color: Colors.white24),
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context, AppLocalizations l, IndustrialZone zone) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        child: ElevatedButton.icon(
          onPressed: _savingLead ? null : () => _saveContactLead(zone),
          icon: _savingLead
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : const Icon(Icons.support_agent, size: 20),
          label: Text(l.siteSelectionContact),
        ),
      ),
    );
  }
}

// ── Tab 1: Overview ────────────────────────────────────────────────────────────

class _OverviewTab extends StatelessWidget {
  final IndustrialZone zone;
  const _OverviewTab({required this.zone});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _InfoSection(
            title: l.zoneGeneralInfo,
            rows: [
              _InfoRow(l.zoneProvinceLabel, zone.province),
              _InfoRow(l.zoneRegionLabel, _regionLabel(l, zone.region)),
              _InfoRow(l.zoneDeveloperLabel, zone.developer ?? '-'),
              _InfoRow(l.zoneDeveloperNationalityLabel, zone.developerNationality ?? '-'),
              _InfoRow(l.zoneTotalAreaLabel, zone.totalAreaHa != null ? '${zone.totalAreaHa} ha' : '-'),
              _InfoRow(l.zoneAvailableAreaLabel, zone.availableAreaHa != null ? '${zone.availableAreaHa} ha' : '-'),
              _InfoRow(l.zoneOccupancyLabel, zone.occupancyRate != null ? '${zone.occupancyRate!.toStringAsFixed(0)}%' : '-'),
              _InfoRow(l.zoneMinLeaseAreaLabel, zone.minLeaseAreaM2 != null ? '${zone.minLeaseAreaM2!.toStringAsFixed(0)} m²' : '-'),
            ],
          ),
          const SizedBox(height: 12),
          _InfoSection(
            title: l.zonePriceIncentives,
            rows: [
              _InfoRow(l.zoneLeasePriceLabel, zone.leasePriceUsd != null ? '\$${zone.leasePriceUsd}/m²/năm' : l.commonContact),
              _InfoRow(l.zoneServiceFeeLabel, zone.serviceFeeUsd != null ? '\$${zone.serviceFeeUsd}/m²/tháng' : '-'),
              _InfoRow(l.zoneTaxIncentiveLabel, zone.taxIncentiveYears != null ? '${zone.taxIncentiveYears} năm' : '-'),
              _InfoRow(l.zoneTaxRateLabel, zone.taxIncentiveRate != null ? '${zone.taxIncentiveRate}%' : '-'),
            ],
          ),
          const SizedBox(height: 12),
          _IndustriesSection(title: l.zoneIndustriesTitle, industries: zone.industriesSupported),
          const SizedBox(height: 12),
          if (zone.contactEmail != null || zone.website != null)
            _InfoSection(
              title: l.zoneContactSection,
              rows: [
                if (zone.contactEmail != null) _InfoRow(l.zoneEmailLabel, zone.contactEmail!),
                if (zone.website != null) _InfoRow(l.zoneWebsiteLabel, zone.website!),
              ],
            ),
        ],
      ),
    );
  }
}

// ── Tab 2: Infrastructure ─────────────────────────────────────────────────────

class _InfrastructureTab extends StatelessWidget {
  final IndustrialZone zone;
  const _InfrastructureTab({required this.zone});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _ScoresSection(zone: zone),
          const SizedBox(height: 12),
          _InfoSection(
            title: l.zoneUtilitiesTitle,
            rows: [
              _InfoRow(l.zoneUtilitiesPower, zone.utilitiesPowerKv ?? l.commonAvailable),
              _InfoRow(l.zoneUtilitiesWater, zone.utilitiesWater ? '✓ ${l.commonAvailable}' : '✗ ${l.commonNotAvailable}'),
              _InfoRow(l.zoneUtilitiesWastewater, zone.utilitiesWastewater ? '✓ ${l.commonAvailable}' : '✗ ${l.commonNotAvailable}'),
              _InfoRow(l.zoneUtilitiesFiber, zone.fiberInternet ? '✓ ${l.commonAvailable}' : '✗ ${l.commonNotAvailable}'),
            ],
          ),
          if (zone.certifications.isNotEmpty) ...[
            const SizedBox(height: 12),
            _CertificationsSection(title: l.zoneCertificationsTitle, certifications: zone.certifications),
          ],
        ],
      ),
    );
  }
}

// ── Tab 3: Location ───────────────────────────────────────────────────────────

class _LocationTab extends StatelessWidget {
  final IndustrialZone zone;
  const _LocationTab({required this.zone});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _InfoSection(
            title: l.zoneDistancesTitle,
            rows: [
              _InfoRow(l.zoneSeaportDistLabel, zone.distanceToSeaportKm != null ? '${zone.distanceToSeaportKm} km' : '-'),
              _InfoRow(l.zoneAirportDistLabel, zone.distanceToAirportKm != null ? '${zone.distanceToAirportKm} km' : '-'),
              _InfoRow(l.zoneHanoiLabel, zone.distanceToHanoiKm != null ? '${zone.distanceToHanoiKm} km' : '-'),
              _InfoRow(l.zoneHcmLabel, zone.distanceToHcmKm != null ? '${zone.distanceToHcmKm} km' : '-'),
            ],
          ),
          const SizedBox(height: 12),
          _MapPlaceholder(zone: zone),
          const SizedBox(height: 12),
          _LogisticsScore(zone: zone),
        ],
      ),
    );
  }
}

// ── Reusable section widgets ──────────────────────────────────────────────────

class _InfoSection extends StatelessWidget {
  final String title;
  final List<_InfoRow> rows;

  const _InfoSection({required this.title, required this.rows});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.navy,
            ),
          ),
          const SizedBox(height: 12),
          ...rows,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: Text(
              label,
              style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.navy,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ScoresSection extends StatelessWidget {
  final IndustrialZone zone;
  const _ScoresSection({required this.zone});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l.zoneScoresTitle,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.navy),
          ),
          const SizedBox(height: 16),
          _ScoreBarDetail(
            label: l.zoneInfraScore,
            value: zone.infraScore ?? 0,
            color: AppColors.navy,
            description: l.zoneInfraDesc,
          ),
          const SizedBox(height: 12),
          _ScoreBarDetail(
            label: l.zoneLaborScore,
            value: zone.laborScore ?? 0,
            color: AppColors.gold,
            description: l.zoneLaborDesc,
          ),
          const SizedBox(height: 12),
          _ScoreBarDetail(
            label: l.zoneLogisticsScore,
            value: zone.logisticsScore ?? 0,
            color: AppColors.info,
            description: l.zoneLogisticsDesc,
          ),
        ],
      ),
    );
  }
}

class _ScoreBarDetail extends StatelessWidget {
  final String label;
  final int value;
  final Color color;
  final String description;

  const _ScoreBarDetail({
    required this.label,
    required this.value,
    required this.color,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: color),
            ),
            const Spacer(),
            Text(
              '$value/10',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: color),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(description, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: value / 10,
            backgroundColor: AppColors.border,
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 8,
          ),
        ),
      ],
    );
  }
}

class _IndustriesSection extends StatelessWidget {
  final String title;
  final List<String> industries;
  const _IndustriesSection({required this.title, required this.industries});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.navy),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: industries
                .map((industry) => Chip(
                      label: Text(industry, style: const TextStyle(fontSize: 12)),
                      backgroundColor: AppColors.navy.withValues(alpha: 0.08),
                      side: const BorderSide(color: AppColors.border),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _CertificationsSection extends StatelessWidget {
  final String title;
  final List<String> certifications;
  const _CertificationsSection({required this.title, required this.certifications});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.navy),
          ),
          const SizedBox(height: 12),
          ...certifications.map((cert) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    const Icon(Icons.verified, size: 16, color: AppColors.success),
                    const SizedBox(width: 8),
                    Text(cert, style: const TextStyle(fontSize: 13, color: AppColors.navy)),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}

class _MapPlaceholder extends StatelessWidget {
  final IndustrialZone zone;
  const _MapPlaceholder({required this.zone});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Container(
      height: 180,
      decoration: BoxDecoration(
        color: const Color(0xFFE8EDF2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.map_outlined, size: 48, color: AppColors.textSecondary),
            const SizedBox(height: 8),
            Text(
              zone.province,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.navy,
              ),
            ),
            Text(
              l.zoneMapComingSoon,
              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

class _LogisticsScore extends StatelessWidget {
  final IndustrialZone zone;
  const _LogisticsScore({required this.zone});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l.zoneLogisticsTitle,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.navy),
          ),
          const SizedBox(height: 12),
          _LogisticsItem(
            icon: Icons.directions_boat,
            label: l.zoneSeaportConnection,
            description: zone.distanceToSeaportKm != null
                ? l.zoneSeaportKmDesc(zone.distanceToSeaportKm!.toStringAsFixed(0))
                : l.zoneNoInfo,
            isGood: (zone.distanceToSeaportKm ?? 999) < 50,
          ),
          _LogisticsItem(
            icon: Icons.flight,
            label: l.zoneAirportConnection,
            description: zone.distanceToAirportKm != null
                ? l.zoneAirportKmDesc(zone.distanceToAirportKm!.toStringAsFixed(0))
                : l.zoneNoInfo,
            isGood: (zone.distanceToAirportKm ?? 999) < 60,
          ),
          _LogisticsItem(
            icon: Icons.score,
            label: l.zoneLogisticsOverall,
            description: l.zoneLogisticsOverallDesc,
            isGood: (zone.logisticsScore ?? 0) >= 7,
          ),
        ],
      ),
    );
  }
}

class _LogisticsItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String description;
  final bool isGood;

  const _LogisticsItem({
    required this.icon,
    required this.label,
    required this.description,
    required this.isGood,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: (isGood ? AppColors.success : AppColors.textSecondary).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 18,
              color: isGood ? AppColors.success : AppColors.textSecondary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.navy)),
                Text(description, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              ],
            ),
          ),
          Icon(
            isGood ? Icons.check_circle : Icons.radio_button_unchecked,
            size: 18,
            color: isGood ? AppColors.success : AppColors.border,
          ),
        ],
      ),
    );
  }
}

class _LargeScoreCircle extends StatelessWidget {
  final double score;
  const _LargeScoreCircle({required this.score});

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
          width: 64,
          height: 64,
          child: CircularProgressIndicator(
            value: score / 10,
            strokeWidth: 6,
            backgroundColor: Colors.white24,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              score.toStringAsFixed(1),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
            const Text('/10', style: TextStyle(fontSize: 10, color: Colors.white70)),
          ],
        ),
      ],
    );
  }
}

class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabController tabController;

  _TabBarDelegate({required this.tabController});

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    final l = AppLocalizations.of(context)!;
    return Container(
      color: Colors.white,
      child: TabBar(
        controller: tabController,
        labelColor: AppColors.navy,
        unselectedLabelColor: AppColors.textSecondary,
        indicatorColor: AppColors.navy,
        tabs: [
          Tab(text: l.tabOverview),
          Tab(text: l.tabInfraUtilities),
          Tab(text: l.tabLocationLogistics),
        ],
      ),
    );
  }

  @override
  double get maxExtent => kTextTabBarHeight;

  @override
  double get minExtent => kTextTabBarHeight;

  @override
  bool shouldRebuild(covariant _TabBarDelegate oldDelegate) => false;
}
