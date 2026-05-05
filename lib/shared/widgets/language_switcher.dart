import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/locale_provider.dart';
import '../../core/theme/app_colors.dart';

class LanguageSwitcher extends ConsumerWidget {
  final Color activeColor;
  final Color inactiveColor;

  const LanguageSwitcher({
    super.key,
    this.activeColor = AppColors.gold,
    this.inactiveColor = Colors.white54,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    final isVi = locale.languageCode == 'vi';

    return GestureDetector(
      onTap: () {
        final newLocale =
            isVi ? const Locale('en') : const Locale('vi');
        ref.read(localeProvider.notifier).setLocale(newLocale);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          border: Border.all(
            color: activeColor.withValues(alpha: 0.6),
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'VI',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: isVi ? activeColor : inactiveColor,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                '|',
                style: TextStyle(
                    fontSize: 12,
                    color: inactiveColor.withValues(alpha: 0.5)),
              ),
            ),
            Text(
              'EN',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: !isVi ? activeColor : inactiveColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
