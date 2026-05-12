import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/config/env.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/language_switcher.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../subscription/presentation/providers/subscription_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    final user = ref.watch(currentUserProvider);
    final isPremium = ref.watch(isProProvider);
    final currentPlan = ref.watch(currentPlanProvider);
    final subAsync = ref.watch(userSubscriptionProvider);

    final email = user?.email ?? '';
    final initial = email.isNotEmpty ? email[0].toUpperCase() : 'U';
    final fullName = user?.userMetadata?['full_name'] as String?;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: AppBar(
        title: Text(l.profileTitle),
        backgroundColor: AppColors.navy,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _UserInfoCard(
              initial: initial,
              email: email,
              fullName: fullName,
              isPremium: isPremium,
              currentPlan: currentPlan,
              l: l,
            ),
            const SizedBox(height: 12),
            _SubscriptionCard(
              isPremium: isPremium,
              subAsync: subAsync,
            ),
            const SizedBox(height: 16),
            _LanguageCard(l: l),
            const SizedBox(height: 16),
            _AccountCard(l: l),
            _SupplyCard(ref: ref),
            if (Env.isDevelopment) ...[
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: () => context.push('/dev/payment-test'),
                icon: const Icon(Icons.science_rounded, size: 18),
                label: const Text('🧪 Test Payment (DEV)'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.purple,
                  side: const BorderSide(color: Colors.purple),
                  minimumSize: const Size.fromHeight(48),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  textStyle: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w600),
                ),
              ),
            ],
            const SizedBox(height: 32),
            OutlinedButton.icon(
              onPressed: () async {
                await ref.read(authRepositoryProvider).signOut();
                if (context.mounted) context.go('/login');
              },
              icon: const Icon(Icons.logout, size: 18),
              label: Text(l.profileLogout),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.error,
                side: const BorderSide(color: AppColors.error),
                minimumSize: const Size.fromHeight(52),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                textStyle: const TextStyle(
                    fontSize: 15, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UserInfoCard extends StatelessWidget {
  final String initial;
  final String email;
  final String? fullName;
  final bool isPremium;
  final String currentPlan;
  final AppLocalizations l;

  const _UserInfoCard({
    required this.initial,
    required this.email,
    required this.fullName,
    required this.isPremium,
    required this.currentPlan,
    required this.l,
  });

  @override
  Widget build(BuildContext context) {
    final planLabel = switch (currentPlan) {
      'pro' => l.profilePlanPro,
      'enterprise' => 'Enterprise',
      _ => l.profilePlanFree,
    };
    final planColor = isPremium ? AppColors.gold : AppColors.textSecondary;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.navy.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 38,
            backgroundColor: AppColors.navy,
            child: Text(
              initial,
              style: const TextStyle(
                fontSize: 30,
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            email.isNotEmpty ? email : '—',
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.navy,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            fullName ?? '---',
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 14),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
            decoration: BoxDecoration(
              color: planColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: planColor.withValues(alpha: 0.4)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isPremium
                      ? Icons.workspace_premium
                      : Icons.account_circle_outlined,
                  size: 15,
                  color: planColor,
                ),
                const SizedBox(width: 5),
                Text(
                  planLabel,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: planColor,
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

class _SubscriptionCard extends ConsumerWidget {
  final bool isPremium;
  final AsyncValue subAsync;

  const _SubscriptionCard({required this.isPremium, required this.subAsync});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
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
              Icon(
                isPremium ? Icons.workspace_premium : Icons.lock_outline,
                color: isPremium ? AppColors.gold : AppColors.textSecondary,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                isPremium ? 'Gói Pro đang hoạt động' : 'Gói miễn phí',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isPremium ? AppColors.navy : AppColors.textSecondary,
                ),
              ),
            ],
          ),
          if (isPremium)
            subAsync.whenOrNull(
              data: (sub) {
                if (sub == null) return const SizedBox.shrink();
                final days = sub.daysRemaining;
                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    'Còn $days ngày • hết hạn ${sub.currentPeriodEnd?.toLocal().toString().substring(0, 10) ?? '—'}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                );
              },
            ) ??
            const SizedBox.shrink(),
          const SizedBox(height: 12),
          if (!isPremium)
            ElevatedButton.icon(
              onPressed: () => context.push('/subscription'),
              icon: const Icon(Icons.arrow_upward_rounded, size: 16),
              label: const Text('Nâng cấp Pro — 299,000đ/tháng'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.gold,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(44),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                textStyle:
                    const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                elevation: 0,
              ),
            )
          else
            OutlinedButton.icon(
              onPressed: () => context.push('/subscription'),
              icon: const Icon(Icons.manage_accounts_rounded, size: 16),
              label: const Text('Quản lý gói'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.gold,
                side: const BorderSide(color: AppColors.gold),
                minimumSize: const Size.fromHeight(44),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                textStyle:
                    const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),
            ),
        ],
      ),
    );
  }
}

