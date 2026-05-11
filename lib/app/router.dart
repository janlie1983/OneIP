import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/theme/app_colors.dart';
import '../features/auth/presentation/providers/auth_provider.dart';
import '../features/auth/presentation/screens/forgot_password_screen.dart';
import '../features/auth/presentation/screens/login_screen.dart';
import '../features/auth/presentation/screens/register_incentive_screen.dart';
import '../features/auth/presentation/screens/register_screen.dart';
import '../features/home/presentation/screens/home_screen.dart';
import '../features/home/presentation/screens/splash_screen.dart';
import '../features/lease_tracker/presentation/screens/lease_tracker_screen.dart';
import '../features/permit_checklist/domain/models/user_checklist_model.dart';
import '../features/permit_checklist/presentation/screens/checklist_detail_screen.dart';
import '../features/permit_checklist/presentation/screens/permit_checklist_screen.dart';
import '../features/permit_checklist/presentation/screens/template_selector_screen.dart';
import '../features/profile/presentation/screens/profile_screen.dart';
import '../features/site_selection/domain/models/industrial_zone_model.dart';
import '../features/site_selection/presentation/screens/compare_screen.dart';
import '../features/site_selection/presentation/screens/site_selection_screen.dart';
import '../features/site_selection/presentation/screens/zone_detail_screen.dart';
import '../features/subscription/domain/models/pending_payment_model.dart';
import '../features/subscription/presentation/screens/payment_screen.dart';
import '../features/subscription/presentation/screens/payment_test_screen.dart';
import '../features/subscription/presentation/screens/subscription_screen.dart';
import '../l10n/app_localizations.dart';

// ── Transitions ───────────────────────────────────────────────────────────────

CustomTransitionPage<void> _fadePage(LocalKey key, Widget child) =>
    CustomTransitionPage(
      key: key,
      child: child,
      transitionDuration: const Duration(milliseconds: 220),
      transitionsBuilder: (context, animation, secondaryAnimation, child) =>
          FadeTransition(opacity: animation, child: child),
    );

CustomTransitionPage<void> _slideUpPage(LocalKey key, Widget child) =>
    CustomTransitionPage(
      key: key,
      child: child,
      transitionDuration: const Duration(milliseconds: 300),
      transitionsBuilder: (context, animation, secondaryAnimation, child) =>
          SlideTransition(
        position: Tween(begin: const Offset(0, 0.07), end: Offset.zero)
            .animate(CurvedAnimation(parent: animation, curve: Curves.easeOut)),
        child: FadeTransition(opacity: animation, child: child),
      ),
    );

// ── Auth notifier ─────────────────────────────────────────────────────────────

class _AuthChangeNotifier extends ChangeNotifier {
  _AuthChangeNotifier(Ref ref) {
    ref.listen(authStateProvider, (prev, next) => notifyListeners());
  }
}

final _authChangeNotifierProvider = Provider<_AuthChangeNotifier>((ref) {
  return _AuthChangeNotifier(ref);
});

// ── Router ────────────────────────────────────────────────────────────────────

