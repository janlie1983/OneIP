import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/models/listing_filter_model.dart';
import '../../domain/models/listing_model.dart';
import '../providers/listing_provider.dart';
import '../widgets/asset_type_tabs.dart';
import '../widgets/listing_card.dart';
import '../widgets/region_filter.dart';

class ListingsScreen extends ConsumerStatefulWidget {
  const ListingsScreen({super.key});

  @override
  ConsumerState<ListingsScreen> createState() => _ListingsScreenState();
}

class _ListingsScreenState extends ConsumerState<ListingsScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final listingsAsync = ref.watch(listingsProvider);
    final filter = ref.watch(listingFilterProvider);
    final authAsync = ref.watch(authStateProvider);
    final isLoggedIn =
        authAsync.whenOrNull(data: (s) => s.session != null) ?? false;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppColors.navy,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'BĐS Công nghiệp',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
        ),
        leading: BackButton(onPressed: () => context.go('/')),
      ),
      body: listingsAsync.when(
        loading: () => const _LoadingSkeleton(),
        error: (e, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: AppColors.error),
              const SizedBox(height: 12),
              Text('$e',
                  style: const TextStyle(color: AppColors.textSecondary)),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => ref.invalidate(listingsProvider),
                style: FilledButton.styleFrom(backgroundColor: AppColors.navy),
                child: const Text('Thử lại'),
              ),
            ],
          ),
        ),
        data: (allListings) {
          final filtered = _applyLocalFilters(allListings, filter);
          final isGuest = !isLoggedIn;
          final visible = isGuest ? filtered.take(4).toList() : filtered;
          final blurred = isGuest ? filtered.skip(4).toList() : <Listing>[];

          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(listingsProvider),
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Column(
                    children: [
                      _SearchBar(
                        controller: _searchController,
                        onChanged: (q) => ref
                            .read(listingFilterProvider.notifier)
                            .state = filter.copyWith(
                          searchQuery: q.isEmpty ? null : q,
                        ),
                      ),
                      AssetTypeTabs(
                        listings: allListings,
                        selected: filter.assetType,
                        onSelected: (type) => ref
                            .read(listingFilterProvider.notifier)
                            .state = filter.copyWith(assetType: type),
                      ),
                      RegionFilter(
                        listings: allListings,
                        selected: filter.region,
                        onSelected: (region) => ref
                            .read(listingFilterProvider.notifier)
                            .state = filter.copyWith(region: region),
                      ),
                      _SortBar(filter: filter),
                      _ResultCount(count: filtered.length),
                    ],
                  ),
                ),
                _ListingGrid(listings: visible.toList()),
                if (blurred.isNotEmpty)
                  SliverToBoxAdapter(
                    child: _GateOverlay(
                      blurredListings: blurred,
                      count: filtered.length,
                    ),
                  ),
                const SliverToBoxAdapter(child: SizedBox(height: 32)),
              ],
            ),
          );
        },
      ),
    );
  }

  List<Listing> _applyLocalFilters(List<Listing> all, ListingFilter filter) {
    var result = all;
    if (filter.assetType != null) {
      result = result.where((l) => l.assetType == filter.assetType).toList();
    }
    if (filter.region != null) {
      result = result.where((l) => l.region == filter.region).toList();
    }
    if (filter.searchQuery != null && filter.searchQuery!.isNotEmpty) {
      final q = filter.searchQuery!.toLowerCase();
      result = result
          .where((l) =>
              l.title.toLowerCase().contains(q) ||
              l.province.toLowerCase().contains(q))
          .toList();
    }
    return result;
  }
}

class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const _SearchBar({required this.controller, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.navy,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: 'Tìm theo tên, tỉnh thành...',
          hintStyle: const TextStyle(color: Colors.white54, fontSize: 14),
          prefixIcon: const Icon(Icons.search, color: Colors.white54, size: 20),
          suffixIcon: controller.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, color: Colors.white54, size: 18),
                  onPressed: () {
                    controller.clear();
                    onChanged('');
                  },
                )
              : null,
          filled: true,
          fillColor: Colors.white.withValues(alpha: 0.12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        ),
      ),
    );
  }
}

