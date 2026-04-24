import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';

// ── Screen imports (will be created in later phases) ──────────────
// Onboarding
import '../../features/onboarding/screens/splash_screen.dart';
import '../../features/onboarding/screens/welcome_screen.dart';
import '../../features/onboarding/screens/onboarding_screen.dart';
// Auth
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/register_screen.dart';
// Home shell
// import '../../features/home/screens/home_screen.dart';
import 'package:smart_farm_assistant/features/home/screens/home_screen%20.dart';

// Livestock
import '../../features/livestock/screens/livestock_form_screen.dart';
import '../../features/livestock/screens/diagnosis_result_screen.dart';
// Crops
import '../../features/crops/screens/crop_input_screen.dart';
import '../../features/crops/screens/crop_result_screen.dart';
// Chat
import '../../features/chat/screens/chat_screen.dart';
// Profile
import '../../features/profile/screens/profile_screen.dart';

/// All route name constants — use these instead of raw strings.
class AppRoutes {
  AppRoutes._();

  static const String splash          = '/';
  static const String welcome         = '/welcome';
  static const String onboarding      = '/onboarding';
  static const String login           = '/login';
  static const String register        = '/register';
  static const String home            = '/home';
  static const String livestockForm   = '/livestock/form';
  static const String diagnosisResult = '/livestock/result';
  static const String cropInput       = '/crops/input';
  static const String cropResult      = '/crops/result';
  static const String chat            = '/chat';
  static const String profile         = '/profile';
}

/// App router singleton.
/// Uses [FirebaseAuth] stream to redirect unauthenticated users to login.
final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.splash,
  debugLogDiagnostics: true,

  // ── Auth redirect guard ──────────────────────────────────────────
  redirect: (BuildContext context, GoRouterState state) {
    final user = FirebaseAuth.instance.currentUser;
    final isLoggedIn = user != null;

    final publicRoutes = [
      AppRoutes.splash,
      AppRoutes.welcome,
      AppRoutes.onboarding,
      AppRoutes.login,
      AppRoutes.register,
    ];

    final isOnPublicRoute = publicRoutes.contains(state.matchedLocation);

    // Not logged in and trying to access protected route → go to login
    if (!isLoggedIn && !isOnPublicRoute) {
      return AppRoutes.login;
    }

    // Already logged in and going to login/register → go to home
    if (isLoggedIn &&
        (state.matchedLocation == AppRoutes.login ||
            state.matchedLocation == AppRoutes.register)) {
      return AppRoutes.home;
    }

    return null; // no redirect
  },

  // ── Routes ────────────────────────────────────────────────────────
  routes: [
    // Onboarding flow
    GoRoute(
      path: AppRoutes.splash,
      name: 'splash',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: AppRoutes.welcome,
      name: 'welcome',
      builder: (context, state) => const WelcomeScreen(),
    ),
    GoRoute(
      path: AppRoutes.onboarding,
      name: 'onboarding',
      builder: (context, state) => const OnboardingScreen(),
    ),

    // Auth flow
    GoRoute(
      path: AppRoutes.login,
      name: 'login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: AppRoutes.register,
      name: 'register',
      builder: (context, state) => const RegisterScreen(),
    ),

    // Main app (home shell with bottom nav)
    GoRoute(
      path: AppRoutes.home,
      name: 'home',
      builder: (context, state) => const HomeScreen(),
    ),

    // Livestock feature
    GoRoute(
      path: AppRoutes.livestockForm,
      name: 'livestockForm',
      builder: (context, state) => const LivestockFormScreen(),
    ),
    GoRoute(
      path: AppRoutes.diagnosisResult,
      name: 'diagnosisResult',
      builder: (context, state) {
        // Pass the AI result map as extra
        final result = state.extra as Map<String, dynamic>?;
        return DiagnosisResultScreen(result: result ?? {});
      },
    ),

    // Crops feature
    GoRoute(
      path: AppRoutes.cropInput,
      name: 'cropInput',
      builder: (context, state) => const CropInputScreen(),
    ),
    GoRoute(
      path: AppRoutes.cropResult,
      name: 'cropResult',
      builder: (context, state) {
        final result = state.extra as Map<String, dynamic>?;
        return CropResultScreen(result: result ?? {});
      },
    ),

    // Chat
    GoRoute(
      path: AppRoutes.chat,
      name: 'chat',
      builder: (context, state) => const ChatScreen(),
    ),

    // Profile
    GoRoute(
      path: AppRoutes.profile,
      name: 'profile',
      builder: (context, state) => const ProfileScreen(),
    ),
  ],

  // ── Error page ────────────────────────────────────────────────────
  errorBuilder: (context, state) => Scaffold(
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            'Page not found',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => context.go(AppRoutes.home),
            child: const Text('Go Home'),
          ),
        ],
      ),
    ),
  ),
);
