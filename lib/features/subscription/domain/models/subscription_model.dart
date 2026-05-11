class SubscriptionModel {
  final String id;
  final String userId;
  final String plan;
  final String status;
  final String? paymentProvider;
  final String? stripeCustomerId;
  final String? stripeSubscriptionId;
  final String? vnpayTransactionId;
  final double? amountUsd;
  final int? amountVnd;
  final DateTime? currentPeriodStart;
  final DateTime? currentPeriodEnd;
  final bool cancelAtPeriodEnd;
  final DateTime? cancelledAt;
  final DateTime? trialEnd;
  final DateTime createdAt;
  final DateTime updatedAt;

  const SubscriptionModel({
    required this.id,
    required this.userId,
    required this.plan,
    required this.status,
    this.paymentProvider,
    this.stripeCustomerId,
    this.stripeSubscriptionId,
    this.vnpayTransactionId,
    this.amountUsd,
    this.amountVnd,
    this.currentPeriodStart,
    this.currentPeriodEnd,
    this.cancelAtPeriodEnd = false,
    this.cancelledAt,
    this.trialEnd,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isActive => status == 'active';
  bool get isPro => plan == 'pro' || plan == 'enterprise';
  int get daysRemaining =>
      currentPeriodEnd?.difference(DateTime.now()).inDays ?? 0;

  factory SubscriptionModel.fromMap(Map<String, dynamic> map) {
    return SubscriptionModel(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      plan: map['plan'] as String,
      status: map['status'] as String,
      paymentProvider: map['payment_provider'] as String?,
      stripeCustomerId: map['stripe_customer_id'] as String?,
      stripeSubscriptionId: map['stripe_subscription_id'] as String?,
      vnpayTransactionId: map['vnpay_transaction_id'] as String?,
      amountUsd: (map['amount_usd'] as num?)?.toDouble(),
      amountVnd: (map['amount_vnd'] as num?)?.toInt(),
      currentPeriodStart: map['current_period_start'] != null
          ? DateTime.parse(map['current_period_start'] as String)
          : null,
      currentPeriodEnd: map['current_period_end'] != null
          ? DateTime.parse(map['current_period_end'] as String)
          : null,
      cancelAtPeriodEnd: map['cancel_at_period_end'] as bool? ?? false,
      cancelledAt: map['cancelled_at'] != null
          ? DateTime.parse(map['cancelled_at'] as String)
          : null,
      trialEnd: map['trial_end'] != null
          ? DateTime.parse(map['trial_end'] as String)
          : null,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }
}
