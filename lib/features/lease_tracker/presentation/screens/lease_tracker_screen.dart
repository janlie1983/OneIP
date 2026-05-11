import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/paywall_gate.dart';
import '../providers/lease_tracker_provider.dart';
import '../widgets/alert_card.dart';
import '../widgets/market_insight_card.dart';
import '../widgets/market_stat_card.dart';
import '../widgets/rate_chart_widget.dart';
import '../widgets/rate_table_row.dart';
import '../../domain/models/rate_alert_model.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

Map<String, String> _buildRegionMap(AppLocalizations l) => {
  'All': l.regionAll,
  'North': l.regionNorth,
  'Central': l.regionCentral,
  'South': l.regionSouth,
};

Map<String, String> _buildAssetTypeMap(AppLocalizations l) => {
  'factory': l.assetFactory,
  'warehouse': l.assetWarehouse,
  'land': l.assetLand,
  'office': l.assetOffice,
};

String _assetTypeLabel(AppLocalizations l, String? key) {
  switch (key) {
    case 'factory': return l.assetFactory;
    case 'warehouse': return l.assetWarehouse;
    case 'land': return l.assetLand;
    case 'office': return l.assetOffice;
    default: return key ?? '';
  }
}

class LeaseTrackerScreen extends ConsumerStatefulWidget {
  const LeaseTrackerScreen({super.key});

  @override
  ConsumerState<LeaseTrackerScreen> createState() => _LeaseTrackerScreenState();
}

class _LeaseTrackerScreenState extends ConsumerState<LeaseTrackerScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    ref.invalidate(leaseRatesProvider);
    ref.invalidate(_allRatesProviderKey);
    ref.invalidate(marketInsightsProvider);
    ref.invalidate(userAlertsProvider);
    await Future.delayed(const Duration(milliseconds: 600));
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppColors.navy,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
        title: Text(
          l.leaseTrackerTitle,
          style: const TextStyle(
              color: Colors.white, fontSize: 17, fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _refresh,
          ),
        ],
        bottom: TabBar(
          controller: _tab,
          indicatorColor: AppColors.gold,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          tabs: [
            Tab(text: l.leaseTrackerMarket),
            Tab(text: l.leaseTrackerAlerts),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tab,
        children: [
          RefreshIndicator(
            onRefresh: _refresh,
            color: AppColors.navy,
            child: const _MarketTab(),
          ),
          const _AlertsTab(),
        ],
      ),
    );
  }
}

// ── Tab 1: Market ─────────────────────────────────────────────────────────────

class _MarketTab extends ConsumerStatefulWidget {
  const _MarketTab();

  @override
  ConsumerState<_MarketTab> createState() => _MarketTabState();
}

class _MarketTabState extends ConsumerState<_MarketTab> {
  String _sortColumn = 'price';
  bool _sortAscending = false;

  @override
  Widget build(BuildContext context) {
    final isPremium = ref.watch(isPremiumProvider);

    return CustomScrollView(
      slivers: [
        if (!isPremium) SliverToBoxAdapter(child: _FreeTierBanner()),
        SliverToBoxAdapter(child: _FilterBar()),
        SliverToBoxAdapter(child: _StatsSection()),
        SliverToBoxAdapter(
          child: PaywallGate(child: _ChartSection()),
        ),
        SliverToBoxAdapter(
          child: _PriceTableSection(
            sortColumn: _sortColumn,
            sortAscending: _sortAscending,
            onSort: (col) => setState(() {
              if (_sortColumn == col) {
                _sortAscending = !_sortAscending;
              } else {
                _sortColumn = col;
                _sortAscending = false;
              }
            }),
          ),
        ),
        SliverToBoxAdapter(child: _InsightsSection()),
        const SliverToBoxAdapter(child: SizedBox(height: 24)),
      ],
    );
  }
}

