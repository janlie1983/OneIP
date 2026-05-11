import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/providers/locale_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../site_selection/domain/models/industrial_zone_model.dart';
import '../../../lease_tracker/domain/models/lease_rate_model.dart';
import '../providers/public_home_provider.dart';
import '../widgets/public_navbar.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _scrollController = ScrollController();
  final _searchKey = GlobalKey();
  final _ratesKey = GlobalKey();
  bool _isScrolled = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    final scrolled = _scrollController.offset > 200;
    if (scrolled != _isScrolled) setState(() => _isScrolled = scrolled);
  }

  void _scrollTo(GlobalKey key) {
    final ctx = key.currentContext;
    if (ctx == null) return;
    Scrollable.ensureVisible(ctx,
        duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isVi = ref.watch(localeProvider).languageCode == 'vi';

    return Scaffold(
      appBar: PublicNavbar(isScrolled: _isScrolled),
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _HeroSection(
              isVi: isVi,
              onSearchTap: () => _scrollTo(_searchKey),
              onRatesTap: () => _scrollTo(_ratesKey),
            ),
            _StatsBar(isVi: isVi),
            _QuickSearchSection(key: _searchKey),
            _FeaturedZonesSection(isVi: isVi),
            _LeaseRatesSection(key: _ratesKey, isVi: isVi),
            _HowItWorksSection(isVi: isVi),
            _CtaBanner(isVi: isVi),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

// ── Section 1: Hero ───────────────────────────────────────────────────────────

class _HeroSection extends StatelessWidget {
  final bool isVi;
  final VoidCallback onSearchTap;
  final VoidCallback onRatesTap;

  const _HeroSection({
    required this.isVi,
    required this.onSearchTap,
    required this.onRatesTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0D1B2E), AppColors.navy, Color(0xFF1E3A5F)],
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 72),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.gold,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Text(
                    '1',
                    style: TextStyle(
                      color: AppColors.navy,
                      fontWeight: FontWeight.w900,
                      fontSize: 28,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'OneIP',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          Text(
            isVi
                ? 'Tìm Khu Công Nghiệp & Kho Xưởng\ntại Việt Nam'
                : 'Find Industrial Zones & Warehouses\nin Vietnam',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w700,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            isVi
                ? 'Dữ liệu giá thuê, công cụ tìm kiếm và hỗ trợ pháp lý cho nhà đầu tư FDI'
                : 'Lease price data, search tools and legal support for FDI investors',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 15,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 40),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            alignment: WrapAlignment.center,
            children: [
              FilledButton.icon(
                onPressed: onSearchTap,
                icon: const Icon(Icons.search, size: 18),
                label: Text(isVi ? 'Tìm KCN ngay' : 'Search Now'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.gold,
                  foregroundColor: AppColors.navy,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  textStyle: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
              OutlinedButton.icon(
                onPressed: onRatesTap,
                icon: const Icon(Icons.trending_up, size: 18),
                label: Text(isVi ? 'Xem giá thuê' : 'View Rates'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white54),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Section 2: Stats Bar ──────────────────────────────────────────────────────

class _StatsBar extends StatelessWidget {
  final bool isVi;
  const _StatsBar({required this.isVi});

  @override
  Widget build(BuildContext context) {
    final stats = [
      ('10+', isVi ? 'Khu công nghiệp' : 'Industrial Zones'),
      ('3', isVi ? 'Miền Bắc/Trung/Nam' : 'North/Central/South'),
      (isVi ? 'Hàng tháng' : 'Monthly', isVi ? 'Cập nhật' : 'Updated'),
    ];

    return Container(
      color: AppColors.gold.withValues(alpha: 0.08),
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: stats
            .map(
              (s) => Column(
                children: [
                  Text(
                    s.$1,
                    style: const TextStyle(
                      color: AppColors.gold,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    s.$2,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            )
            .toList(),
      ),
    );
  }
}

// ── Section 3: Quick Search ───────────────────────────────────────────────────

class _QuickSearchSection extends ConsumerStatefulWidget {
  const _QuickSearchSection({super.key});
  final bool isVi = true;

  @override
  ConsumerState<_QuickSearchSection> createState() =>
      _QuickSearchSectionState();
}

class _QuickSearchSectionState extends ConsumerState<_QuickSearchSection> {
  bool _searched = false;

  static const _industries = [
    'Electronics',
    'Textile',
    'Food Processing',
    'Logistics',
    'Auto Parts',
    'Pharma',
  ];
  static const _regions = {
    '': 'Tất cả',
    'North': 'Miền Bắc',
    'Central': 'Miền Trung',
    'South': 'Miền Nam',
  };

  @override
  Widget build(BuildContext context) {
    final isVi = ref.watch(localeProvider).languageCode == 'vi';
    final selectedIndustry = ref.watch(publicSearchQueryProvider);
    final selectedRegion = ref.watch(publicRegionFilterProvider) ?? '';

    return Container(
      color: AppColors.backgroundLight,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isVi ? 'Tìm KCN phù hợp' : 'Find the Right Industrial Zone',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppColors.navy,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            isVi ? 'Ngành nghề' : 'Industry',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 38,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _industries.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, i) {
                final ind = _industries[i];
                final selected = selectedIndustry == ind;
                return ChoiceChip(
                  label: Text(ind),
                  selected: selected,
                  onSelected: (_) {
                    ref.read(publicSearchQueryProvider.notifier).state =
                        selected ? null : ind;
                  },
                  selectedColor: AppColors.navy,
                  labelStyle: TextStyle(
                    color: selected ? Colors.white : AppColors.navy,
                    fontSize: 13,
                  ),
                  backgroundColor: Colors.white,
                  side: BorderSide(
                    color: selected ? AppColors.navy : AppColors.border,
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          Text(
            isVi ? 'Khu vực' : 'Region',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            children: _regions.entries.map((e) {
              final selected = selectedRegion == e.key;
              return ChoiceChip(
                label: Text(e.value),
                selected: selected,
                onSelected: (_) {
                  ref.read(publicRegionFilterProvider.notifier).state =
                      selected ? null : e.key;
                },
                selectedColor: AppColors.navy,
                labelStyle: TextStyle(
                  color: selected ? Colors.white : AppColors.navy,
                  fontSize: 13,
                ),
                backgroundColor: Colors.white,
                side: BorderSide(
                  color: selected ? AppColors.navy : AppColors.border,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () => setState(() => _searched = true),
              icon: const Icon(Icons.search),
              label: Text(isVi ? 'Tìm kiếm' : 'Search'),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.navy,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
          if (_searched) ...[
            const SizedBox(height: 24),
            _PublicSearchResults(isVi: isVi),
          ],
          const SizedBox(height: 20),
          _AdvancedSearchButton(isVi: isVi),
        ],
      ),
    );
  }
}

class _PublicSearchResults extends ConsumerWidget {
  final bool isVi;
  const _PublicSearchResults({required this.isVi});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resultsAsync = ref.watch(publicSearchResultsProvider);

    return resultsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Text('$e'),
      data: (zones) {
        if (zones.isEmpty) {
          return Center(
            child: Text(
              isVi ? 'Không tìm thấy KCN phù hợp' : 'No zones found',
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          );
        }
        final visible = zones.take(3).toList();
        final blurred = zones.skip(3).toList();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ...visible.map((z) => _PublicZoneCard(zone: z, isVi: isVi)),
            if (blurred.isNotEmpty)
              Stack(
                children: [
                  Column(
                    children: blurred
                        .map((z) => _PublicZoneCard(zone: z, isVi: isVi))
                        .toList(),
                  ),
                  Positioned.fill(
                    child: _PaywallOverlay(isVi: isVi),
                  ),
                ],
              ),
          ],
        );
      },
    );
  }
}


class _AdvancedSearchButton extends ConsumerWidget {
  final bool isVi;
  const _AdvancedSearchButton({required this.isVi});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authAsync = ref.watch(authStateProvider);
    final isLoggedIn =
        authAsync.whenOrNull(data: (s) => s.session != null) ?? false;

    return OutlinedButton.icon(
      onPressed: () {
        if (isLoggedIn) {
          context.go('/home/site-selection');
        } else {
          context.go('/register-incentive');
        }
      },
      icon: const Icon(Icons.tune, size: 16),
      label: Text(isVi ? 'Tìm kiếm nâng cao' : 'Advanced Search'),
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.navy,
        side: const BorderSide(color: AppColors.navy),
        minimumSize: const Size(double.infinity, 44),
      ),
    );
  }
}

// ── Section 4: Featured KCN Cards ────────────────────────────────────────────

class _FeaturedZonesSection extends ConsumerWidget {
  final bool isVi;
  const _FeaturedZonesSection({required this.isVi});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final zonesAsync = ref.watch(publicZonesProvider);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isVi ? 'Khu công nghiệp nổi bật' : 'Featured Industrial Zones',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppColors.navy,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            isVi
                ? 'Dữ liệu được cập nhật hàng tháng'
                : 'Data updated monthly',
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 24),
          zonesAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Text('$e'),
            data: (zones) => Column(
              children:
                  zones.map((z) => _PublicZoneCard(zone: z, isVi: isVi)).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _PublicZoneCard extends ConsumerWidget {
  final IndustrialZone zone;
  final bool isVi;

  const _PublicZoneCard({required this.zone, required this.isVi});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authAsync = ref.watch(authStateProvider);
    final isLoggedIn =
        authAsync.whenOrNull(data: (s) => s.session != null) ?? false;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          if (!isLoggedIn) {
            _showLoginPrompt(context, isVi);
          } else {
            context.push('/zone-detail/${zone.id}', extra: zone);
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
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
                        Row(
                          children: [
                            const Icon(Icons.location_on,
                                size: 13, color: AppColors.textSecondary),
                            const SizedBox(width: 3),
                            Text(
                              zone.province,
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(width: 8),
                            _RegionBadge(region: zone.region),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (zone.overallScore > 0)
                    _ScoreBadge(score: zone.overallScore),
                ],
              ),
              if (zone.leasePriceUsd != null) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.attach_money,
                        size: 14, color: AppColors.gold),
                    Text(
                      '\$${zone.leasePriceUsd!.toStringAsFixed(0)}/m²/năm',
                      style: const TextStyle(
                        color: AppColors.gold,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ],
              if (zone.industriesSupported.isNotEmpty) ...[
                const SizedBox(height: 10),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: zone.industriesSupported.take(4).map((ind) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.backgroundLight,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Text(
                        ind,
                        style: const TextStyle(
                            fontSize: 11, color: AppColors.textSecondary),
                      ),
                    );
                  }).toList(),
                ),
              ],
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton.icon(
                    onPressed: () {
                      if (!isLoggedIn) {
                        _showLoginPrompt(context, isVi);
                      } else {
                        context.push('/zone-detail/${zone.id}', extra: zone);
                      }
                    },
                    icon: const Icon(Icons.arrow_forward_ios, size: 12),
                    label: Text(
                        isVi ? 'Xem chi tiết' : 'View Details',
                        style: const TextStyle(fontSize: 13)),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.navy,
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                  if (!isLoggedIn)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.gold.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.lock_outline,
                              size: 11, color: AppColors.gold),
                          const SizedBox(width: 4),
                          Text(
                            isVi ? 'Đăng nhập để xem' : 'Login to view',
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.gold,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLoginPrompt(BuildContext context, bool isVi) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isVi ? 'Đăng nhập để xem' : 'Login Required'),
        content: Text(
          isVi
              ? 'Đăng ký miễn phí để xem thông tin chi tiết về khu công nghiệp.'
              : 'Sign up for free to view detailed information about industrial zones.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(isVi ? 'Để sau' : 'Later'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.go('/register');
            },
            style: FilledButton.styleFrom(backgroundColor: AppColors.navy),
            child: Text(isVi ? 'Đăng ký miễn phí' : 'Sign Up Free'),
          ),
        ],
      ),
    );
  }
}

class _RegionBadge extends StatelessWidget {
  final String region;
  const _RegionBadge({required this.region});

  String get label => const {
        'North': 'Miền Bắc',
        'Central': 'Miền Trung',
        'South': 'Miền Nam',
      }[region] ??
      region;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.navy.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 11,
          color: AppColors.navy,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _ScoreBadge extends StatelessWidget {
  final double score;
  const _ScoreBadge({required this.score});

  Color get _color => score >= 7
      ? AppColors.success
      : score >= 5
          ? AppColors.warning
          : AppColors.error;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _color.withValues(alpha: 0.3)),
      ),
      child: Text(
        score.toStringAsFixed(1),
        style: TextStyle(
          color: _color,
          fontWeight: FontWeight.w700,
          fontSize: 16,
        ),
      ),
    );
  }
}

class _PaywallOverlay extends ConsumerWidget {
  final bool isVi;
  const _PaywallOverlay({required this.isVi});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ClipRRect(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white.withValues(alpha: 0.0),
              Colors.white.withValues(alpha: 0.85),
              Colors.white,
            ],
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Icon(Icons.lock_outline,
                    size: 32, color: AppColors.navy),
                const SizedBox(height: 8),
                Text(
                  isVi
                      ? 'Đăng nhập để xem thêm kết quả'
                      : 'Login to see more results',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.navy,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    OutlinedButton(
                      onPressed: () => context.go('/login'),
                      child: Text(isVi ? 'Đăng nhập' : 'Sign In'),
                    ),
                    const SizedBox(width: 12),
                    FilledButton(
                      onPressed: () => context.go('/register'),
                      style: FilledButton.styleFrom(
                          backgroundColor: AppColors.navy),
                      child: Text(isVi ? 'Đăng ký miễn phí' : 'Sign Up Free'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Section 5: Lease Rate Snapshot ───────────────────────────────────────────

class _LeaseRatesSection extends ConsumerWidget {
  final bool isVi;
  const _LeaseRatesSection({super.key, required this.isVi});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ratesAsync = ref.watch(publicLeaseRatesProvider);
    final authAsync = ref.watch(authStateProvider);
    final isLoggedIn =
        authAsync.whenOrNull(data: (s) => s.session != null) ?? false;

    return Container(
      color: AppColors.backgroundLight,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isVi ? 'Giá thuê KCN mới nhất' : 'Latest Lease Rates',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppColors.navy,
            ),
          ),
          const SizedBox(height: 20),
          ratesAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Text('$e'),
            data: (rates) => Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    children: [
                      _RateTableHeader(isVi: isVi),
                      const Divider(height: 1),
                      ...rates.asMap().entries.map((e) => Column(
                            children: [
                              _RateTableRow(
                                  rate: e.value, isVi: isVi),
                              if (e.key < rates.length - 1)
                                const Divider(height: 1),
                            ],
                          )),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                if (!isLoggedIn)
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => context.go('/login'),
                      icon: const Icon(Icons.trending_up),
                      label: Text(isVi ? 'Xem thêm' : 'View More'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.navy,
                        side: const BorderSide(color: AppColors.navy),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RateTableHeader extends StatelessWidget {
  final bool isVi;
  const _RateTableHeader({required this.isVi});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: const BoxDecoration(
        color: AppColors.navy,
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      child: Row(
        children: [
          Expanded(
              flex: 3,
              child: Text(isVi ? 'Khu công nghiệp' : 'Zone',
                  style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      fontWeight: FontWeight.w600))),
          Expanded(
              flex: 2,
              child: Text(isVi ? 'Loại' : 'Type',
                  style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      fontWeight: FontWeight.w600))),
          Expanded(
              flex: 2,
              child: Text(isVi ? 'Giá' : 'Price',
                  style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      fontWeight: FontWeight.w600))),
          Expanded(
              flex: 2,
              child: Text(isVi ? 'Khu vực' : 'Region',
                  style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      fontWeight: FontWeight.w600))),
        ],
      ),
    );
  }
}

class _RateTableRow extends StatelessWidget {
  final LeaseRate rate;
  final bool isVi;
  const _RateTableRow({required this.rate, required this.isVi});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              rate.zoneName,
              style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.navy,
                  fontWeight: FontWeight.w500),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              rate.assetTypeLabel,
              style: const TextStyle(
                  fontSize: 12, color: AppColors.textSecondary),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              rate.formattedPrice,
              style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.gold,
                  fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              rate.regionLabel,
              style: const TextStyle(
                  fontSize: 12, color: AppColors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Section 6: How it works ───────────────────────────────────────────────────

class _HowItWorksSection extends StatelessWidget {
  final bool isVi;
  const _HowItWorksSection({required this.isVi});

  @override
  Widget build(BuildContext context) {
    final steps = isVi
        ? [
            (Icons.search_rounded, 'Tìm kiếm KCN phù hợp',
                'Lọc theo ngành nghề, khu vực và tiêu chí ưu tiên'),
            (Icons.compare_arrows_rounded, 'So sánh giá và hạ tầng',
                'Xem điểm số hạ tầng, lao động, logistics và chi phí'),
            (Icons.handshake_rounded, 'Kết nối với chủ KCN',
                'Liên hệ trực tiếp với ban quản lý khu công nghiệp'),
          ]
        : [
            (Icons.search_rounded, 'Search for the right zone',
                'Filter by industry, region and priority criteria'),
            (Icons.compare_arrows_rounded, 'Compare prices & infrastructure',
                'View infra, labor, logistics scores and costs'),
            (Icons.handshake_rounded, 'Connect with zone developers',
                'Contact industrial zone management directly'),
          ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      child: Column(
        children: [
          Text(
            isVi ? 'Cách hoạt động' : 'How It Works',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppColors.navy,
            ),
          ),
          const SizedBox(height: 32),
          ...steps.asMap().entries.map((e) => _StepTile(
                step: e.key + 1,
                icon: e.value.$1,
                title: e.value.$2,
                description: e.value.$3,
              )),
        ],
      ),
    );
  }
}

class _StepTile extends StatelessWidget {
  final int step;
  final IconData icon;
  final String title;
  final String description;

  const _StepTile({
    required this.step,
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.navy,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.gold, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 20,
                      height: 20,
                      decoration: const BoxDecoration(
                        color: AppColors.gold,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '$step',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.navy,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.navy,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Padding(
                  padding: const EdgeInsets.only(left: 28),
                  child: Text(
                    description,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Section 7: CTA Banner ─────────────────────────────────────────────────────

class _CtaBanner extends StatelessWidget {
  final bool isVi;
  const _CtaBanner({required this.isVi});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.navy, Color(0xFF1E3A5F)],
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
      child: Column(
        children: [
          Text(
            isVi
                ? 'Bắt đầu miễn phí ngay hôm nay'
                : 'Get Started for Free Today',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isVi
                ? 'Hoặc nâng cấp Pro để truy cập đầy đủ tất cả tính năng'
                : 'Or upgrade to Pro for full access to all features',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 32),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            alignment: WrapAlignment.center,
            children: [
              OutlinedButton(
                onPressed: () => context.go('/register'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white54),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                ),
                child: Text(isVi ? 'Đăng ký miễn phí' : 'Sign Up Free'),
              ),
              FilledButton(
                onPressed: () => context.go('/subscription'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.gold,
                  foregroundColor: AppColors.navy,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                ),
                child: Text(
                  isVi ? 'Nâng cấp Pro - 299.000đ/tháng' : 'Upgrade Pro - \$12/month',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
