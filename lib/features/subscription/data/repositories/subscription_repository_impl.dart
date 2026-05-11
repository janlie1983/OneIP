import '../../domain/models/plan_model.dart';
import '../../domain/models/subscription_model.dart';
import '../../domain/repositories/subscription_repository.dart';
import '../datasources/subscription_remote_datasource.dart';

class SubscriptionRepositoryImpl implements SubscriptionRepository {
  final SubscriptionRemoteDataSource _dataSource;

  SubscriptionRepositoryImpl(this._dataSource);

  @override
  Future<List<PlanModel>> getPlans() => _dataSource.getPlans();

  @override
  Future<SubscriptionModel?> getUserSubscription(String userId) =>
      _dataSource.getUserSubscription(userId);

  @override
  Future<void> createFreeSubscription(String userId) =>
      _dataSource.createFreeSubscription(userId);
}
