import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/config/supabase_config.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/datasources/subscription_remote_datasource.dart';
import '../../data/repositories/subscription_repository_impl.dart';
import '../../domain/models/plan_model.dart';
import '../../domain/models/subscription_model.dart';
import '../../domain/repositories/subscription_repository.dart';

final subscriptionRepositoryProvider = Provider<SubscriptionRepository>((ref) {
  return SubscriptionRepositoryImpl(SubscriptionRemoteDataSource());
});

final plansProvider = FutureProvider<List<PlanModel>>((ref) {
  return ref.watch(subscriptionRepositoryProvider).getPlans();
});

final userSubscriptionProvider = FutureProvider<SubscriptionModel?>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return Future.value(null);
  return ref.watch(subscriptionRepositoryProvider).getUserSubscription(user.id);
});

final currentPlanProvider = Provider<String>((ref) {
  return ref.watch(userSubscriptionProvider).whenOrNull(
            data: (sub) => sub?.plan,
          ) ??
      'free';
});

final isProProvider = Provider<bool>((ref) {
  return ref.watch(userSubscriptionProvider).whenOrNull(
            data: (sub) => sub?.isPro,
          ) ??
      false;
});

final canExportPdfProvider = Provider<bool>((ref) => ref.watch(isProProvider));

final canViewRealTimeDataProvider =
    Provider<bool>((ref) => ref.watch(isProProvider));

final maxChecklistsProvider = Provider<int>((ref) {
  return ref.watch(isProProvider) ? -1 : 1;
});

final maxAlertsProvider = Provider<int>((ref) {
  return ref.watch(isProProvider) ? -1 : 2;
});

// Checks if current user has active PPV access for a given content ID
final ppvAccessProvider =
    FutureProvider.family<bool, String>((ref, contentId) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return false;
  final data = await SupabaseConfig.client
      .from('ppv_access')
      .select()
      .eq('user_id', user.id)
      .eq('content_id', contentId)
      .gt('expires_at', DateTime.now().toIso8601String())
      .maybeSingle();
  return data != null;
});
