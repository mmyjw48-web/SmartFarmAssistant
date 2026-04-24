import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../models/onboarding_data.dart';

/// One slide inside the onboarding PageView.
/// Matches the designs: top illustration, bold title, bullet checkmarks.
class OnboardingCard extends StatelessWidget {
  final OnboardingData data;

  const OnboardingCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        children: [
          // ── Illustration ──────────────────────────────────────
          SizedBox(
            height: size.height * 0.32,
            child: Image.asset(
              data.imagePath,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => _fallbackIllustration(context),
            ),
          ),

          const SizedBox(height: 32),

          // ── Bold Title ────────────────────────────────────────
          Text(
            data.title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                  height: 1.2,
                ),
          ),

          const SizedBox(height: 28),

          // ── Bullet Points (slides 1 & 2) ──────────────────────
          if (data.bulletPoints.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: data.bulletPoints
                  .map((point) => _buildBullet(context, point))
                  .toList(),
            ),

          // ── Body text (slide 3 – AI role) ─────────────────────
          if (data.bodyText != null)
            Text(
              data.bodyText!,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.6,
                    fontSize: 17,
                  ),
            ),
        ],
      ),
    );
  }

  Widget _buildBullet(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Green checkmark circle
          Container(
            width: 28,
            height: 28,
            decoration: const BoxDecoration(
              color: AppColors.primaryLight,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check,
              color: AppColors.white,
              size: 16,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.textPrimary,
                    height: 1.4,
                    fontSize: 16,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _fallbackIllustration(BuildContext context) {
    const icons = [
      Icons.pets,
      Icons.wb_sunny_outlined,
      Icons.psychology_outlined,
    ];
    return Icon(
      icons[0],
      size: 120,
      color: AppColors.primary.withOpacity(0.6),
    );
  }
}