class _LanguageCard extends ConsumerWidget {
  final AppLocalizations l;
  const _LanguageCard({required this.l});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          const Icon(Icons.language, color: AppColors.navy, size: 20),
          const SizedBox(width: 12),
          Text(
            l.profileLanguage,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: AppColors.navy,
            ),
          ),
          const Spacer(),
          LanguageSwitcher(
            activeColor: AppColors.navy,
            inactiveColor: AppColors.textSecondary,
          ),
        ],
      ),
    );
  }
}

class _AccountCard extends StatelessWidget {
  final AppLocalizations l;
  const _AccountCard({required this.l});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          _AccountTile(
            icon: Icons.person_outline,
            title: l.profileAccountInfo,
            isFirst: true,
          ),
          const Divider(height: 1, indent: 16),
          _AccountTile(
            icon: Icons.lock_outline,
            title: l.profileChangePassword,
            isLast: true,
          ),
        ],
      ),
    );
  }
}

class _AccountTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool isFirst;
  final bool isLast;

  const _AccountTile({
    required this.icon,
    required this.title,
    this.isFirst = false,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.vertical(
        top: isFirst ? const Radius.circular(12) : Radius.zero,
        bottom: isLast ? const Radius.circular(12) : Radius.zero,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, color: AppColors.navy, size: 20),
            const SizedBox(width: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 15,
                color: AppColors.textPrimary,
              ),
            ),
            const Spacer(),
            const Icon(Icons.chevron_right,
                color: AppColors.textSecondary, size: 20),
          ],
        ),
      ),
    );
  }
}

// ── Supply (Owner/Broker) Card ────────────────────────────────────────────────

class _SupplyCard extends ConsumerWidget {
  final WidgetRef ref;
  const _SupplyCard({required this.ref});

  @override
  Widget build(BuildContext context, WidgetRef widgetRef) {
    final role = widgetRef.watch(userRoleProvider);
    if (!role.isSupply) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.gold.withValues(alpha: 0.4)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.gold.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'Quản lý BĐS',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.gold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            InkWell(
              onTap: () => context.go('/my-listings'),
              borderRadius: const BorderRadius.vertical(),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 14),
                child: Row(
                  children: [
                    const Icon(Icons.storefront_outlined,
                        color: AppColors.navy, size: 20),
                    const SizedBox(width: 12),
                    const Text(
                      'Quản lý listing của tôi',
                      style: TextStyle(
                          fontSize: 15, color: AppColors.textPrimary),
                    ),
                    const Spacer(),
                    const Icon(Icons.chevron_right,
                        color: AppColors.textSecondary, size: 20),
                  ],
                ),
              ),
            ),
            const Divider(height: 1, indent: 16),
            InkWell(
              onTap: () => context.push('/listings/create'),
              borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 14),
                child: Row(
                  children: [
                    const Icon(Icons.add_business_outlined,
                        color: AppColors.gold, size: 20),
                    const SizedBox(width: 12),
                    const Text(
                      'Đăng listing mới',
                      style: TextStyle(
                          fontSize: 15, color: AppColors.textPrimary),
                    ),
                    const Spacer(),
                    const Icon(Icons.chevron_right,
                        color: AppColors.textSecondary, size: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
