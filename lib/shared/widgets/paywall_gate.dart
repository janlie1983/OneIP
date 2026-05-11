import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../features/subscription/presentation/providers/subscription_provider.dart';
import '../../features/subscription/presentation/screens/paywall_screen.dart';

class PaywallGate extends ConsumerWidget {
  final Widget child;
  final Widget? lockedChild;
  final String requiredPlan;
  final String? contentId;

  const PaywallGate({
    super.key,
    required this.child,
    this.lockedChild,
    this.requiredPlan = 'pro',
    this.contentId,
  });

  void _showPaywall(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => PaywallBottomSheet(contentId: contentId),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Pro subscribers always get access
    final isPro = ref.watch(isProProvider);
    if (isPro) return child;

    // PPV access check when contentId is provided
    if (contentId != null) {
      final hasPPV =
          ref.watch(ppvAccessProvider(contentId!)).valueOrNull ?? false;
      if (hasPPV) return child;
    }

    final locked = lockedChild ?? child;

    return Stack(
      children: [
        ImageFiltered(
          imageFilter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
          child: IgnorePointer(child: locked),
        ),
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.gold.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.workspace_premium_rounded,
                    color: AppColors.gold,
                    size: 28,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Tính năng Pro',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: AppColors.navy,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Nâng cấp để truy cập đầy đủ',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () => _showPaywall(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.gold,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Nâng cấp ngay',
                    style:
                        TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
