import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/locale_service.dart';

class LocaleNotifier extends StateNotifier<Locale> {
  LocaleNotifier() : super(const Locale('vi')) {
    _init();
  }

  Future<void> _init() async {
    final locale = await LocaleService.loadLocale();
    if (mounted) state = locale;
  }

  Future<void> setLocale(Locale locale) async {
    state = locale;
    await LocaleService.saveLocale(locale.languageCode);
  }
}

final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>(
  (ref) => LocaleNotifier(),
);