class _SortBar extends ConsumerWidget {
  final ListingFilter filter;
  const _SortBar({required this.filter});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const options = {
      'featured': 'Nổi bật',
      'price_asc': 'Giá thấp nhất',
      'price_desc': 'Giá cao nhất',
      'newest': 'Mới nhất',
      'area_asc': 'Diện tích lớn nhất',
    };

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          const Text(
            'Sắp xếp:',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(width: 8),
          DropdownButton<String>(
            value: filter.sortBy,
            isDense: true,
            underline: const SizedBox.shrink(),
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.navy,
              fontWeight: FontWeight.w600,
            ),
            items: options.entries
                .map((e) => DropdownMenuItem(
                      value: e.key,
                      child: Text(e.value),
                    ))
                .toList(),
            onChanged: (v) {
              if (v != null) {
                ref.read(listingFilterProvider.notifier).state =
                    filter.copyWith(sortBy: v);
              }
            },
          ),
        ],
      ),
    );
  }
}

class _ResultCount extends StatelessWidget {
  final int count;
  const _ResultCount({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.backgroundLight,
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
      alignment: Alignment.centerLeft,
      child: Text(
        'Tìm thấy $count bất động sản',
        style: const TextStyle(
          fontSize: 13,
          color: AppColors.textSecondary,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _ListingGrid extends StatelessWidget {
  final List<Listing> listings;
  const _ListingGrid({required this.listings});

  @override
  Widget build(BuildContext context) {
    if (listings.isEmpty) {
      return const SliverToBoxAdapter(child: _EmptyState());
    }

    final width = MediaQuery.sizeOf(context).width;
    final crossAxisCount = width >= 720 ? 2 : 1;

    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      sliver: SliverGrid(
        delegate: SliverChildBuilderDelegate(
          (context, i) => ListingCard(listing: listings[i]),
          childCount: listings.length,
        ),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: crossAxisCount == 2 ? 0.72 : 0.85,
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 64, horizontal: 32),
      child: Column(
        children: [
          Icon(Icons.search_off,
              size: 56, color: AppColors.textSecondary.withValues(alpha: 0.4)),
          const SizedBox(height: 16),
          const Text(
            'Không tìm thấy',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Thử điều chỉnh bộ lọc hoặc tìm kiếm với từ khóa khác.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class _GateOverlay extends StatelessWidget {
  final List<Listing> blurredListings;
  final int count;

  const _GateOverlay({
    required this.blurredListings,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
          child: GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: MediaQuery.sizeOf(context).width >= 720 ? 2 : 1,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 0.85,
            children: blurredListings
                .take(4)
                .map((l) => Opacity(
                      opacity: 0.25,
                      child: ListingCard(listing: l),
                    ))
                .toList(),
          ),
        ),
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.backgroundLight.withValues(alpha: 0.1),
                  AppColors.backgroundLight.withValues(alpha: 0.9),
                  AppColors.backgroundLight,
                ],
              ),
            ),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const Icon(Icons.lock_outline,
                        size: 40, color: AppColors.navy),
                    const SizedBox(height: 12),
                    Text(
                      'Còn ${blurredListings.length} bất động sản khác',
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: AppColors.navy,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Đăng ký miễn phí để xem toàn bộ danh sách\nvà thông tin liên hệ chủ bất động sản.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: AppColors.textSecondary, fontSize: 13),
                    ),
                    const SizedBox(height: 20),
                    FilledButton.icon(
                      onPressed: () => context.go('/register'),
                      icon: const Icon(Icons.person_add_outlined, size: 18),
                      label: const Text('Đăng ký miễn phí'),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.navy,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 28, vertical: 14),
                        textStyle: const TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 15),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextButton(
                      onPressed: () => context.go('/login'),
                      style: TextButton.styleFrom(
                          foregroundColor: AppColors.textSecondary),
                      child: const Text('Đã có tài khoản? Đăng nhập'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _LoadingSkeleton extends StatelessWidget {
  const _LoadingSkeleton();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            height: 56,
            color: AppColors.navy,
            margin: const EdgeInsets.all(16),
          ),
          const SizedBox(height: 8),
          ...List.generate(
            4,
            (_) => Container(
              height: 220,
              margin:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