class _FreeTierBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.warning.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          const Icon(Icons.schedule, size: 18, color: AppColors.warning),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              l.leaseTrackerFreeDelay,
              style: const TextStyle(fontSize: 12, color: AppColors.navy),
            ),
          ),
          const SizedBox(width: 8),
          TextButton(
            onPressed: () {},
            style: TextButton.styleFrom(
              foregroundColor: AppColors.gold,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(l.leaseTrackerUpgrade,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}

class _FilterBar extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    final selectedRegion = ref.watch(selectedRegionProvider);
    final selectedAsset = ref.watch(selectedAssetTypeProvider);
    final regions = _buildRegionMap(l);
    final assetTypes = _buildAssetTypeMap(l);

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              l.leaseTrackerRegion,
              style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary),
            ),
          ),
          const SizedBox(height: 6),
          SizedBox(
            height: 36,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: regions.entries.map((e) {
                final isSelected = selectedRegion == e.key;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(e.value),
                    selected: isSelected,
                    onSelected: (_) => ref
                        .read(selectedRegionProvider.notifier)
                        .state = e.key,
                    selectedColor: AppColors.navy,
                    backgroundColor: AppColors.backgroundLight,
                    labelStyle: TextStyle(
                      fontSize: 12,
                      color: isSelected ? Colors.white : AppColors.textSecondary,
                    ),
                    side: BorderSide(
                        color: isSelected ? AppColors.navy : AppColors.border),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              l.leaseTrackerAssetType,
              style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary),
            ),
          ),
          const SizedBox(height: 6),
          SizedBox(
            height: 36,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: assetTypes.entries.map((e) {
                final isSelected = selectedAsset == e.key;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(e.value),
                    selected: isSelected,
                    onSelected: (_) {
                      ref.read(selectedAssetTypeProvider.notifier).state = e.key;
                      ref.read(selectedZoneProvider.notifier).state = null;
                    },
                    selectedColor: AppColors.gold,
                    backgroundColor: AppColors.backgroundLight,
                    labelStyle: TextStyle(
                      fontSize: 12,
                      color: isSelected ? Colors.white : AppColors.textSecondary,
                    ),
                    side: BorderSide(
                        color: isSelected ? AppColors.gold : AppColors.border),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatsSection extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    final statsAsync = ref.watch(marketStatsProvider);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l.leaseTrackerMarketOverview,
            style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.navy),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 130,
            child: statsAsync.when(
              loading: () => ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: 3,
                separatorBuilder: (_, _) => const SizedBox(width: 10),
                itemBuilder: (_, _) => const MarketStatCardSkeleton(),
              ),
              error: (_, _) => Center(
                child: Text(l.commonNoData,
                    style: const TextStyle(color: AppColors.textSecondary)),
              ),
              data: (statsList) => ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: statsList.length,
                separatorBuilder: (_, _) => const SizedBox(width: 10),
                itemBuilder: (_, i) =>
                    MarketStatCard(stats: statsList[i]),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChartSection extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    final selectedZone = ref.watch(selectedZoneProvider);
    final selectedAsset = ref.watch(selectedAssetTypeProvider);
    final historyAsync = ref.watch(rateHistoryProvider);
    final ratesAsync = ref.watch(leaseRatesProvider);

    final zones = ratesAsync.whenOrNull(
          data: (rates) =>
              rates.map((r) => r.zoneName).toSet().toList()..sort(),
        ) ??
        [];

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  l.leaseTrackerChart,
                  style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.navy),
                ),
              ),
              if (zones.isNotEmpty)
                DropdownButton<String>(
                  value: zones.contains(selectedZone) ? selectedZone : zones.first,
                  underline: const SizedBox(),
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.navy, fontWeight: FontWeight.w500),
                  isDense: true,
                  items: zones
                      .map((z) => DropdownMenuItem(value: z, child: Text(z)))
                      .toList(),
                  onChanged: (z) =>
                      ref.read(selectedZoneProvider.notifier).state = z,
                ),
            ],
          ),
          if (selectedZone != null)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                '${_assetTypeLabel(l, selectedAsset)} · $selectedZone',
                style: const TextStyle(
                    fontSize: 12, color: AppColors.textSecondary),
              ),
            ),
          const SizedBox(height: 16),
          SizedBox(
            height: 220,
            child: historyAsync.when(
              loading: () => const _ChartSkeleton(),
              error: (_, _) => Center(
                child: Text(l.commonNoData,
                    style: const TextStyle(color: AppColors.textSecondary)),
              ),
              data: (rates) => RateChartWidget(
                rates: rates,
                zoneName: selectedZone ?? '',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PriceTableSection extends ConsumerWidget {
  final String sortColumn;
  final bool sortAscending;
  final ValueChanged<String> onSort;

  const _PriceTableSection({
    required this.sortColumn,
    required this.sortAscending,
    required this.onSort,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    final currentRatesAsync = ref.watch(currentRatesProvider);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 14, 12, 8),
            child: Row(
              children: [
                Text(
                  l.leaseTrackerTable,
                  style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.navy),
                ),
                const Spacer(),
                currentRatesAsync.whenOrNull(
                      data: (rows) => Text(
                        l.leaseTrackerKcnCount(rows.length),
                        style: const TextStyle(
                            fontSize: 12, color: AppColors.textSecondary),
                      ),
                    ) ??
                    const SizedBox(),
              ],
            ),
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Column(
              children: [
                RateTableHeader(
                  sortColumn: sortColumn,
                  sortAscending: sortAscending,
                  onSort: onSort,
                ),
                currentRatesAsync.when(
                  loading: () => const _TableSkeleton(),
                  error: (_, _) => Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(l.commonNoData,
                        style: const TextStyle(color: AppColors.textSecondary)),
                  ),
                  data: (rows) {
                    final sorted = _sortRows([...rows], sortColumn, sortAscending);
                    return Column(
                      children: sorted.asMap().entries.map((entry) {
                        final item = entry.value;
                        return RateTableRow(
                          rate: item.current,
                          changeUsd: item.changeUsd,
                          isEven: entry.key.isEven,
                        );
                      }).toList(),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<ZoneCurrentRate> _sortRows(
      List<ZoneCurrentRate> rows, String col, bool asc) {
    rows.sort((a, b) {
      int cmp;
      switch (col) {
        case 'zone':
          cmp = a.current.zoneName.compareTo(b.current.zoneName);
        case 'price':
          cmp = a.current.priceUsd.compareTo(b.current.priceUsd);
        case 'change':
          cmp = (a.changeUsd ?? 0).compareTo(b.changeUsd ?? 0);
        default:
          cmp = 0;
      }
      return asc ? cmp : -cmp;
    });
    return rows;
  }
}

class _InsightsSection extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    final insightsAsync = ref.watch(marketInsightsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
          child: Text(
            l.leaseTrackerNews,
            style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.navy),
          ),
        ),
        insightsAsync.when(
          loading: () => const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: _InsightSkeleton(),
          ),
          error: (_, _) => Padding(
            padding: const EdgeInsets.all(16),
            child: Text(l.commonNoData,
                style: const TextStyle(color: AppColors.textSecondary)),
          ),
          data: (insights) => Column(
            children: insights
                .map((i) => MarketInsightCard(insight: i))
                .toList(),
          ),
        ),
      ],
    );
  }
}

// ── Tab 2: Alerts ─────────────────────────────────────────────────────────────

class _AlertsTab extends ConsumerWidget {
  const _AlertsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final alertsAsync = ref.watch(userAlertsProvider);
    final isPremium = ref.watch(isPremiumProvider);

    if (user == null) {
      return const _LoginPrompt();
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: alertsAsync.when(
        loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.navy)),
        error: (_, _) => const Center(
          child: Text('—',
              style: TextStyle(color: AppColors.textSecondary)),
        ),
        data: (alerts) => alerts.isEmpty
            ? _EmptyAlerts(
                onCreateTap: () =>
                    _showCreateSheet(context, ref, isPremium, alerts.length),
              )
            : ListView.builder(
                padding: const EdgeInsets.fromLTRB(0, 12, 0, 100),
                itemCount: alerts.length,
                itemBuilder: (_, i) => AlertCard(alert: alerts[i]),
              ),
      ),
      floatingActionButton: alertsAsync.whenOrNull(
        data: (alerts) => FloatingActionButton(
          backgroundColor: AppColors.navy,
          foregroundColor: Colors.white,
          onPressed: () =>
              _showCreateSheet(context, ref, isPremium, alerts.length),
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  void _showCreateSheet(
      BuildContext context, WidgetRef ref, bool isPremium, int currentCount) {
    final l = AppLocalizations.of(context)!;
    if (!isPremium && currentCount >= 2) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(l.leaseTrackerFreeLimitTitle),
          content: Text(l.leaseTrackerFreeLimitContent),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(l.commonClose),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.gold),
              child: Text(l.planUpgradeButton),
            ),
          ],
        ),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
        ),
        child: const _CreateAlertSheet(),
      ),
    );
  }
}

