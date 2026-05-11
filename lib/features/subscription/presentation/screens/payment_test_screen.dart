import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/config/supabase_config.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/payment_provider.dart';
import '../providers/subscription_provider.dart';

class PaymentTestScreen extends ConsumerWidget {
  const PaymentTestScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentPlan = ref.watch(currentPlanProvider);
    final subAsync = ref.watch(userSubscriptionProvider);
    final createSub = ref.watch(createSubscriptionPaymentProvider);
    final createPPV = ref.watch(createPPVPaymentProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: AppBar(
        title: const Text('Payment Test (DEV)'),
        backgroundColor: AppColors.navy,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _StatusCard(currentPlan: currentPlan, subAsync: subAsync),
            const SizedBox(height: 20),
            _TestButton(
              label: 'Test Subscription Payment (299,000đ)',
              icon: Icons.workspace_premium_rounded,
              color: AppColors.gold,
              isLoading: createSub.isLoading,
              onPressed: () async {
                try {
                  final payment = await ref
                      .read(createSubscriptionPaymentProvider.notifier)
                      .create('pro');
                  if (context.mounted) {
                    context.push('/payment', extra: payment);
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: $e')),
                    );
                  }
                }
              },
            ),
            const SizedBox(height: 12),
            _TestButton(
              label: 'Test PPV Payment (20,000đ)',
              icon: Icons.play_circle_outline_rounded,
              color: AppColors.navy,
              isLoading: createPPV.isLoading,
              onPressed: () async {
                try {
                  final payment = await ref
                      .read(createPPVPaymentProvider.notifier)
                      .create(contentId: 'test-content-001');
                  if (context.mounted) {
                    context.push('/payment', extra: payment);
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: $e')),
                    );
                  }
                }
              },
            ),
            const SizedBox(height: 12),
            _SimulateButton(ref: ref),
          ],
        ),
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  final String currentPlan;
  final AsyncValue subAsync;

  const _StatusCard({required this.currentPlan, required this.subAsync});

  @override
  Widget build(BuildContext context) {
    final planColor = currentPlan == 'free' ? AppColors.textSecondary : AppColors.gold;

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
          const Text(
            'Current Status',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: planColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: planColor.withValues(alpha: 0.4)),
                ),
                child: Text(
                  currentPlan.toUpperCase(),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: planColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          subAsync.when(
            data: (sub) {
              if (sub == null) {
                return const Text('No subscription found',
                    style: TextStyle(fontSize: 13, color: AppColors.textSecondary));
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Status: ${sub.status}',
                    style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                  ),
                  if (sub.currentPeriodEnd != null)
                    Text(
                      'Expires: ${sub.currentPeriodEnd!.toLocal().toString().substring(0, 10)}',
                      style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                    ),
                ],
              );
            },
            loading: () => const LinearProgressIndicator(),
            error: (e, _) => Text('Error: $e',
                style: const TextStyle(fontSize: 13, color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}

class _TestButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool isLoading;
  final VoidCallback onPressed;

  const _TestButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.isLoading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: isLoading ? null : onPressed,
      icon: isLoading
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
            )
          : Icon(icon, size: 18),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        minimumSize: const Size.fromHeight(52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        elevation: 0,
      ),
    );
  }
}

class _SimulateButton extends ConsumerWidget {
  const _SimulateButton({required this.ref});
  final WidgetRef ref;

  @override
  Widget build(BuildContext context, WidgetRef widgetRef) {
    return OutlinedButton.icon(
      onPressed: () => _simulateSuccess(context, widgetRef),
      icon: const Icon(Icons.science_rounded, size: 18),
      label: const Text('Simulate Payment Success (DEV)'),
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.purple,
        side: const BorderSide(color: Colors.purple),
        minimumSize: const Size.fromHeight(52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      ),
    );
  }

  Future<void> _simulateSuccess(BuildContext context, WidgetRef ref) async {
    final userId = ref.read(currentUserProvider)?.id;
    if (userId == null) return;

    try {
      final now = DateTime.now();
      await SupabaseConfig.client.from('subscriptions').upsert({
        'user_id': userId,
        'plan': 'pro',
        'status': 'active',
        'current_period_start': now.toIso8601String(),
        'current_period_end': now.add(const Duration(days: 30)).toIso8601String(),
      }, onConflict: 'user_id');

      ref.invalidate(userSubscriptionProvider);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Simulated Pro subscription activated!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }
}
