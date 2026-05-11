import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/providers/locale_provider.dart';

class RegisterIncentiveScreen extends ConsumerWidget {
  final String? redirect;

  const RegisterIncentiveScreen({super.key, this.redirect});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isVi = ref.watch(localeProvider).languageCode == 'vi';

    final benefits = isVi
        ? [
            (Icons.search_rounded, 'Xem toàn bộ kết quả tìm kiếm',
                'Không giới hạn số lượng KCN có thể xem'),
            (Icons.trending_up_rounded, 'Theo dõi giá thuê KCN',
                'Cập nhật giá mới nhất hàng tháng'),
            (Icons.checklist_rounded, 'Tạo checklist giấy phép',
                'Hướng dẫn pháp lý bước-từng-bước'),
            (Icons.bookmark_rounded, 'Lưu danh sách yêu thích',
                'So sánh nhiều KCN cùng lúc'),
          ]
        : [
            (Icons.search_rounded, 'See all search results',
                'Unlimited industrial zones to browse'),
            (Icons.trending_up_rounded, 'Track IZ lease rates',
                'Latest monthly price updates'),
            (Icons.checklist_rounded, 'Create permit checklists',
                'Step-by-step legal guidance'),
            (Icons.bookmark_rounded, 'Save your favorites',
                'Compare multiple zones side-by-side'),
          ];

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context, isVi),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildValueProp(isVi),
                    const SizedBox(height: 32),
                    ...benefits.map((b) => _BenefitRow(
                          icon: b.$1,
                          title: b.$2,
                          description: b.$3,
                        )),
                    const SizedBox(height: 40),
                    _buildActions(context, isVi),
                    const SizedBox(height: 16),
                    _buildBackLink(context, isVi),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isVi) {
    return Container(
      color: AppColors.navy,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/');
              }
            },
          ),
          const Expanded(
            child: Text(
              'OneIP',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildValueProp(bool isVi) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.success.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            isVi ? 'Miễn phí hoàn toàn' : '100% Free',
            style: const TextStyle(
              color: AppColors.success,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          isVi ? 'Đăng ký miễn phí để:' : 'Sign up free to:',
          style: const TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w800,
            color: AppColors.navy,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          isVi
              ? 'Không cần thẻ tín dụng. Hủy bất kỳ lúc nào.'
              : 'No credit card required. Cancel anytime.',
          style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
        ),
      ],
    );
  }

  Widget _buildActions(BuildContext context, bool isVi) {
    final r = redirect;
    final registerDest = (r?.isNotEmpty == true)
        ? '/register?redirect=${Uri.encodeComponent(r!)}'
        : '/register';
    final loginDest = (r?.isNotEmpty == true)
        ? '/login?redirect=${Uri.encodeComponent(r!)}'
        : '/login';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FilledButton(
          onPressed: () => context.go(registerDest),
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.navy,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            isVi ? 'Đăng ký ngay' : 'Sign Up Now',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
        ),
        const SizedBox(height: 12),
        OutlinedButton(
          onPressed: () => context.go(loginDest),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.navy,
            side: const BorderSide(color: AppColors.navy),
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            isVi ? 'Đăng nhập' : 'Sign In',
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }

  Widget _buildBackLink(BuildContext context, bool isVi) {
    return Center(
      child: TextButton(
        onPressed: () {
          if (context.canPop()) {
            context.pop();
          } else {
            context.go('/');
          }
        },
        style: TextButton.styleFrom(foregroundColor: AppColors.textSecondary),
        child: Text(
          isVi ? 'Tiếp tục xem miễn phí' : 'Continue browsing for free',
          style: const TextStyle(fontSize: 13),
        ),
      ),
    );
  }
}

class _BenefitRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _BenefitRow({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.gold.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.gold, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.check_circle_rounded,
                        size: 16, color: AppColors.success),
                    const SizedBox(width: 6),
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
                const SizedBox(height: 3),
                Padding(
                  padding: const EdgeInsets.only(left: 22),
                  child: Text(
                    description,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
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
