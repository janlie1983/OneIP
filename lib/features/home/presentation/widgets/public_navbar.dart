import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/providers/locale_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class PublicNavbar extends ConsumerStatefulWidget implements PreferredSizeWidget {
  final bool isScrolled;

  const PublicNavbar({super.key, this.isScrolled = false});

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  ConsumerState<PublicNavbar> createState() => _PublicNavbarState();
}

class _PublicNavbarState extends ConsumerState<PublicNavbar> {
  bool _menuOpen = false;

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.sizeOf(context).width >= 720;
    final authAsync = ref.watch(authStateProvider);
    final isLoggedIn = authAsync.whenOrNull(data: (s) => s.session != null) ?? false;
    final locale = ref.watch(localeProvider);
    final isVi = locale.languageCode == 'vi';

    final isScrolled = widget.isScrolled;

    return AppBar(
      backgroundColor: AppColors.navy,
      elevation: isScrolled ? 4 : 0,
      shadowColor: Colors.black38,
      toolbarHeight: 64,
      leading: GestureDetector(
        onTap: () => context.go('/'),
        child: Padding(
          padding: const EdgeInsets.only(left: 16),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.gold,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: Text(
                    '1',
                    style: TextStyle(
                      color: AppColors.navy,
                      fontWeight: FontWeight.w900,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'OneIP',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                ),
              ),
            ],
          ),
        ),
      ),
      leadingWidth: 120,
      actions: isWide
          ? _wideActions(context, isLoggedIn, isVi)
          : _mobileActions(context, isLoggedIn, isVi),
    );
  }

  List<Widget> _wideActions(
      BuildContext context, bool isLoggedIn, bool isVi) {
    return [
      _NavLink(label: isVi ? 'Tìm KCN' : 'Find IZ', onTap: () => context.go('/')),
      _NavLink(label: isVi ? 'Giá thuê' : 'Rates', onTap: () => context.go('/')),
      _NavLink(label: isVi ? 'Giấy phép' : 'Permits', onTap: () => context.go('/')),
      const SizedBox(width: 8),
      _LangToggle(isVi: isVi),
      const SizedBox(width: 8),
      if (isLoggedIn) ...[
        FilledButton(
          onPressed: () => context.go('/home/site-selection'),
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.gold,
            foregroundColor: AppColors.navy,
          ),
          child: Text(isVi ? 'Vào app' : 'Open App'),
        ),
      ] else ...[
        TextButton(
          onPressed: () => context.go('/login'),
          style: TextButton.styleFrom(foregroundColor: Colors.white),
          child: Text(isVi ? 'Đăng nhập' : 'Sign In'),
        ),
        FilledButton(
          onPressed: () => context.go('/register'),
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.gold,
            foregroundColor: AppColors.navy,
          ),
          child: Text(isVi ? 'Đăng ký' : 'Sign Up'),
        ),
      ],
      const SizedBox(width: 16),
    ];
  }

  List<Widget> _mobileActions(
      BuildContext context, bool isLoggedIn, bool isVi) {
    return [
      _LangToggle(isVi: isVi),
      IconButton(
        icon: Icon(_menuOpen ? Icons.close : Icons.menu, color: Colors.white),
        onPressed: () => setState(() => _menuOpen = !_menuOpen),
      ),
    ];
  }
}

class _NavLink extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _NavLink({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onTap,
      style: TextButton.styleFrom(
        foregroundColor: Colors.white70,
        padding: const EdgeInsets.symmetric(horizontal: 12),
      ),
      child: Text(label, style: const TextStyle(fontSize: 14)),
    );
  }
}

class _LangToggle extends ConsumerWidget {
  final bool isVi;
  const _LangToggle({required this.isVi});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () {
        ref.read(localeProvider.notifier).setLocale(
              isVi ? const Locale('en') : const Locale('vi'),
            );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white30),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          isVi ? 'VI' : 'EN',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
