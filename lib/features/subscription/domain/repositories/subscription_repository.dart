import '../models/plan_model.dart';
import '../models/subscription_model.dart';

abstract class SubscriptionRepository {
  Future<List<PlanModel>> getPlans();
  Future<SubscriptionModel?> getUserSubscription(String userId);
  Future<void> createFreeSubscription(String userId);
}
