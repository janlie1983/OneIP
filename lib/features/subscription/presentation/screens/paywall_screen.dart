import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/payment_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class PaywallBottomSheet extends ConsumerStatefulWidget {
  final String? contentId;

  const PaywallBottomSheet({super.key, this.contentId});

  @override
  ConsumerState<PaywallBottomSheet> createState() => _PaywallBottomSheetState();
}

class _PaywallBottomSheetState extends ConsumerState<PaywallBottomSheet> {
  bool _isCreatingSubscription = false;
  bool _isCreatingPPV = false;

  Future<void> _subscribe() async {
    setState(() => _isCreatingSubscription = true);
    try {
      final payment =
          await ref.read(createSubscriptionPaymentProvider.notifier).create('pro');
      if (mounted) {
        Navigator.of(context).pop();
        context.push('/payment', extra: payment);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isCreatingSubscription = false);
    }
  }

  Future<void> _payPerView() async {
    setState(() => _isCreatingPPV = true);
    try {
      final payment = await ref
          .read(createPPVPaymentProvider.notifier)
          .create(contentId: widget.contentId);
      if (mounted) {
        Navigator.of(context).pop();
        context.push('/payment', extra: payment);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isCreatingPPV = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.fromLTRB(
          20, 16, 20, MediaQuery.of(context).viewInsets.bottom + 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          const Icon(Icons.workspace_premium_rounded,
              color: AppColors.gold, size: 32),
          const SizedBox(height: 10),
          const Text(
            'Mở khóa tính năng Pro',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.navy,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Chọn cách bạn muốn truy cập',
            style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _OptionCard(
                  icon: Icons.star_rounded,
                  iconColor: AppColors.navy,
                  title: 'Gói Pro',
                  subtitle: '299,000đ/tháng',
                  features: const [
                    'Dữ liệu thời gian thực',
                    'Xuất PDF báo cáo',
                    'Không giới hạn checklist',
                  ],
                  buttonLabel: 'Đăng ký ngay',
                  buttonColor: AppColors.navy,
                  isLoading: _isCreatingSubscription,
                  enabled: user != null,
                  onTap: user != null ? _subscribe : null,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _OptionCard(
                  icon: Icons.flash_on_rounded,
                  iconColor: AppColors.gold,
                  title: 'Xem ngay',
                  subtitle: '20,000đ',
                  features: const [
                    'Truy cập 24 giờ',
                    'Không cần tài khoản',
                    'Thanh toán 1 lần',
                  ],
                  buttonLabel: 'Quét QR thanh toán',
                  buttonColor: AppColors.gold,
                  isLoading: _isCreatingPPV,
                  enabled: true,
                  onTap: _payPerView,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Hủy bất cứ lúc nào • Không hoàn tiền sau 7 ngày',
            style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _OptionCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final List<String> features;
  final String buttonLabel;
  final Color buttonColor;
  final bool isLoading;
  final bool enabled;
  final VoidCallback? onTap;

  const _OptionCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.features,
    required this.buttonLabel,
    required this.buttonColor,
    required this.isLoading,
    required this.enabled,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.backgroundLight,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 24),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.navy,
            ),
          ),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 13,
              color: iconColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          ...features.map(
            (f) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('• ',
                      style: TextStyle(
                          color: AppColors.textSecondary, fontSize: 12)),
                  Expanded(
                    child: Text(
                      f,
                      style: const TextStyle(
                          color: AppColors.textSecondary, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: enabled && !isLoading ? onTap : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: buttonColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                elevation: 0,
                textStyle: const TextStyle(
                    fontSize: 12, fontWeight: FontWeight.w600),
              ),
              child: isLoading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : Text(buttonLabel, textAlign: TextAlign.center),
            ),
          ),
        ],
      ),
    );
  }
}
