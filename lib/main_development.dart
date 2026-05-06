import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app/app.dart';
import 'core/config/env.dart';
import 'core/config/supabase_config.dart';
import 'core/utils/auth_callback_handler.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Env.load(Flavor.development);
  await SupabaseConfig.initialize();
  await AuthCallbackHandler.initialize();
  runApp(const ProviderScope(child: App()));
}
