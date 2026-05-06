import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthCallbackHandler {
  static StreamSubscription<Uri>? _sub;

  static Future<void> initialize() async {
    if (kIsWeb) return;

    final appLinks = AppLinks();

    final initialUri = await appLinks.getInitialLink();
    if (initialUri != null) {
      await _handleUri(initialUri);
    }

    _sub = appLinks.uriLinkStream.listen(
      _handleUri,
      onError: (_) {},
    );
  }

  static Future<void> _handleUri(Uri uri) async {
    if (uri.scheme == 'io.supabase.oneip') {
      await Supabase.instance.client.auth.getSessionFromUrl(uri);
    }
  }

  static void dispose() {
    _sub?.cancel();
    _sub = null;
  }
}
