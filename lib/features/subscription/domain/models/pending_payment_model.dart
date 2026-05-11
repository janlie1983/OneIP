import 'viet_qr_model.dart';

class PendingPaymentModel {
  final String id;
  final String userId;
  final String paymentType;
  final String? plan;
  final String? contentId;
  final int amountVnd;
  final String transferCode;
  final String status;
  final String? qrUrl;
  final DateTime expiresAt;
  final DateTime createdAt;

  const PendingPaymentModel({
    required this.id,
    required this.userId,
    required this.paymentType,
    this.plan,
    this.contentId,
    required this.amountVnd,
    required this.transferCode,
    required this.status,
    this.qrUrl,
    required this.expiresAt,
    required this.createdAt,
  });

  bool get isExpired => DateTime.now().isAfter(expiresAt);
  bool get isSuccess => status == 'success';
  Duration get remaining => expiresAt.difference(DateTime.now());

  VietQRConfig get vietQRConfig => VietQRConfig.fromEnv(
        amount: amountVnd,
        description: transferCode,
      );

  factory PendingPaymentModel.fromMap(Map<String, dynamic> map) {
    return PendingPaymentModel(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      paymentType: map['payment_type'] as String,
      plan: map['plan'] as String?,
      contentId: map['content_id'] as String?,
      amountVnd: (map['amount_vnd'] as num).toInt(),
      transferCode: map['transfer_code'] as String,
      status: map['status'] as String? ?? 'pending',
      qrUrl: map['qr_url'] as String?,
      expiresAt: DateTime.parse(map['expires_at'] as String),
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }
}