class _LoginPrompt extends StatelessWidget {
  const _LoginPrompt();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.notifications_none, size: 64, color: AppColors.textSecondary),
            const SizedBox(height: 16),
            Text(
              l.leaseTrackerLoginPromptTitle,
              style: const TextStyle(
                  fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.navy),
            ),
            const SizedBox(height: 8),
            Text(
              l.leaseTrackerLoginPromptSub,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {},
              child: Text(l.authLogin),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyAlerts extends StatelessWidget {
  final VoidCallback onCreateTap;
  const _EmptyAlerts({required this.onCreateTap});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.notifications_none,
                size: 64, color: AppColors.textSecondary),
            const SizedBox(height: 16),
            Text(
              l.leaseTrackerNoAlertsTitle,
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.navy),
            ),
            const SizedBox(height: 8),
            Text(
              l.leaseTrackerNoAlertsSub,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onCreateTap,
              icon: const Icon(Icons.add, size: 18),
              label: Text(l.leaseTrackerCreateFirstAlert),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Create Alert Bottom Sheet ─────────────────────────────────────────────────

class _CreateAlertSheet extends ConsumerStatefulWidget {
  const _CreateAlertSheet();

  @override
  ConsumerState<_CreateAlertSheet> createState() => _CreateAlertSheetState();
}

class _CreateAlertSheetState extends ConsumerState<_CreateAlertSheet> {
  final _zoneController = TextEditingController();
  String _selectedAsset = 'factory';
  String _direction = 'above';
  final _thresholdController = TextEditingController(text: '100');
  bool _saving = false;

  @override
  void dispose() {
    _zoneController.dispose();
    _thresholdController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final l = AppLocalizations.of(context)!;
    final user = ref.read(currentUserProvider);
    if (user == null) return;

    final threshold = double.tryParse(_thresholdController.text);
    if (threshold == null || threshold <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l.leaseTrackerAlertInvalidThreshold)),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      final alert = RateAlert(
        userId: user.id,
        zoneName: _zoneController.text.isEmpty ? null : _zoneController.text,
        assetType: _selectedAsset,
        thresholdPriceUsd: threshold,
        direction: _direction,
      );
      await ref.read(leaseTrackerRepositoryProvider).createAlert(alert);
      ref.invalidate(userAlertsProvider);
      if (mounted) Navigator.pop(context);
    } catch (_) {
      if (mounted) {
        final l2 = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l2.leaseTrackerAlertError),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final assetTypes = _buildAssetTypeMap(l);

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            l.leaseTrackerAlertCreate,
            style: const TextStyle(
                fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.navy),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _zoneController,
            decoration: InputDecoration(
              labelText: l.leaseTrackerAlertZoneName,
              hintText: l.leaseTrackerAlertZoneHint,
              prefixIcon: const Icon(Icons.location_city_outlined),
            ),
          ),
          const SizedBox(height: 14),
          Text(l.leaseTrackerAssetType,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.navy)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: assetTypes.entries.map((e) {
              final isSelected = _selectedAsset == e.key;
              return ChoiceChip(
                label: Text(e.value),
                selected: isSelected,
                onSelected: (_) => setState(() => _selectedAsset = e.key),
                selectedColor: AppColors.navy,
                labelStyle: TextStyle(
                    color: isSelected ? Colors.white : AppColors.textSecondary,
                    fontSize: 13),
                side: BorderSide(color: isSelected ? AppColors.navy : AppColors.border),
              );
            }).toList(),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _thresholdController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
            ],
            decoration: InputDecoration(
              labelText: l.leaseTrackerAlertThreshold,
              prefixIcon: const Icon(Icons.attach_money),
              suffixText: 'USD',
            ),
            onChanged: (v) {
              final parsed = double.tryParse(v);
              if (parsed != null) {}
            },
          ),
          const SizedBox(height: 14),
          Text(l.leaseTrackerAlertDirection,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.navy)),
          const SizedBox(height: 8),
          Row(
            children: [
              _DirectionChip(
                label: l.leaseTrackerPriceAbove,
                value: 'above',
                selected: _direction == 'above',
                color: AppColors.error,
                onTap: () => setState(() => _direction = 'above'),
              ),
              const SizedBox(width: 10),
              _DirectionChip(
                label: l.leaseTrackerPriceBelow,
                value: 'below',
                selected: _direction == 'below',
                color: AppColors.success,
                onTap: () => setState(() => _direction = 'below'),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : Text(l.leaseTrackerAlertSave),
            ),
          ),
        ],
      ),
    );
  }
}

