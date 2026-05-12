import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/models/listing_model.dart';
import '../providers/listing_provider.dart';

class MyListingsScreen extends ConsumerWidget {
  const MyListingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final role = ref.watch(userRoleProvider);
    if (!role.isSupply) {
      return _NotSupplyScreen();
    }

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: AppColors.backgroundLight,
        appBar: AppBar(
          backgroundColor: AppColors.navy,
          foregroundColor: Colors.white,
          elevation: 0,
          title: const Text(
            'Quản lý listing',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 17),
          ),
          leading: BackButton(
              onPressed: () => context.go('/home/profile')),
          bottom: const TabBar(
            labelColor: AppColors.gold,
            unselectedLabelColor: Colors.white60,
            indicatorColor: AppColors.gold,
            labelStyle:
                TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
            unselectedLabelStyle: TextStyle(fontSize: 12),
            tabs: [
              Tab(text: 'Hoạt động'),
              Tab(text: 'Chờ duyệt'),
              Tab(text: 'Nháp'),
              Tab(text: 'Hết hạn'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _ListingTab(status: 'active'),
            _ListingTab(status: 'pending_review'),
            _ListingTab(status: 'draft'),
            _ListingTab(status: 'expired'),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => context.push('/listings/create'),
          backgroundColor: AppColors.gold,
          foregroundColor: AppColors.navy,
          icon: const Icon(Icons.add),
          label: const Text(
            'Đăng listing mới',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
      ),
    );
  }
}

class _ListingTab extends ConsumerWidget {
  final String status;
  const _ListingTab({required this.status});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allAsync = ref.watch(myListingsProvider);

    return allAsync.when(
      loading: () =>
          const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline,
                size: 48, color: AppColors.error),
            const SizedBox(height: 12),
            Text('$e',
                style:
                    const TextStyle(color: AppColors.textSecondary)),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => ref.invalidate(myListingsProvider),
              style: FilledButton.styleFrom(
                  backgroundColor: AppColors.navy),
              child: const Text('Thử lại'),
            ),
          ],
        ),
      ),
      data: (all) {
        final listings =
            all.where((l) => l.status == status).toList();
        if (listings.isEmpty) {
          return _EmptyTab(status: status);
        }
        return RefreshIndicator(
          onRefresh: () async =>
              ref.invalidate(myListingsProvider),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: listings.length,
            itemBuilder: (ctx, i) =>
                _MyListingCard(listing: listings[i]),
          ),
        );
      },
    );
  }
}

class _MyListingCard extends ConsumerWidget {
  final Listing listing;
  const _MyListingCard({required this.listing});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          _AssetBadge(listing: listing),
                          const SizedBox(width: 8),
                          _StatusBadge(status: listing.status),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        listing.title,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.navy,
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            // Stats row
            Row(
              children: [
                _StatChip(
                    icon: Icons.visibility_outlined,
                    label: '${listing.viewCount} lượt xem'),
                const SizedBox(width: 12),
                _StatChip(
                    icon: Icons.mail_outline,
                    label: '${listing.inquiryCount} yêu cầu'),
                const Spacer(),
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
            const Divider(height: 20),
            // Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (listing.status == 'draft')
                  _ActionBtn(
                    icon: Icons.delete_outline,
                    label: 'Xóa',
                    color: AppColors.error,
                    onTap: () => _confirmDelete(context, ref, listing),
                  ),
                const Spacer(),
                _ActionBtn(
                  icon: Icons.visibility_outlined,
                  label: 'Xem trước',
                  color: AppColors.textSecondary,
                  onTap: () => context.push(
                      '/listings/${listing.id}',
                      extra: listing),
                ),
                const SizedBox(width: 8),
                _ActionBtn(
                  icon: Icons.edit_outlined,
                  label: 'Chỉnh sửa',
                  color: AppColors.navy,
                  onTap: () => context.push(
                      '/listings/${listing.id}/edit'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete(
      BuildContext context, WidgetRef ref, Listing listing) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xóa listing?'),
        content: Text('Xóa "${listing.title}"?\nKhông thể khôi phục.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style:
                FilledButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref
          .read(listingRepositoryProvider)
          .deleteListing(listing.id);
      ref.invalidate(myListingsProvider);
    }
  }
}

class _AssetBadge extends StatelessWidget {
  final Listing listing;
  const _AssetBadge({required this.listing});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: listing.assetTypeColor,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        listing.assetTypeLabel,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  String get _label => switch (status) {
        'active' => 'Đang hoạt động',
        'pending_review' => 'Chờ duyệt',
        'draft' => 'Nháp',
        'rented' => 'Đã cho thuê',
        'expired' => 'Hết hạn',
        'rejected' => 'Bị từ chối',
        _ => status,
      };

  Color get _color => switch (status) {
        'active' => AppColors.success,
        'pending_review' => AppColors.warning,
        'draft' => AppColors.textSecondary,
        'rented' => AppColors.info,
        'expired' || 'rejected' => AppColors.error,
        _ => AppColors.textSecondary,
      };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: _color.withValues(alpha: 0.3)),
      ),
      child: Text(
        _label,
        style: TextStyle(
          color: _color,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _StatChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppColors.textSecondary),
        const SizedBox(width: 4),
        Text(label,
            style: const TextStyle(
                fontSize: 12, color: AppColors.textSecondary)),
      ],
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionBtn({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 15),
      label: Text(label, style: const TextStyle(fontSize: 12)),
      style: TextButton.styleFrom(
        foregroundColor: color,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }
}

class _EmptyTab extends StatelessWidget {
  final String status;
  const _EmptyTab({required this.status});

  @override
  Widget build(BuildContext context) {
    final (icon, title, body, cta) = switch (status) {
      'active' => (
          Icons.storefront_outlined,
          'Chưa có listing đang hoạt động',
          'Đăng listing mới để bắt đầu thu hút người thuê.',
          'Đăng ngay',
        ),
      'pending_review' => (
          Icons.hourglass_empty_outlined,
          'Không có listing chờ duyệt',
          'Các listing mới sẽ xuất hiện đây khi được gửi duyệt.',
          null,
        ),
      'draft' => (
          Icons.edit_note_outlined,
          'Không có nháp',
          'Lưu nháp khi đang soạn listing để tiếp tục sau.',
          'Tạo listing mới',
        ),
      _ => (
          Icons.history_outlined,
          'Không có listing hết hạn',
          'Các listing hết hạn sẽ xuất hiện ở đây.',
          null,
        ),
    };

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon,
                size: 60,
                color: AppColors.textSecondary.withValues(alpha: 0.4)),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.navy,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              body,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 13),
            ),
            if (cta != null) ...[
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: () => context.push('/listings/create'),
                icon: const Icon(Icons.add, size: 18),
                label: Text(cta),
                style: FilledButton.styleFrom(
                    backgroundColor: AppColors.navy,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12)),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _NotSupplyScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.navy,
        foregroundColor: Colors.white,
        title: const Text('Quản lý listing'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.business_outlined,
                  size: 64, color: AppColors.textSecondary),
              const SizedBox(height: 20),
              const Text(
                'Tính năng dành cho Chủ KCN và Môi giới',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.navy),
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () => context.go('/home/profile'),
                style: FilledButton.styleFrom(
                    backgroundColor: AppColors.navy,
                    minimumSize: const Size(double.infinity, 48)),
                child: const Text('Liên hệ nâng cấp tài khoản'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
