import '../../../../core/config/app_config.dart';

class VietQRConfig {
  final String bankCode;
  final String accountNumber;
  final String accountName;
  final int amount;
  final String description;

  const VietQRConfig({
    required this.bankCode,
    required this.accountNumber,
    required this.accountName,
    required this.amount,
    required this.description,
  });

  String get qrUrl =>
      'https://img.vietqr.io/image/$bankCode-$accountNumber-compact2.png'
      '?amount=$amount'
      '&addInfo=${Uri.encodeComponent(description)}'
      '&accountName=${Uri.encodeComponent(accountName)}';

  factory VietQRConfig.fromEnv({
    required int amount,
    required String description,
  }) {
    return VietQRConfig(
      bankCode: AppConfig.bankCode,
      accountNumber: AppConfig.bankAccountNumber,
      accountName: AppConfig.bankAccountName,
      amount: amount,
      description: description,
    );
  }
}
