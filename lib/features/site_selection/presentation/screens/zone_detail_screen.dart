import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/models/industrial_zone_model.dart';
import '../providers/site_selection_provider.dart';

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
    setState(() => _savingLead = true);
    try {
      final repo = ref.read(siteSelectionRepositoryProvider);
      final user = ref.read(currentUserProvider);
      await repo.saveContactLead(user?.id, zone);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Yêu cầu tư vấn đã được ghi nhận!'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Không thể gửi yêu cầu. Vui lòng thử lại.'),
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
          title: const Text('Chi tiết KCN'),
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
          _buildSliverAppBar(context, zone, isComparing, compareZones),
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
      bottomNavigationBar: _buildBottomBar(context, zone),
    );
  }

  Widget _buildSliverAppBar(
    BuildContext context,
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
                const SnackBar(
                  content: Text('Đã bỏ khỏi danh sách so sánh'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            } else if (compareZones.length < 3) {
              notifier.state = [...compareZones, zone];
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Đã thêm vào so sánh'),
                  behavior: SnackBarBehavior.floating,
                  action: SnackBarAction(
                    label: 'Xem so sánh',
                    onPressed: () => context.push('/zone-compare'),
                  ),
                ),
              );
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
          icon: Icon(
            isComparing ? Icons.compare_arrows : Icons.add_chart_outlined,
            color: isComparing ? AppColors.gold : Colors.white,
          ),
          tooltip: isComparing ? 'Bỏ so sánh' : 'Thêm so sánh',
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: _buildHeroImage(zone),
      ),
    );
  }

  Widget _buildHeroImage(IndustrialZone zone) {
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
                '${zone.developer ?? ''} • ${zone.establishedYear != null ? 'Thành lập ${zone.establishedYear}' : ''}',
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

  Widget _buildBottomBar(BuildContext context, IndustrialZone zone) {
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
          label: const Text('Liên hệ tư vấn'),
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
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _InfoSection(
            title: 'Thông tin chung',
            rows: [
              _InfoRow('Tỉnh/Thành phố', zone.province),
              _InfoRow('Vùng', _regionLabel(zone.region)),
              _InfoRow('Chủ đầu tư', zone.developer ?? '-'),
              _InfoRow('Quốc tịch CĐT', zone.developerNationality ?? '-'),
              _InfoRow('Tổng diện tích', zone.totalAreaHa != null ? '${zone.totalAreaHa} ha' : '-'),
              _InfoRow('Diện tích còn trống', zone.availableAreaHa != null ? '${zone.availableAreaHa} ha' : '-'),
              _InfoRow('Tỷ lệ lấp đầy', zone.occupancyRate != null ? '${zone.occupancyRate!.toStringAsFixed(0)}%' : '-'),
              _InfoRow('Diện tích thuê tối thiểu', zone.minLeaseAreaM2 != null ? '${zone.minLeaseAreaM2!.toStringAsFixed(0)} m²' : '-'),
            ],
          ),
          const SizedBox(height: 12),
          _InfoSection(
            title: 'Giá & Ưu đãi',
            rows: [
              _InfoRow('Giá thuê đất', zone.leasePriceUsd != null ? '\$${zone.leasePriceUsd}/m²/năm' : 'Liên hệ'),
              _InfoRow('Phí dịch vụ', zone.serviceFeeUsd != null ? '\$${zone.serviceFeeUsd}/m²/tháng' : '-'),
              _InfoRow('Ưu đãi thuế', zone.taxIncentiveYears != null ? '${zone.taxIncentiveYears} năm' : '-'),
              _InfoRow('Thuế suất ưu đãi', zone.taxIncentiveRate != null ? '${zone.taxIncentiveRate}%' : '-'),
            ],
          ),
          const SizedBox(height: 12),
          _IndustriesSection(industries: zone.industriesSupported),
          const SizedBox(height: 12),
          if (zone.contactEmail != null || zone.website != null)
            _InfoSection(
              title: 'Liên hệ',
              rows: [
                if (zone.contactEmail != null) _InfoRow('Email', zone.contactEmail!),
                if (zone.website != null) _InfoRow('Website', zone.website!),
              ],
            ),
        ],
      ),
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

