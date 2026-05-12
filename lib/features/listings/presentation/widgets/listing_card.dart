import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../subscription/presentation/providers/subscription_provider.dart';
import '../../domain/models/listing_model.dart';
import '../providers/listing_provider.dart';

class ListingCard extends ConsumerWidget {
  final Listing listing;

  const ListingCard({super.key, required this.listing});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authAsync = ref.watch(authStateProvider);
    final isLoggedIn =
        authAsync.whenOrNull(data: (s) => s.session != null) ?? false;
    final isPro = ref.watch(isProProvider);

    return Card(
      elevation: 1,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () =>
            context.push('/listings/${listing.id}', extra: listing),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ImageHeader(listing: listing),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    listing.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.navy,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.location_on,
                          size: 12, color: AppColors.textSecondary),
                      const SizedBox(width: 2),
                      Expanded(
                        child: Text(
                          '${listing.province} · ${listing.regionLabel}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  _SpecsRow(listing: listing),
                  const SizedBox(height: 8),
                  _FeatureChips(listing: listing),
                  const SizedBox(height: 10),
                  _ContactRow(
                    listing: listing,
                    isLoggedIn: isLoggedIn,
                    isPro: isPro,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ImageHeader extends ConsumerWidget {
  final Listing listing;
  const _ImageHeader({required this.listing});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final savedAsync = user != null
        ? ref.watch(isListingSavedProvider(listing.id))
        : const AsyncValue.data(false);

    return Stack(
      children: [
        Container(
          height: 120,
          width: double.infinity,
          color: listing.assetTypeColor.withValues(alpha: 0.08),
          child: listing.images.isNotEmpty
              ? Image.network(
                  listing.images.first,
                  fit: BoxFit.cover,
                  errorBuilder: (ctx, err, stack) => _PlaceholderImage(listing),
                )
              : _PlaceholderImage(listing),
        ),
        Positioned(
          top: 8,
          left: 8,
          child: _AssetTypeBadge(listing: listing),
        ),
        if (listing.isFeatured)
          Positioned(
            top: 8,
            left: listing.assetTypeLabel.length * 7.0 + 24,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.gold,
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text(
                'Nổi bật',
                style: TextStyle(
                  color: AppColors.navy,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        if (user != null)
          Positioned(
            top: 6,
            right: 6,
            child: savedAsync.when(
              data: (isSaved) => _SaveButton(
                listingId: listing.id,
                isSaved: isSaved,
              ),
              loading: () => const SizedBox(width: 32, height: 32),
              error: (err, stack) => const SizedBox.shrink(),
            ),
          ),
      ],
    );
  }
}

class _PlaceholderImage extends StatelessWidget {
  final Listing listing;
  const _PlaceholderImage(this.listing);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Icon(
        listing.assetTypeIcon,
        size: 48,
        color: listing.assetTypeColor.withValues(alpha: 0.3),
      ),
    );
  }
}

class _AssetTypeBadge extends StatelessWidget {
  final Listing listing;
  const _AssetTypeBadge({required this.listing});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: listing.assetTypeColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(listing.assetTypeIcon, size: 11, color: Colors.white),
          const SizedBox(width: 4),
          Text(
            listing.assetTypeLabel,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _SaveButton extends ConsumerWidget {
  final String listingId;
  final bool isSaved;
  const _SaveButton({required this.listingId, required this.isSaved});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);

    return GestureDetector(
      onTap: () async {
        if (user == null) return;
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
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.9),
          shape: BoxShape.circle,
        ),
        child: Icon(
          isSaved ? Icons.bookmark : Icons.bookmark_outline,
          size: 18,
          color: isSaved ? AppColors.gold : AppColors.textSecondary,
        ),
      ),
    );
  }
}

class _SpecsRow extends StatelessWidget {
  final Listing listing;
  const _SpecsRow({required this.listing});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 4,
      children: [
        _SpecItem(
          '📐',
          _formatArea(listing.totalAreaM2),
        ),
        _SpecItem('💰', listing.priceLabel),
        if (listing.clearHeightM != null &&
            (listing.assetType == 'rbf' || listing.assetType == 'rbw'))
          _SpecItem('📏', '${listing.clearHeightM!.toStringAsFixed(1)}m'),
      ],
    );
  }

  String _formatArea(double area) {
    if (area >= 10000) {
      return '${(area / 10000).toStringAsFixed(1)}ha';
    }
    return '${area.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}m²';
  }
}

class _SpecItem extends StatelessWidget {
  final String emoji;
  final String value;
  const _SpecItem(this.emoji, this.value);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(emoji, style: const TextStyle(fontSize: 12)),
        const SizedBox(width: 3),
        Text(
          value,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _FeatureChips extends StatelessWidget {
  final Listing listing;
  const _FeatureChips({required this.listing});

  @override
  Widget build(BuildContext context) {
    final features = <String>[];
    if (listing.hasLoadingDock) {
      features.add(listing.loadingDockCount != null
          ? '${listing.loadingDockCount} cổng hàng'
          : 'Loading dock');
    }
    if (listing.has3PhasePower) features.add('3 pha');
    if (listing.hasFiberInternet) features.add('Fiber');
    if (listing.hasWastewaterTreatment) features.add('XLNT');

    if (features.isEmpty) return const SizedBox.shrink();

    return Wrap(
      spacing: 4,
      runSpacing: 4,
      children: features
          .take(3)
          .map((f) => Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.backgroundLight,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: AppColors.border),
                ),
                child: Text(
                  f,
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppColors.textSecondary,
                  ),
                ),
              ))
          .toList(),
    );
  }
}

class _ContactRow extends StatelessWidget {
  final Listing listing;
  final bool isLoggedIn;
  final bool isPro;

  const _ContactRow({
    required this.listing,
    required this.isLoggedIn,
    required this.isPro,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: FilledButton(
            onPressed: () =>
                context.push('/listings/${listing.id}', extra: listing),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.navy,
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              textStyle: const TextStyle(fontSize: 12),
            ),
            child: const Text('Xem chi tiết'),
          ),
        ),
        if (!isPro && listing.contactPhone != null) ...[
          const SizedBox(width: 8),
          Tooltip(
            message: 'Nâng cấp Pro để xem liên hệ',
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.gold.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                    color: AppColors.gold.withValues(alpha: 0.3)),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.lock_outline,
                      size: 12, color: AppColors.gold),
                  SizedBox(width: 3),
                  Text(
                    'Pro',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.gold,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}
