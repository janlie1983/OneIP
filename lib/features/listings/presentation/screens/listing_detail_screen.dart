import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../subscription/presentation/providers/subscription_provider.dart';
import '../../../subscription/presentation/screens/paywall_screen.dart';
import '../../domain/models/listing_model.dart';
import '../providers/listing_provider.dart';
import '../widgets/inquiry_form.dart';

class ListingDetailScreen extends ConsumerStatefulWidget {
  final String id;
  final Listing? initialListing;

  const ListingDetailScreen({
    super.key,
    required this.id,
    this.initialListing,
  });

  @override
  ConsumerState<ListingDetailScreen> createState() =>
      _ListingDetailScreenState();
}

class _ListingDetailScreenState extends ConsumerState<ListingDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(listingRepositoryProvider).incrementViews(widget.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final listingAsync = widget.initialListing != null
        ? AsyncValue.data(widget.initialListing!)
        : ref.watch(listingByIdProvider(widget.id));

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: listingAsync.when(
        loading: () => const _LoadingState(),
        error: (e, _) => _ErrorState(
          message: '$e',
          onRetry: () => ref.invalidate(listingByIdProvider(widget.id)),
        ),
        data: (listing) {
          if (listing == null) return const _NotFoundState();
          return Stack(
            children: [
              CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                      child: _ImageGallery(listing: listing)),
                  SliverToBoxAdapter(
                      child: _HeaderSection(listing: listing)),
                  SliverToBoxAdapter(
                      child: _SpecsGrid(listing: listing)),
                  SliverToBoxAdapter(
                      child: _UtilitiesSection(listing: listing)),
                  SliverToBoxAdapter(
                      child: _DescriptionSection(listing: listing)),
                  SliverToBoxAdapter(
                      child: _LocationSection(listing: listing)),
                  SliverToBoxAdapter(
                      child: _ContactSection(listing: listing)),
                  SliverToBoxAdapter(
                      child: _SimilarListings(listing: listing)),
                  const SliverToBoxAdapter(child: SizedBox(height: 100)),
                ],
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: _BottomBar(listing: listing),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ── Image Gallery ─────────────────────────────────────────────────────────────

class _ImageGallery extends StatefulWidget {
  final Listing listing;
  const _ImageGallery({required this.listing});

  @override
  State<_ImageGallery> createState() => _ImageGalleryState();
}

class _ImageGalleryState extends State<_ImageGallery> {
  final _controller = PageController();
  int _index = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final images = widget.listing.images;

    return SizedBox(
      height: 280,
      child: Stack(
        children: [
          images.isEmpty
              ? _GalleryPlaceholder(listing: widget.listing)
              : PageView.builder(
                  controller: _controller,
                  itemCount: images.length,
                  onPageChanged: (i) => setState(() => _index = i),
                  itemBuilder: (ctx, i) => Image.network(
                    images[i],
                    fit: BoxFit.cover,
                    width: double.infinity,
                    errorBuilder: (ctx, err, stack) =>
                        _GalleryPlaceholder(listing: widget.listing),
                  ),
                ),
          // Top overlay
          SafeArea(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _CircleButton(
                    icon: Icons.arrow_back,
                    onTap: () {
                      if (context.canPop()) {
                        context.pop();
                      } else {
                        context.go('/listings');
                      }
                    },
                  ),
                  Row(
                    children: [
                      _CircleButton(
                        icon: Icons.share_outlined,
                        onTap: () {
                          Clipboard.setData(ClipboardData(
                            text:
                                'OneIP – ${widget.listing.title}\n/listings/${widget.listing.id}',
                          ));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content:
                                    Text('Đã sao chép link bất động sản')),
                          );
                        },
                      ),
                      const SizedBox(width: 8),
                      _SaveIconButton(listingId: widget.listing.id),
                    ],
                  ),
                ],
              ),
            ),
          ),
          // Counter
          if (images.length > 1)
            Positioned(
              bottom: 12,
              right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${_index + 1}/${images.length}',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _GalleryPlaceholder extends StatelessWidget {
  final Listing listing;
  const _GalleryPlaceholder({required this.listing});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            listing.assetTypeColor,
            listing.assetTypeColor.withValues(alpha: 0.6),
          ],
        ),
      ),
      child: Center(
        child: Icon(
          listing.assetTypeIcon,
          size: 80,
          color: Colors.white.withValues(alpha: 0.4),
        ),
      ),
    );
  }
}