// ── Tab 2: Infrastructure ─────────────────────────────────────────────────────

class _InfrastructureTab extends StatelessWidget {
  final IndustrialZone zone;
  const _InfrastructureTab({required this.zone});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _ScoresSection(zone: zone),
          const SizedBox(height: 12),
          _InfoSection(
            title: 'Tiện ích',
            rows: [
              _InfoRow('Điện', zone.utilitiesPowerKv ?? 'Có sẵn'),
              _InfoRow('Nước sạch', zone.utilitiesWater ? '✓ Có sẵn' : '✗ Không có'),
              _InfoRow('Xử lý nước thải', zone.utilitiesWastewater ? '✓ Có sẵn' : '✗ Không có'),
              _InfoRow('Internet cáp quang', zone.fiberInternet ? '✓ Có sẵn' : '✗ Không có'),
            ],
          ),
          if (zone.certifications.isNotEmpty) ...[
            const SizedBox(height: 12),
            _CertificationsSection(certifications: zone.certifications),
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
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _InfoSection(
            title: 'Khoảng cách vận chuyển',
            rows: [
              _InfoRow('Đến cảng biển gần nhất', zone.distanceToSeaportKm != null ? '${zone.distanceToSeaportKm} km' : '-'),
              _InfoRow('Đến sân bay gần nhất', zone.distanceToAirportKm != null ? '${zone.distanceToAirportKm} km' : '-'),
              _InfoRow('Đến Hà Nội', zone.distanceToHanoiKm != null ? '${zone.distanceToHanoiKm} km' : '-'),
              _InfoRow('Đến TP.HCM', zone.distanceToHcmKm != null ? '${zone.distanceToHcmKm} km' : '-'),
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
          const Text(
            'Điểm đánh giá',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.navy),
          ),
          const SizedBox(height: 16),
          _ScoreBarDetail(
            label: 'Hạ tầng',
            value: zone.infraScore ?? 0,
            color: AppColors.navy,
            description: 'Đường sá, điện nước, viễn thông',
          ),
          const SizedBox(height: 12),
          _ScoreBarDetail(
            label: 'Lao động',
            value: zone.laborScore ?? 0,
            color: AppColors.gold,
            description: 'Nguồn lao động, tay nghề khu vực',
          ),
          const SizedBox(height: 12),
          _ScoreBarDetail(
            label: 'Logistics',
            value: zone.logisticsScore ?? 0,
            color: AppColors.info,
            description: 'Cảng biển, sân bay, giao thông',
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
  final List<String> industries;
  const _IndustriesSection({required this.industries});

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
          const Text(
            'Ngành công nghiệp phù hợp',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.navy),
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
  final List<String> certifications;
  const _CertificationsSection({required this.certifications});

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
          const Text(
            'Chứng nhận',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.navy),
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
            const Text(
              'Bản đồ sẽ được cập nhật',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
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
          const Text(
            'Đánh giá Logistics',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.navy),
          ),
          const SizedBox(height: 12),
          _LogisticsItem(
            icon: Icons.directions_boat,
            label: 'Kết nối cảng biển',
            description: zone.distanceToSeaportKm != null
                ? '${zone.distanceToSeaportKm} km đến cảng gần nhất'
                : 'Không có thông tin',
            isGood: (zone.distanceToSeaportKm ?? 999) < 50,
          ),
          _LogisticsItem(
            icon: Icons.flight,
            label: 'Kết nối sân bay',
            description: zone.distanceToAirportKm != null
                ? '${zone.distanceToAirportKm} km đến sân bay'
                : 'Không có thông tin',
            isGood: (zone.distanceToAirportKm ?? 999) < 60,
          ),
          _LogisticsItem(
            icon: Icons.score,
            label: 'Điểm Logistics tổng thể',
            description: 'Dựa trên đánh giá tổng hợp',
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
    return Container(
      color: Colors.white,
      child: TabBar(
        controller: tabController,
        labelColor: AppColors.navy,
        unselectedLabelColor: AppColors.textSecondary,
        indicatorColor: AppColors.navy,
        tabs: const [
          Tab(text: 'Tổng quan'),
          Tab(text: 'Hạ tầng & Tiện ích'),
          Tab(text: 'Vị trí & Logistics'),
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
