import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/providers/locale_provider.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/subscription/presentation/providers/subscription_provider.dart';
import '../../features/subscription/presentation/screens/paywall_screen.dart';

enum GateLevel {
  guest, // requires login; free users pass
  pro,   // requires pro; shows guest overlay if not logged in, pro overlay if free
  hard,  // requires login; no blur, just empty state
}

class PaywallGate extends ConsumerWidget {
  final Widget child;
  final Widget? lockedChild;
  final GateLevel level;
  final String? contentId;

  const PaywallGate({
    super.key,
    required this.child,
    this.lockedChild,
    this.level = GateLevel.pro,
    this.contentId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authAsync = ref.watch(authStateProvider);
    final isLoggedIn =
        authAsync.whenOrNull(data: (s) => s.session != null) ?? false;
    final isPro = ref.watch(isProProvider);
    final isVi = ref.watch(localeProvider).languageCode == 'vi';

    if (contentId != null) {
      final hasPPV =
          ref.watch(ppvAccessProvider(contentId!)).valueOrNull ?? false;
      if (hasPPV) return child;
    }

    switch (level) {
      case GateLevel.guest:
        if (isLoggedIn) return child;
        return _GuestOverlay(locked: lockedChild ?? child, isVi: isVi);

      case GateLevel.pro:
        if (isPro) return child;
        if (!isLoggedIn) {
          return _GuestOverlay(locked: lockedChild ?? child, isVi: isVi);
        }
        return _ProOverlay(
          locked: lockedChild ?? child,
          isVi: isVi,
          contentId: contentId,
          onPpv: () => showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (_) => PaywallBottomSheet(contentId: contentId),
          ),
        );

      case GateLevel.hard:
        if (isLoggedIn) return child;
        return _HardBlock(isVi: isVi);
    }
  }
}

// ── Level 1: Guest blur ───────────────────────────────────────────────────────

class _GuestOverlay extends StatelessWidget {
  final Widget locked;
  final bool isVi;

  const _GuestOverlay({required this.locked, required this.isVi});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ImageFiltered(
          imageFilter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
          child: IgnorePointer(child: locked),
        ),
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.72),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.navy.withValues(alpha: 0.08),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.lock_outline,
                      size: 26, color: AppColors.navy),
                ),
                const SizedBox(height: 10),
                Text(
                  isVi ? 'Đăng nhập để xem đầy đủ' : 'Sign in to view full content',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: AppColors.navy,
                  ),
                ),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: () => context.go('/register-incentive'),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.navy,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  ),
                  child: Text(
                    isVi ? 'Đăng nhập miễn phí' : 'Sign Up Free',
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () => context.go('/login'),
                  child: Text(
                    isVi
                        ? 'Đã có tài khoản? Đăng nhập'
                        : 'Already have an account? Sign in',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                      decoration: TextDecoration.underline,
                    ),
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

// ── Level 2: Pro blur ─────────────────────────────────────────────────────────

class _ProOverlay extends StatelessWidget {
  final Widget locked;
  final bool isVi;
  final String? contentId;
  final VoidCallback onPpv;

  const _ProOverlay({
    required this.locked,
    required this.isVi,
    this.contentId,
    required this.onPpv,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ImageFiltered(
          imageFilter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
          child: IgnorePointer(child: locked),
        ),
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.72),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.gold.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.gold),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.workspace_premium_rounded,
                          size: 14, color: AppColors.gold),
                      const SizedBox(width: 4),
                      Text(
                        isVi ? 'Tính năng Pro' : 'Pro Feature',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.gold,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  isVi ? 'Nâng cấp để truy cập' : 'Upgrade to access',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: AppColors.navy,
                  ),
                ),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: () => context.go('/subscription'),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.gold,
                    foregroundColor: AppColors.navy,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  ),
                  child: Text(
                    isVi
                        ? 'Xem gói Pro - 299.000đ/tháng'
                        : 'View Pro Plan - \$12/month',
                    style: const TextStyle(
                        fontSize: 12, fontWeight: FontWeight.w700),
                  ),
                ),
                if (contentId != null) ...[
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: onPpv,
                    child: Text(
                      isVi
                          ? 'Hoặc xem ngay 20.000đ'
                          : 'Or pay-per-view 20,000₫',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                        decoration: TextDecoration.underline,
                      ),
                    ),
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

// ── Level 3: Hard block ───────────────────────────────────────────────────────

class _HardBlock extends StatelessWidget {
  final bool isVi;
  const _HardBlock({required this.isVi});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.backgroundLight,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.border),
              ),
              child: const Icon(Icons.lock_outline,
                  size: 36, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 20),
            Text(
              isVi
                  ? 'Đăng nhập để sử dụng tính năng này'
                  : 'Login to use this feature',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.navy,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isVi
                  ? 'Tạo tài khoản miễn phí chỉ mất 30 giây'
                  : 'Create a free account in 30 seconds',
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 13, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () => context.go('/register-incentive'),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.navy,
                minimumSize: const Size(200, 44),
              ),
              child: Text(isVi ? 'Đăng ký miễn phí' : 'Sign Up Free'),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () => context.go('/login'),
              style: TextButton.styleFrom(foregroundColor: AppColors.textSecondary),
              child: Text(
                isVi ? 'Đã có tài khoản? Đăng nhập' : 'Have an account? Sign in',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