class _CircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _CircleButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Colors.black45,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 18),
      ),
    );
  }
}

class _SaveIconButton extends ConsumerWidget {
  final String listingId;
  const _SaveIconButton({required this.listingId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    if (user == null) return const SizedBox.shrink();

    final savedAsync = ref.watch(isListingSavedProvider(listingId));
    return savedAsync.when(
      data: (isSaved) => GestureDetector(
        onTap: () async {
          final repo = ref.read(listingRepositoryProvider);
          if (isSaved) {
            await repo.unsaveListing(user.id, listingId);
          } else {
            await repo.saveListing(user.id, listingId);
          }
          ref.invalidate(isListingSavedProvider(listingId));
          ref.invalidate(savedListingsProvider);
        },
        child: Container(
          width: 36,
          height: 36,
          decoration: const BoxDecoration(
            color: Colors.black45,
            shape: BoxShape.circle,
          ),
          child: Icon(
            isSaved ? Icons.bookmark : Icons.bookmark_outline,
            color: isSaved ? AppColors.gold : Colors.white,
            size: 18,
          ),
        ),
      ),
      loading: () => const SizedBox(width: 36, height: 36),
      error: (err, stack) => const SizedBox.shrink(),
    );
  }
}

// ── Header ────────────────────────────────────────────────────────────────────

class _HeaderSection extends StatelessWidget {
  final Listing listing;
  const _HeaderSection({required this.listing});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Badges
          Wrap(
            spacing: 8,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: listing.assetTypeColor,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(listing.assetTypeIcon,
                        size: 12, color: Colors.white),
                    const SizedBox(width: 5),
                    Text(
                      listing.assetTypeLabel,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              if (listing.isFeatured)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.gold,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'Nổi bật',
                    style: TextStyle(
                      color: AppColors.navy,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              if (listing.isVerified)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                        color: AppColors.success.withValues(alpha: 0.3)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.verified,
                          size: 12, color: AppColors.success),
                      SizedBox(width: 4),
                      Text(
                        'Đã xác minh',
                        style: TextStyle(
                          color: AppColors.success,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),
          // Title
          Text(
            listing.title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppColors.navy,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 10),
          // Location chips
          Wrap(
            spacing: 8,
            children: [
              _LocationChip(
                  icon: Icons.location_on, label: listing.province),
              _LocationChip(icon: Icons.map, label: listing.regionLabel),
              if (listing.district != null)
                _LocationChip(
                    icon: Icons.location_city, label: listing.district!),
            ],
          ),
          const SizedBox(height: 16),
          // Price
          if (listing.leasePriceUsd != null) ...[
            Text(
              '\$${listing.leasePriceUsd!.toStringAsFixed(0)}/m²/năm',
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: AppColors.gold,
              ),
            ),
            if (listing.isNegotiable)
              const Text(
                'Giá có thể thương lượng',
                style: TextStyle(
                    fontSize: 12, color: AppColors.textSecondary),
              ),
          ] else
            const Text(
              'Liên hệ để biết giá',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppColors.textSecondary,
              ),
            ),
          if (listing.availableFrom != null) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.calendar_today,
                    size: 14, color: AppColors.textSecondary),
                const SizedBox(width: 6),
                Text(
                  'Có sẵn từ: ${_formatDate(listing.availableFrom!)}',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  String _formatDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
}

class _LocationChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _LocationChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.backgroundLight,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: AppColors.textSecondary),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
                fontSize: 12, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

// ── Specs Grid ────────────────────────────────────────────────────────────────

class _SpecsGrid extends StatelessWidget {
  final Listing listing;
  const _SpecsGrid({required this.listing});

  @override
  Widget build(BuildContext context) {
    final specs = <(String, String, String)>[
      ('📐', 'Tổng diện tích', _area(listing.totalAreaM2)),
      if (listing.clearHeightM != null)
        ('📏', 'Chiều cao thông thủy',
            '${listing.clearHeightM!.toStringAsFixed(1)}m'),
      if (listing.powerCapacityKva != null)
        ('⚡', 'Công suất điện',
            '${listing.powerCapacityKva!.toStringAsFixed(0)} KVA'),
      if (listing.hasLoadingDock && listing.loadingDockCount != null)
        ('🚪', 'Loading dock', '${listing.loadingDockCount} cửa'),
      if (listing.floorLoadCapacity != null)
        ('🏗️', 'Tải trọng sàn',
            '${listing.floorLoadCapacity!.toStringAsFixed(0)} kg/m²'),
      if (listing.yearBuilt != null)
        ('📅', 'Năm xây dựng', '${listing.yearBuilt}'),
      if (listing.minLeaseTermMonths != null)
        ('📋', 'Thời hạn tối thiểu', '${listing.minLeaseTermMonths} tháng'),
      if (listing.numberOfFloors > 1)
        ('🏢', 'Số tầng', '${listing.numberOfFloors} tầng'),
    ];

    if (specs.isEmpty) return const SizedBox.shrink();

    return _Section(
      title: 'Thông số kỹ thuật',
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        childAspectRatio: 3.2,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        children: specs.map((s) => _SpecCard(s.$1, s.$2, s.$3)).toList(),
      ),
    );
  }

