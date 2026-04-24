import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_assets.dart';
import '../../../core/router/app_router.dart';

/// The initial "Get Start" screen shown before onboarding slides.
/// White background with centered cow illustration (slide 1 from your designs).
class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeIn);
    _slide = Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.splashGradient),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fade,
            child: SlideTransition(
              position: _slide,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 48),

                    // ── Title ────────────────────────────────────
                    Text(
                      'Welcome to',
                      style:
                          Theme.of(context).textTheme.headlineMedium?.copyWith(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w400,
                              ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Smart Farm\nAssistant',
                      textAlign: TextAlign.center,
                      style: Theme.of(context)
                          .textTheme
                          .displayMedium
                          ?.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.bold,
                            height: 1.15,
                          ),
                    ),

                    // ── Illustration ─────────────────────────────
                    Expanded(
                      child: _buildIllustration(size),
                    ),

                    // ── Tagline ───────────────────────────────────
                    Text(
                      AppStrings.tagline,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w500,
                            height: 1.45,
                          ),
                    ),

                    const SizedBox(height: 48),

                    // ── CTA Button ────────────────────────────────
                    ElevatedButton(
                      onPressed: () => context.go(AppRoutes.onboarding),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.white,
                        minimumSize: const Size(double.infinity, 56),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        AppStrings.getStarted,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: AppColors.white,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ),

                    const SizedBox(height: 48),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIllustration(Size size) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Grass oval base
        Positioned(
          bottom: 16,
          child: Container(
            width: 240,
            height: 54,
            decoration: BoxDecoration(
              color: AppColors.primaryLight.withOpacity(0.45),
              borderRadius: BorderRadius.circular(100),
            ),
          ),
        ),
        // Cow image
        Image.asset(
          AppAssets.splash,
          height: size.height * 0.26,
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => const Text(
            '🐄',
            style: TextStyle(fontSize: 100),
          ),
        ),
      ],
    );
  }
}
