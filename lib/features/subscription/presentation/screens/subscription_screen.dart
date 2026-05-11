import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/subscription_provider.dart';
import '../widgets/plan_card.dart';

class SubscriptionScreen extends ConsumerStatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  ConsumerState<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends ConsumerState<SubscriptionScreen> {
  String? _selectedPlan;

  @override
  Widget build(BuildContext context) {
    final plansAsync = ref.watch(plansProvider);
    final currentPlan = ref.watch(currentPlanProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Nâng cấp OneIP Pro'),
        backgroundColor: AppColors.navy,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: plansAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Text('Lỗi tải dữ liệu: $e',
              style: const TextStyle(color: AppColors.error)),
        ),
        data: (plans) => SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _CurrentPlanBadge(plan: currentPlan),
              const SizedBox(height: 24),
              const Text(
                'Chọn gói phù hợp',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.navy,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Nâng cấp để mở khóa đầy đủ tính năng',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 420,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  clipBehavior: Clip.none,
                  itemCount: plans.length,
                  separatorBuilder: (context, i) => const SizedBox(width: 12),
                  itemBuilder: (context, i) {
                    final planItem = plans[i];
                    return PlanCard(
                      plan: planItem,
                      isCurrentPlan: planItem.name == currentPlan,
                      isSelected: _selectedPlan == planItem.name,
                      isRecommended: planItem.isPro,
                      onSelect: () {
                        if (planItem.name != currentPlan) {
                          setState(() => _selectedPlan = planItem.name);
                        }
                      },
                    );
                  },
                ),
              ),
              if (_selectedPlan != null &&
                  _selectedPlan != currentPlan) ...[
                const SizedBox(height: 32),
                _PaymentSection(selectedPlan: _selectedPlan!),
              ],
              const SizedBox(height: 24),
              const Center(
                child: Text(
                  'Hủy bất cứ lúc nào. Không hoàn tiền sau 7 ngày.',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _CurrentPlanBadge extends StatelessWidget {
  final String plan;

  const _CurrentPlanBadge({required this.plan});

  @override
  Widget build(BuildContext context) {
    final isPro = plan == 'pro' || plan == 'enterprise';
    final color = isPro ? AppColors.gold : AppColors.textSecondary;
    final label = switch (plan) {
      'pro' => 'Pro',
      'enterprise' => 'Enterprise',
      _ => 'Free',
    };

    return Row(
      children: [
        Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: color.withValues(alpha: 0.4)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isPro
                    ? Icons.workspace_premium_rounded
                    : Icons.account_circle_outlined,
                size: 14,
                color: color,
              ),
              const SizedBox(width: 6),
              Text(
                'Gói hiện tại: $label',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PaymentSection extends StatelessWidget {
  final String selectedPlan;

  const _PaymentSection({required this.selectedPlan});

  String get _planLabel => switch (selectedPlan) {
        'pro' => 'Pro (299,000đ/tháng)',
        'enterprise' => 'Enterprise (\$99/tháng)',
        _ => selectedPlan,
      };

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Thanh toán cho gói $_planLabel',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.navy,
          ),
        ),
        const SizedBox(height: 16),
        _PaymentButton(
          label: 'Thanh toán bằng thẻ quốc tế',
          subtitle: 'Visa, Mastercard qua Stripe',
          icon: Icons.credit_card_rounded,
          onTap: () {},
        ),
        const SizedBox(height: 12),
        _PaymentButton(
          label: 'Thanh toán qua VNPay',
          subtitle: 'Thẻ nội địa, ví điện tử',
          icon: Icons.account_balance_rounded,
          onTap: () {},
        ),
      ],
    );
  }
}

class _PaymentButton extends StatelessWidget {
  final String label;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const _PaymentButton({
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.navy.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: AppColors.navy, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.navy,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios,
                size: 14, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}