  String _area(double m2) {
    if (m2 >= 10000) {
      return '${(m2 / 10000).toStringAsFixed(2)} ha';
    }
    return '${m2.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}m²';
  }
}

class _SpecCard extends StatelessWidget {
  final String emoji;
  final String label;
  final String value;
  const _SpecCard(this.emoji, this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.backgroundLight,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppColors.textSecondary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Utilities ─────────────────────────────────────────────────────────────────

class _UtilitiesSection extends StatelessWidget {
  final Listing listing;
  const _UtilitiesSection({required this.listing});

  @override
  Widget build(BuildContext context) {
    final items = [
      (listing.has3PhasePower, 'Điện 3 pha'),
      (listing.hasWaterSupply, 'Cấp thoát nước'),
      (listing.hasWastewaterTreatment, 'Xử lý nước thải'),
      (listing.hasFiberInternet, 'Internet cáp quang'),
      (listing.hasSecurity, 'An ninh 24/7'),
      (listing.hasCanteen, 'Căng tin'),
      (listing.hasParking, 'Bãi đỗ xe'),
      (listing.hasLoadingDock, 'Loading dock'),
    ];

    return _Section(
      title: 'Tiện ích & Tính năng',
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        childAspectRatio: 4.5,
        mainAxisSpacing: 4,
        crossAxisSpacing: 8,
        children: items
            .map((item) => Row(
                  children: [
                    Icon(
                      item.$1
                          ? Icons.check_circle
                          : Icons.cancel_outlined,
                      size: 16,
                      color: item.$1
                          ? AppColors.success
                          : AppColors.border,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        item.$2,
                        style: TextStyle(
                          fontSize: 13,
                          color: item.$1
                              ? AppColors.textPrimary
                              : AppColors.textSecondary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ))
            .toList(),
      ),
    );
  }
}

// ── Description ───────────────────────────────────────────────────────────────

class _DescriptionSection extends StatefulWidget {
  final Listing listing;
  const _DescriptionSection({required this.listing});

  @override
  State<_DescriptionSection> createState() => _DescriptionSectionState();
}

class _DescriptionSectionState extends State<_DescriptionSection> {
  bool _expanded = false;
  static const _threshold = 200;

  @override
  Widget build(BuildContext context) {
    final text = widget.listing.description;
    if (text == null || text.isEmpty) return const SizedBox.shrink();

    final isLong = text.length > _threshold;
    final displayText =
        (!_expanded && isLong) ? '${text.substring(0, _threshold)}...' : text;

    return _Section(
      title: 'Mô tả',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            displayText,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textPrimary,
              height: 1.6,
            ),
          ),
          if (isLong) ...[
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () => setState(() => _expanded = !_expanded),
              child: Text(
                _expanded ? 'Thu gọn ▲' : 'Xem thêm ▼',
                style: const TextStyle(
                  color: AppColors.navy,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Location ──────────────────────────────────────────────────────────────────

class _LocationSection extends StatelessWidget {
  final Listing listing;
  const _LocationSection({required this.listing});

  @override
  Widget build(BuildContext context) {
    return _Section(
      title: 'Vị trí',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _LocationRow(
              icon: Icons.location_city, label: listing.province),
          if (listing.district != null)
            _LocationRow(icon: Icons.map_outlined, label: listing.district!),
          if (listing.address != null)
            _LocationRow(
                icon: Icons.place_outlined, label: listing.address!),
          const SizedBox(height: 12),
          // Map placeholder
          Container(
            height: 140,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.backgroundLight,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.map,
                    size: 40,
                    color: AppColors.textSecondary.withValues(alpha: 0.4)),
                const SizedBox(height: 8),
                Text(
                  listing.province,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
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

class _LocationRow extends StatelessWidget {
  final IconData icon;
  final String label;
  const _LocationRow({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.textSecondary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                  fontSize: 14, color: AppColors.textPrimary),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Contact ───────────────────────────────────────────────────────────────────

class _ContactSection extends ConsumerWidget {
  final Listing listing;
  const _ContactSection({required this.listing});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authAsync = ref.watch(authStateProvider);
    final isLoggedIn =
        authAsync.whenOrNull(data: (s) => s.session != null) ?? false;
    final isPro = ref.watch(isProProvider);

    if (!isLoggedIn) {
      return _Section(
        title: 'Thông tin liên hệ',
        child: _GatedContact(
          overlayText: 'Đăng ký miễn phí để xem thông tin liên hệ',
          buttonLabel: 'Đăng ký ngay',
          buttonColor: AppColors.navy,
          onTap: () => context.go('/register'),
        ),
      );
    }

    if (!isPro) {
      return _Section(
        title: 'Thông tin liên hệ',
        child: _GatedContact(
          overlayText: 'Nâng cấp Pro để xem thông tin liên hệ đầy đủ',
          buttonLabel: 'Nâng cấp Pro – 299,000đ/tháng',
          buttonColor: AppColors.gold,
          buttonTextColor: AppColors.navy,
          onTap: () => showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            builder: (ctx) => const PaywallBottomSheet(),
          ),
          secondaryLabel: 'Xem ngay 20,000đ',
          onSecondaryTap: () => showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            builder: (ctx) => PaywallBottomSheet(contentId: listing.id),
          ),
        ),
      );
    }

    return _Section(
      title: 'Thông tin liên hệ',
      child: _FullContact(listing: listing),
    );
  }
}

class _GatedContact extends StatelessWidget {
  final String overlayText;
  final String buttonLabel;
  final Color buttonColor;
  final Color buttonTextColor;
  final VoidCallback onTap;
  final String? secondaryLabel;
  final VoidCallback? onSecondaryTap;

  const _GatedContact({
    required this.overlayText,
    required this.buttonLabel,
    required this.buttonColor,
    this.buttonTextColor = Colors.white,
    required this.onTap,
    this.secondaryLabel,
    this.onSecondaryTap,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Blurred placeholder
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.backgroundLight,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: [
              _MaskedRow(icon: Icons.person_outline, value: '••••••••'),
              _MaskedRow(icon: Icons.phone_outlined, value: '09••••••••'),
              _MaskedRow(
                  icon: Icons.email_outlined, value: '••••@••••.com'),
              _MaskedRow(
                  icon: Icons.chat_bubble_outline, value: '09••••••••'),
            ],
          ),
        ),
        // Overlay
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.85),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.lock_outline, size: 28, color: AppColors.navy),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    overlayText,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.navy,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: onTap,
                  style: FilledButton.styleFrom(
                    backgroundColor: buttonColor,
                    foregroundColor: buttonTextColor,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    textStyle: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w700),
                  ),
                  child: Text(buttonLabel),
                ),
                if (secondaryLabel != null && onSecondaryTap != null) ...[
                  const SizedBox(height: 6),
                  TextButton(
                    onPressed: onSecondaryTap,
                    style: TextButton.styleFrom(
                        foregroundColor: AppColors.textSecondary),
                    child: Text(secondaryLabel!,
                        style: const TextStyle(fontSize: 12)),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _MaskedRow extends StatelessWidget {
  final IconData icon;
  final String value;
  const _MaskedRow({required this.icon, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.textSecondary),
          const SizedBox(width: 10),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
              letterSpacing: 2,
            ),
          ),
        ],
      ),
    );
  }
}

class _FullContact extends StatelessWidget {
  final Listing listing;
  const _FullContact({required this.listing});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.backgroundLight,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          if (listing.contactName != null)
            _ContactRow(
              icon: Icons.person_outline,
              label: 'Liên hệ',
              value: listing.contactName!,
            ),
          if (listing.contactPhone != null)
            _ContactRow(
              icon: Icons.phone_outlined,
              label: 'SĐT',
              value: listing.contactPhone!,
              onTap: () => _copy(context, listing.contactPhone!, 'Số điện thoại'),
            ),
          if (listing.contactEmail != null)
            _ContactRow(
              icon: Icons.email_outlined,
              label: 'Email',
              value: listing.contactEmail!,
              onTap: () => _copy(context, listing.contactEmail!, 'Email'),
            ),
          if (listing.contactZalo != null)
            _ContactRow(
              icon: Icons.chat_bubble_outline,
              label: 'Zalo',
              value: listing.contactZalo!,
              onTap: () => _copy(context, listing.contactZalo!, 'Zalo'),
            )
          else if (listing.contactPhone != null)
            _ContactRow(
              icon: Icons.chat_bubble_outline,
              label: 'Zalo',
              value: listing.contactPhone!,
              onTap: () => _copy(context, listing.contactPhone!, 'Zalo'),
            ),
        ],
      ),
    );
  }

  void _copy(BuildContext context, String value, String label) {
    Clipboard.setData(ClipboardData(text: value));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Đã sao chép $label: $value')),
    );
  }
}

