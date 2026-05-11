import 'env.dart';

class AppConfig {
  static String get bankCode => Env.bankCode;
  static String get bankAccountNumber => Env.bankAccountNumber;
  static String get bankAccountName => Env.bankAccountName;
  static String get bankName => Env.bankName;
}
