import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/router/app_router.dart';
import '../models/crop_model.dart';
import '../providers/crop_provider.dart';
import '../widgets/crop_widgets.dart';

class CropResultScreen extends ConsumerWidget {
  final Map<String, dynamic> result;

  const CropResultScreen({super.key, required this.result});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Parse result from router extra
    final rawCrops = result['crops'] as List<dynamic>? ?? [];
    final generalAdvice = result['general_advice'] as String? ?? '';
    final risks = result['risks'] as String? ?? '';

    final crops = rawCrops.map((c) {
      final map = c as Map<String, dynamic>;
      return CropRecommendation(
        name: map['name'] as String? ?? '',
        suitability: Suitability.fromString(map['suitability'] as String? ?? ''),
        reason: map['reason'] as String? ?? '',
        tips: map['tips'] as String? ?? '',
      );
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: AppBar(
        title: const Text(AppStrings.recommendedCrops),
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header banner ──────────────────────────────────
            _HeaderBanner(cropCount: crops.length),

            const SizedBox(height: 24),

            // ── Crop Cards ─────────────────────────────────────
            if (crops.isNotEmpty) ...[
              Text(
                AppStrings.recommendedCrops,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 14),
              ...crops.asMap().entries.map(
                    (e) => CropResultCard(
                      crop: e.value,
                      index: e.key + 1,
                    ),
                  ),
            ] else ...[
              _EmptyCropsBox(),
            ],

            const SizedBox(height: 8),

            // ── General Advice Card ────────────────────────────
            if (generalAdvice.isNotEmpty) ...[
              _InfoCard(
                icon: Icons.tips_and_updates_outlined,
                iconColor: AppColors.primary,
                title: AppStrings.plantingTips,
                content: generalAdvice,
                bgColor: AppColors.primaryPale,
              ),
              const SizedBox(height: 14),
            ],

            // ── Risks Card ─────────────────────────────────────
            if (risks.isNotEmpty) ...[
              _InfoCard(
                icon: Icons.warning_amber_outlined,
                iconColor: AppColors.riskMedium,
                title: 'Risks to Watch For',
                content: risks,
                bgColor: AppColors.riskMedium.withOpacity(0.06),
              ),
              const SizedBox(height: 14),
            ],

            // ── Disclaimer ─────────────────────────────────────
            _DisclaimerBox(),

            const SizedBox(height: 32),

            // ── Action Buttons ─────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      ref.read(cropProvider.notifier).reset();
                      context.pop();
                    },
                    icon: const Icon(Icons.refresh_rounded, size: 20),
                    label: const Text('Try Again'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      ref.read(cropProvider.notifier).reset();
                      context.go(AppRoutes.home);
                    },
                    icon: const Icon(Icons.home_rounded, size: 20),
                    label: const Text(AppStrings.backHome),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// Header Banner
// ─────────────────────────────────────────────────────────────────────────
class _HeaderBanner extends StatelessWidget {
  final int cropCount;
  const _HeaderBanner({required this.cropCount});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.teal, AppColors.primary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.eco_rounded,
                color: AppColors.white, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AI Analysis Complete',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Found $cropCount suitable crops for your farm',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.white.withOpacity(0.9),
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// Info Card (General Advice / Risks)
// ─────────────────────────────────────────────────────────────────────────
class _InfoCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String content;
  final Color bgColor;

  const _InfoCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.content,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: iconColor.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            content,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  height: 1.5,
                  color: AppColors.textSecondary,
                ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// Empty State
// ─────────────────────────────────────────────────────────────────────────
class _EmptyCropsBox extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Icon(Icons.grass_outlined, size: 56, color: AppColors.grey400),
          const SizedBox(height: 12),
          Text(
            'No specific crops found',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Try adjusting your farm conditions.',
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// Disclaimer
// ─────────────────────────────────────────────────────────────────────────
class _DisclaimerBox extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.info.withOpacity(0.07),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.info.withOpacity(0.25)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline, color: AppColors.info, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'These recommendations are AI-generated based on the conditions you provided. Consult a local agronomist for best results.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
