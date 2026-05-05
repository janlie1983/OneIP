import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/config/supabase_config.dart';

class SupabaseService {
  static SupabaseClient get client => SupabaseConfig.client;
}
