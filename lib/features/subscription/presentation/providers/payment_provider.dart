import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/datasources/payment_remote_datasource.dart';
import '../../domain/models/pending_payment_model.dart';

final paymentDatasourceProvider = Provider<PaymentRemoteDataSource>((ref) {
  return PaymentRemoteDataSource();
});

final pendingPaymentProvider = StateProvider<PendingPaymentModel?>((ref) => null);

// Streams status for a specific payment ID via Supabase realtime
final paymentStatusProvider =
    StreamProvider.family<String, String>((ref, paymentId) {
  return ref.read(paymentDatasourceProvider).streamPaymentStatus(paymentId);
});

// AsyncNotifier: create a subscription payment
final createSubscriptionPaymentProvider = AsyncNotifierProvider<
    CreateSubscriptionPaymentNotifier, PendingPaymentModel?>(
  CreateSubscriptionPaymentNotifier.new,
);

class CreateSubscriptionPaymentNotifier
    extends AsyncNotifier<PendingPaymentModel?> {
  @override
  Future<PendingPaymentModel?> build() async => null;

  Future<PendingPaymentModel> create(String plan) async {
    state = const AsyncLoading();
    final userId = ref.read(currentUserProvider)?.id;
    if (userId == null) throw Exception('Not authenticated');

    final payment = await ref.read(paymentDatasourceProvider).createPendingPayment(
          userId: userId,
          type: 'subscription',
          plan: plan,
          amountVnd: 299000,
        );
    state = AsyncData(payment);
    ref.read(pendingPaymentProvider.notifier).state = payment;
    return payment;
  }
}

// AsyncNotifier: create a pay-per-view payment
final createPPVPaymentProvider =
    AsyncNotifierProvider<CreatePPVPaymentNotifier, PendingPaymentModel?>(
  CreatePPVPaymentNotifier.new,
);

class CreatePPVPaymentNotifier extends AsyncNotifier<PendingPaymentModel?> {
  @override
  Future<PendingPaymentModel?> build() async => null;

  Future<PendingPaymentModel> create({String? contentId}) async {
    state = const AsyncLoading();
    final userId = ref.read(currentUserProvider)?.id;
    if (userId == null) throw Exception('Not authenticated');

    final payment = await ref.read(paymentDatasourceProvider).createPendingPayment(
          userId: userId,
          type: 'ppv',
          contentId: contentId,
          amountVnd: 20000,
        );
    state = AsyncData(payment);
    ref.read(pendingPaymentProvider.notifier).state = payment;
    return payment;
  }
}