final routerProvider = Provider<GoRouter>((ref) {
  final notifier = ref.watch(_authChangeNotifierProvider);

  return GoRouter(
    refreshListenable: notifier,
    initialLocation: '/splash',
    redirect: (context, state) {
      final authAsync = ref.read(authStateProvider);

      return authAsync.when(
        data: (authState) {
          final isAuthenticated = authState.session != null;
          final loc = state.matchedLocation;

          final isPublicRoute = loc == '/splash' ||
              loc == '/' ||
              loc == '/login' ||
              loc == '/register' ||
              loc == '/register-incentive' ||
              loc == '/forgot-password' ||
              loc.startsWith('/auth/') ||
              loc == '/subscription' ||
              loc.startsWith('/zones') ||
              loc.startsWith('/zone-detail');

          final isAuthRoute = loc == '/login' ||
              loc == '/register' ||
              loc == '/forgot-password' ||
              loc.startsWith('/auth/');

          // Block unauthenticated users from protected routes — show value first
          if (!isAuthenticated && !isPublicRoute) {
            final encoded = Uri.encodeComponent(loc);
            return '/register-incentive?redirect=$encoded';
          }

          // Authenticated users leaving auth screens go to the app
          if (isAuthenticated && isAuthRoute) return '/home/site-selection';

          return null;
        },
        loading: () => null,
        error: (err, stack) => '/',
      );
    },
    routes: [
      // ── Splash ──────────────────────────────────────────────────────────────
      GoRoute(
        path: '/splash',
        pageBuilder: (_, s) => _fadePage(s.pageKey, const SplashScreen()),
      ),

      // ── Public landing ───────────────────────────────────────────────────────
      GoRoute(
        path: '/',
        pageBuilder: (_, s) => _fadePage(s.pageKey, const HomeScreen()),
      ),

      // ── Auth ────────────────────────────────────────────────────────────────
      GoRoute(
        path: '/register-incentive',
        pageBuilder: (_, s) => _slideUpPage(
          s.pageKey,
          RegisterIncentiveScreen(
            redirect: s.uri.queryParameters['redirect'],
          ),
        ),
      ),
      GoRoute(
        path: '/login',
        pageBuilder: (_, s) => _slideUpPage(
          s.pageKey,
          LoginScreen(redirect: s.uri.queryParameters['redirect']),
        ),
      ),
      GoRoute(
        path: '/register',
        pageBuilder: (_, s) => _slideUpPage(
          s.pageKey,
          RegisterScreen(redirect: s.uri.queryParameters['redirect']),
        ),
      ),
      GoRoute(
        path: '/forgot-password',
        pageBuilder: (_, s) =>
            _slideUpPage(s.pageKey, const ForgotPasswordScreen()),
      ),
      GoRoute(
        path: '/auth/callback',
        builder: (_, s) => const _AuthCallbackScreen(),
      ),

      // ── Semi-public zone routes ──────────────────────────────────────────────
      GoRoute(
        path: '/zones',
        pageBuilder: (_, s) =>
            _fadePage(s.pageKey, const SiteSelectionScreen()),
      ),
      GoRoute(
        path: '/zones/:zoneId',
        pageBuilder: (_, s) => _fadePage(
          s.pageKey,
          ZoneDetailScreen(
            zoneId: s.pathParameters['zoneId']!,
            zone: s.extra as IndustrialZone?,
          ),
        ),
      ),
      GoRoute(
        path: '/zone-detail/:zoneId',
        pageBuilder: (_, s) => _fadePage(
          s.pageKey,
          ZoneDetailScreen(
            zoneId: s.pathParameters['zoneId']!,
            zone: s.extra as IndustrialZone?,
          ),
        ),
      ),
      GoRoute(
        path: '/zone-compare',
        pageBuilder: (_, s) => _fadePage(s.pageKey, const CompareScreen()),
      ),

      // ── Subscription ─────────────────────────────────────────────────────────
      GoRoute(
        path: '/subscription',
        pageBuilder: (_, s) =>
            _fadePage(s.pageKey, const SubscriptionScreen()),
      ),
      GoRoute(
        path: '/payment',
        pageBuilder: (_, s) => _slideUpPage(
          s.pageKey,
          PaymentScreen(payment: s.extra as PendingPaymentModel),
        ),
      ),
      GoRoute(
        path: '/dev/payment-test',
        builder: (_, s) => const PaymentTestScreen(),
      ),

      // ── Permit ──────────────────────────────────────────────────────────────
      GoRoute(
        path: '/permit-templates',
        pageBuilder: (_, s) =>
            _fadePage(s.pageKey, const TemplateSelectorScreen()),
      ),
      GoRoute(
        path: '/checklist-detail/:checklistId',
        pageBuilder: (_, s) => _fadePage(
          s.pageKey,
          ChecklistDetailScreen(
            checklistId: s.pathParameters['checklistId']!,
            checklist: s.extra as UserChecklist?,
          ),
        ),
      ),

      // ── Protected shell (auth required) ─────────────────────────────────────
      ShellRoute(
        builder: (context, s, child) => _HomeShell(child: child),
        routes: [
          GoRoute(
            path: '/home/site-selection',
            builder: (_, s) => const SiteSelectionScreen(),
          ),
          GoRoute(
            path: '/home/lease-tracker',
            builder: (_, s) => const LeaseTrackerScreen(),
          ),
          GoRoute(
            path: '/home/permit-checklist',
            builder: (_, s) => const PermitChecklistScreen(),
          ),
          GoRoute(
            path: '/home/profile',
            builder: (_, s) => const ProfileScreen(),
          ),
        ],
      ),
    ],
  );
});

// ── Auth callback ─────────────────────────────────────────────────────────────

class _AuthCallbackScreen extends StatefulWidget {
  const _AuthCallbackScreen();

  @override
  State<_AuthCallbackScreen> createState() => _AuthCallbackScreenState();
}

class _AuthCallbackScreenState extends State<_AuthCallbackScreen> {
  @override
  void initState() {
    super.initState();
    _exchangeCode();
  }

  Future<void> _exchangeCode() async {
    final uri = GoRouterState.of(context).uri;
    try {
      await Supabase.instance.client.auth.getSessionFromUrl(uri);
    } catch (_) {}
    if (mounted) context.go('/home/site-selection');
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}

// ── Home shell ────────────────────────────────────────────────────────────────

class _HomeShell extends StatelessWidget {
  final Widget child;
  const _HomeShell({required this.child});

  int _tabIndex(BuildContext context) {
    final loc = GoRouterState.of(context).matchedLocation;
    if (loc.startsWith('/home/lease-tracker')) return 1;
    if (loc.startsWith('/home/permit-checklist')) return 2;
    if (loc.startsWith('/home/profile')) return 3;
    return 0;
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
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.location_city),
            label: AppLocalizations.of(context)?.navSiteSelection ?? 'Chọn địa điểm',
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.trending_up),
            label: AppLocalizations.of(context)?.navLeaseTracker ?? 'Giá thuê',
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.checklist),
            label: AppLocalizations.of(context)?.navPermitChecklist ?? 'Giấy phép',
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.person),
            label: AppLocalizations.of(context)?.navProfile ?? 'Hồ sơ',
          ),
        ],
      ),
    );
  }
}
