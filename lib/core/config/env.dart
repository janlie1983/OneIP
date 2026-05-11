import 'package:flutter_dotenv/flutter_dotenv.dart';

enum Flavor { development, production }

class Env {
  static Flavor _flavor = Flavor.development;

  static Future<void> load(Flavor flavor) async {
    _flavor = flavor;
    final fileName = flavor == Flavor.development
        ? '.env.development'
        : '.env.production';
    await dotenv.load(fileName: fileName);
  }

  static String get supabaseUrl => dotenv.env['SUPABASE_URL'] ?? '';
  static String get supabaseAnonKey => dotenv.env['SUPABASE_ANON_KEY'] ?? '';
  static String get bankCode => dotenv.env['BANK_CODE'] ?? '';
  static String get bankAccountNumber => dotenv.env['BANK_ACCOUNT_NUMBER'] ?? '';
  static String get bankAccountName => dotenv.env['BANK_ACCOUNT_NAME'] ?? '';
  static String get bankName => dotenv.env['BANK_NAME'] ?? '';
  static const String googleWebClientId = String.fromEnvironment(
    'GOOGLE_WEB_CLIENT_ID',
    defaultValue: '',
  );
  static Flavor get environment => _flavor;
  static bool get isDevelopment => _flavor == Flavor.development;
  static bool get isProduction => _flavor == Flavor.production;
}
