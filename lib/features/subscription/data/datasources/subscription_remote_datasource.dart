import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/config/supabase_config.dart';
import '../../domain/models/plan_model.dart';
import '../../domain/models/subscription_model.dart';

class SubscriptionRemoteDataSource {
  SupabaseClient get _client => SupabaseConfig.client;

  Future<List<PlanModel>> getPlans() async {
    final data = await _client
        .from('plans')
        .select()
        .eq('is_active', true)
        .order('price_usd');
    return (data as List).map((m) => PlanModel.fromMap(m)).toList();
  }

  Future<SubscriptionModel?> getUserSubscription(String userId) async {
    final data = await _client
        .from('subscriptions')
        .select()
        .eq('user_id', userId)
        .eq('status', 'active')
        .order('created_at', ascending: false)
        .limit(1)
        .maybeSingle();
    if (data == null) return null;
    return SubscriptionModel.fromMap(data);
  }

  Future<void> createFreeSubscription(String userId) async {
    await _client.from('subscriptions').insert({
      'user_id': userId,
      'plan': 'free',
      'status': 'active',
    });
  }
}
