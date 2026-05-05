import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../core/theme/app_colors.dart';
import '../features/auth/presentation/providers/auth_provider.dart';
import '../features/auth/presentation/screens/forgot_password_screen.dart';
import '../features/auth/presentation/screens/login_screen.dart';
import '../features/auth/presentation/screens/register_screen.dart';
import '../features/lease_tracker/presentation/screens/lease_tracker_screen.dart';
import '../features/permit_checklist/presentation/screens/permit_checklist_screen.dart';
import '../features/profile/presentation/screens/profile_screen.dart';
import '../features/site_selection/presentation/screens/site_selection_screen.dart';

class _AuthChangeNotifier extends ChangeNotifier {
  _AuthChangeNotifier(Ref ref) {
    ref.listen(authStateProvider, (prev, next) => notifyListeners());
  }
}

final _authChangeNotifierProvider = Provider<_AuthChangeNotifier>((ref) {
  return _AuthChangeNotifier(ref);
});

final routerProvider = Provider<GoRouter>((ref) {
  final notifier = ref.watch(_authChangeNotifierProvider);

  return GoRouter(
    refreshListenable: notifier,
    initialLocation: '/login',
    redirect: (context, state) {
      final authAsync = ref.read(authStateProvider);

      return authAsync.when(
        data: (authState) {
          final isAuthenticated = authState.session != null;
          final loc = state.matchedLocation;
          final isAuthRoute = loc == '/login' ||
              loc == '/register' ||
              loc == '/forgot-password';

          if (!isAuthenticated && !isAuthRoute) return '/login';
          if (isAuthenticated && isAuthRoute) return '/home/site-selection';
          return null;
        },
        loading: () => null,
        error: (err, stack) => '/login',
      );
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, s) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, s) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, s) => const ForgotPasswordScreen(),
      ),
      ShellRoute(
        builder: (context, s, child) => _HomeShell(child: child),
        routes: [
          GoRoute(
            path: '/home/site-selection',
            builder: (context, s) => const SiteSelectionScreen(),
          ),
          GoRoute(
            path: '/home/lease-tracker',
            builder: (context, s) => const LeaseTrackerScreen(),
          ),
          GoRoute(
            path: '/home/permit-checklist',
            builder: (context, s) => const PermitChecklistScreen(),
          ),
          GoRoute(
            path: '/home/profile',
            builder: (context, s) => const ProfileScreen(),
          ),
        ],
      ),
    ],
  );
});

class _HomeShell extends StatelessWidget {
  final Widget child;

  const _HomeShell({required this.child});

  int _tabIndex(BuildContext context) {
    final loc = GoRouterState.of(context).matchedLocation;
    switch (loc) {
      case '/home/site-selection':
        return 0;
      case '/home/lease-tracker':
        return 1;
      case '/home/permit-checklist':
        return 2;
      case '/home/profile':
        return 3;
      default:
        return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _tabIndex(context),
        onTap: (index) {
          switch (index) {
            case 0:
              context.go('/home/site-selection');
            case 1:
              context.go('/home/lease-tracker');
            case 2:
              context.go('/home/permit-checklist');
            case 3:
              context.go('/home/profile');
          }
        },
        selectedItemColor: AppColors.navy,
        unselectedItemColor: AppColors.textSecondary,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.location_city),
            label: 'Chọn địa điểm',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.trending_up),
            label: 'Giá thuê',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.checklist),
            label: 'Giấy phép',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Hồ sơ',
          ),
        ],
      ),
    );
  }
}