class _DirectionChip extends StatelessWidget {
  final String label;
  final String value;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  const _DirectionChip({
    required this.label,
    required this.value,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? color.withValues(alpha: 0.12) : AppColors.backgroundLight,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: selected ? color : AppColors.border, width: selected ? 1.5 : 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              value == 'above' ? Icons.arrow_upward : Icons.arrow_downward,
              size: 14,
              color: selected ? color : AppColors.textSecondary,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: selected ? color : AppColors.textSecondary,
                fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Skeleton loaders ──────────────────────────────────────────────────────────

class _ChartSkeleton extends StatefulWidget {
  const _ChartSkeleton();

  @override
  State<_ChartSkeleton> createState() => _ChartSkeletonState();
}

class _ChartSkeletonState extends State<_ChartSkeleton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, _) => Container(
        decoration: BoxDecoration(
          color: AppColors.border.withValues(alpha: 0.4 + _ctrl.value * 0.3),
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}

class _TableSkeleton extends StatelessWidget {
  const _TableSkeleton();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        4,
        (i) => Container(
          height: 52,
          color: i.isEven ? AppColors.backgroundLight : Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              Expanded(
                  flex: 3,
                  child: Container(height: 12, color: AppColors.border)),
              const SizedBox(width: 8),
              Expanded(
                  flex: 2,
                  child: Container(height: 12, color: AppColors.border)),
              const SizedBox(width: 8),
              Expanded(
                  flex: 2,
                  child: Container(height: 12, color: AppColors.border)),
              const SizedBox(width: 8),
              Expanded(
                  flex: 1,
                  child: Container(height: 12, color: AppColors.border)),
            ],
          ),
        ),
      ),
    );
  }
}

class _InsightSkeleton extends StatelessWidget {
  const _InsightSkeleton();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        2,
        (_) => Container(
          margin: const EdgeInsets.only(bottom: 10),
          height: 90,
          decoration: BoxDecoration(
            color: AppColors.border.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}

// Private provider key for refresh
final _allRatesProviderKey = Provider<String>((ref) => 'key');