class _ContactRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback? onTap;

  const _ContactRow({
    required this.icon,
    required this.label,
    required this.value,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Icon(icon, size: 16, color: AppColors.navy),
            const SizedBox(width: 10),
            Text(
              '$label: ',
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
            Expanded(
              child: Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: onTap != null ? AppColors.navy : AppColors.textPrimary,
                ),
              ),
            ),
            if (onTap != null)
              const Icon(Icons.copy, size: 14, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}

// ── Similar Listings ──────────────────────────────────────────────────────────

class _SimilarListings extends ConsumerWidget {
  final Listing listing;
  const _SimilarListings({required this.listing});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final similarAsync = ref.watch(
      similarListingsProvider((listing.id, listing.assetType, listing.region)),
    );

    return similarAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (err, stack) => const SizedBox.shrink(),
      data: (items) {
        if (items.isEmpty) return const SizedBox.shrink();
        return _Section(
          title: 'Bất động sản tương tự',
          child: SizedBox(
            height: 240,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: items.length,
              separatorBuilder: (ctx, i) => const SizedBox(width: 12),
              itemBuilder: (ctx, i) =>
                  _SimilarCard(listing: items[i]),
            ),
          ),
        );
      },
    );
  }
}

class _SimilarCard extends StatelessWidget {
  final Listing listing;
  const _SimilarCard({required this.listing});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/listings/${listing.id}', extra: listing),
      child: SizedBox(
        width: 220,
        child: Card(
          elevation: 1,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Mini image header
              SizedBox(
                height: 100,
                width: double.infinity,
                child: listing.images.isNotEmpty
                    ? Image.network(
                        listing.images.first,
                        fit: BoxFit.cover,
                        errorBuilder: (ctx, err, stack) =>
                            _MiniPlaceholder(listing),
                      )
                    : _MiniPlaceholder(listing),
              ),
              Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      listing.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.navy,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      listing.province,
                      style: const TextStyle(
                          fontSize: 11, color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      listing.priceLabel,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.gold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MiniPlaceholder extends StatelessWidget {
  final Listing listing;
  const _MiniPlaceholder(this.listing);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: listing.assetTypeColor.withValues(alpha: 0.1),
      child: Center(
        child: Icon(listing.assetTypeIcon,
            size: 32,
            color: listing.assetTypeColor.withValues(alpha: 0.4)),
      ),
    );
  }
}

// ── Bottom Bar ────────────────────────────────────────────────────────────────

class _BottomBar extends ConsumerWidget {
  final Listing listing;
  const _BottomBar({required this.listing});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authAsync = ref.watch(authStateProvider);
    final isLoggedIn =
        authAsync.whenOrNull(data: (s) => s.session != null) ?? false;
    final isPro = ref.watch(isProProvider);
    final bottom = MediaQuery.of(context).padding.bottom;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(top: BorderSide(color: AppColors.border)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      padding: EdgeInsets.fromLTRB(20, 12, 20, bottom > 0 ? bottom : 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  listing.priceLabel,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.gold,
                  ),
                ),
                Text(
                  '${listing.assetTypeLabel} • ${listing.province}',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          if (!isLoggedIn)
            FilledButton(
              onPressed: () => context.go(
                  '/register-incentive?redirect=/listings/${listing.id}'),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.gold,
                foregroundColor: AppColors.navy,
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 12),
                textStyle: const TextStyle(
                    fontWeight: FontWeight.w700, fontSize: 13),
              ),
              child: const Text('Đăng ký để liên hệ'),
            )
          else if (!isPro)
            FilledButton(
              onPressed: () => showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                shape: const RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(20)),
                ),
                builder: (ctx) => const PaywallBottomSheet(),
              ),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.gold,
                foregroundColor: AppColors.navy,
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 12),
                textStyle: const TextStyle(
                    fontWeight: FontWeight.w700, fontSize: 13),
              ),
              child: const Text('Nâng cấp để liên hệ'),
            )
          else
            FilledButton(
              onPressed: () => _showContactSheet(context, listing),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.navy,
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 12),
                textStyle: const TextStyle(
                    fontWeight: FontWeight.w700, fontSize: 13),
              ),
              child: const Text('Liên hệ ngay'),
            ),
        ],
      ),
    );
  }

  void _showContactSheet(BuildContext context, Listing listing) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => _ContactSheet(listing: listing),
    );
  }
}

