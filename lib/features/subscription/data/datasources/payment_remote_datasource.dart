import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/config/supabase_config.dart';
import '../../domain/models/pending_payment_model.dart';

class PaymentRemoteDataSource {
  SupabaseClient get _client => SupabaseConfig.client;

  String _generateTransferCode(String userId) {
    final prefix = userId.replaceAll('-', '').substring(0, 6).toUpperCase();
    final suffix = (DateTime.now().millisecondsSinceEpoch % 10000)
        .toString()
        .padLeft(4, '0');
    return 'ONEIP$prefix$suffix';
  }

  Future<PendingPaymentModel> createPendingPayment({
    required String userId,
    required String type,
    String? plan,
    String? contentId,
    required int amountVnd,
  }) async {
    final transferCode = _generateTransferCode(userId);
    final expiresAt = DateTime.now().add(const Duration(minutes: 15));

    final data = await _client.from('pending_payments').insert({
      'user_id': userId,
      'payment_type': type,
      'plan': plan,
      'content_id': contentId,
      'amount_vnd': amountVnd,
      'transfer_code': transferCode,
      'status': 'pending',
      'expires_at': expiresAt.toIso8601String(),
    }).select().single();

    return PendingPaymentModel.fromMap(data);
  }

  Future<String> checkPaymentStatus(String paymentId) async {
    final data = await _client
        .from('pending_payments')
        .select('status')
        .eq('id', paymentId)
        .single();
    return data['status'] as String? ?? 'pending';
  }

  Stream<String> streamPaymentStatus(String paymentId) {
    return _client
        .from('pending_payments')
        .stream(primaryKey: ['id'])
        .eq('id', paymentId)
        .map((rows) {
          if (rows.isEmpty) return 'pending';
          return rows.first['status'] as String? ?? 'pending';
        });
  }
}