class _ContactSheet extends StatelessWidget {
  final Listing listing;
  const _ContactSheet({required this.listing});

  void _copy(BuildContext context, String value, String label) {
    Clipboard.setData(ClipboardData(text: value));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Đã sao chép $label')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).padding.bottom;
    return DraggableScrollableSheet(
      initialChildSize: 0.8,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (ctx, scroll) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SingleChildScrollView(
          controller: scroll,
          padding: EdgeInsets.fromLTRB(20, 8, 20, bottom + 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const Text(
                'Thông tin liên hệ',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.navy,
                ),
              ),
              const SizedBox(height: 16),
              // Contact buttons
              if (listing.contactPhone != null) ...[
                _ActionButton(
                  icon: Icons.phone,
                  label: 'Gọi ngay',
                  subtitle: listing.contactPhone!,
                  color: AppColors.success,
                  onTap: () =>
                      _copy(context, listing.contactPhone!, 'Số điện thoại'),
                ),
                const SizedBox(height: 10),
              ],
              if (listing.contactEmail != null) ...[
                _ActionButton(
                  icon: Icons.email,
                  label: 'Gửi email',
                  subtitle: listing.contactEmail!,
                  color: AppColors.navy,
                  onTap: () => _copy(context, listing.contactEmail!, 'Email'),
                ),
                const SizedBox(height: 10),
              ],
              if (listing.contactZalo != null ||
                  listing.contactPhone != null) ...[
                _ActionButton(
                  icon: Icons.chat_bubble,
                  label: 'Nhắn Zalo',
                  subtitle:
                      listing.contactZalo ?? listing.contactPhone ?? '',
                  color: const Color(0xFF0068FF),
                  onTap: () => _copy(
                    context,
                    listing.contactZalo ?? listing.contactPhone ?? '',
                    'Số Zalo',
                  ),
                ),
                const SizedBox(height: 20),
              ],
              const Divider(),
              const SizedBox(height: 16),
              InquiryForm(listingId: listing.id),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 0,
      ),
      child: Row(
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(label,
                  style: const TextStyle(
                      fontWeight: FontWeight.w700, fontSize: 14)),
              Text(subtitle,
                  style: const TextStyle(
                      fontSize: 12, color: Colors.white70)),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Shared Section wrapper ────────────────────────────────────────────────────

class _Section extends StatelessWidget {
  final String title;
  final Widget child;
  const _Section({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      color: Colors.white,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.navy,
            ),
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

// ── State widgets ─────────────────────────────────────────────────────────────

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Container(
            height: 280,
            color: AppColors.border,
          ),
        ),
        SliverToBoxAdapter(
          child: Container(
            margin: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                    height: 20, width: 120, color: AppColors.border),
                const SizedBox(height: 12),
                Container(
                    height: 28, width: double.infinity, color: AppColors.border),
                const SizedBox(height: 8),
                Container(
                    height: 28, width: 200, color: AppColors.border),
                const SizedBox(height: 16),
                Container(
                    height: 36, width: 160, color: AppColors.border),
              ],
            ),
          ),
        ),
        const SliverFillRemaining(
          child: Center(child: CircularProgressIndicator()),
        ),
      ],
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline,
                size: 56, color: AppColors.error),
            const SizedBox(height: 16),
            Text(message,
                textAlign: TextAlign.center,
                style:
                    const TextStyle(color: AppColors.textSecondary)),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Thử lại'),
              style: FilledButton.styleFrom(
                  backgroundColor: AppColors.navy),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotFoundState extends StatelessWidget {
  const _NotFoundState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.search_off, size: 56, color: AppColors.textSecondary),
          const SizedBox(height: 16),
          const Text('Không tìm thấy bất động sản này',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary)),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: () => context.go('/listings'),
            style: FilledButton.styleFrom(backgroundColor: AppColors.navy),
            child: const Text('Xem tất cả BĐS'),
          ),
        ],
      ),
    );
  }
}
