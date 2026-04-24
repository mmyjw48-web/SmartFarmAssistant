import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/router/app_router.dart';
import '../models/livestock_model.dart';
import '../providers/livestock_provider.dart';

class DiagnosisResultScreen extends ConsumerWidget {
  final Map<String, dynamic> result;

  const DiagnosisResultScreen({super.key, required this.result});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final condition = result['condition'] as String? ?? 'Unknown';
    final riskStr  = result['risk'] as String? ?? 'Unknown';
    final actions  = List<String>.from(result['actions'] ?? []);
    final info     = result['info'] as String?;
    final risk     = RiskLevel.fromString(riskStr);

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: AppBar(
        title: const Text('Diagnosis Result'),
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
            // ── Risk Level Banner ─────────────────────────────
            _RiskBanner(risk: risk),

            const SizedBox(height: 20),

            // ── Possible Condition Card ───────────────────────
            _ResultCard(
              icon: Icons.coronavirus_outlined,
              iconColor: AppColors.primary,
              title: AppStrings.possibleCondition,
              child: Text(
                condition,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
              ),
            ),

            const SizedBox(height: 16),

            // ── Recommended Actions Card ──────────────────────
            _ResultCard(
              icon: Icons.checklist_outlined,
              iconColor: AppColors.teal,
              title: AppStrings.whatToDo,
              child: Column(
                children: actions
                    .asMap()
                    .entries
                    .map((e) => _ActionItem(
                          index: e.key + 1,
                          text: e.value,
                        ))
                    .toList(),
              ),
            ),

            // ── Additional Info ───────────────────────────────
            if (info != null && info.isNotEmpty) ...[
              const SizedBox(height: 16),
              _ResultCard(
                icon: Icons.info_outline,
                iconColor: AppColors.info,
                title: 'Additional Information',
                child: Text(
                  info,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        height: 1.5,
                        color: AppColors.textSecondary,
                      ),
                ),
              ),
            ],

            const SizedBox(height: 16),

            // ── Disclaimer ────────────────────────────────────
            _DisclaimerBox(),

            const SizedBox(height: 32),

            // ── Action Buttons ────────────────────────────────
            Row(
              children: [
                // Diagnose again
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      ref.read(livestockProvider.notifier).reset();
                      context.pop();
                    },
                    icon: const Icon(Icons.refresh_rounded, size: 20),
                    label: const Text(AppStrings.diagnoseAgain),
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
                // Back home
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      ref.read(livestockProvider.notifier).reset();
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
// Risk Level Banner
// ─────────────────────────────────────────────────────────────────────────
class _RiskBanner extends StatelessWidget {
  final RiskLevel risk;
  const _RiskBanner({required this.risk});

  Color get _color {
    switch (risk) {
      case RiskLevel.high:    return AppColors.riskHigh;
      case RiskLevel.medium:  return AppColors.riskMedium;
      case RiskLevel.low:     return AppColors.riskLow;
      case RiskLevel.unknown: return AppColors.grey400;
    }
  }

  IconData get _icon {
    switch (risk) {
      case RiskLevel.high:    return Icons.warning_rounded;
      case RiskLevel.medium:  return Icons.info_rounded;
      case RiskLevel.low:     return Icons.check_circle_rounded;
      case RiskLevel.unknown: return Icons.help_outline_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        color: _color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _color.withOpacity(0.4), width: 1.5),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: _color.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(_icon, color: _color, size: 26),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppStrings.riskLevel,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
              Text(
                risk.label,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: _color,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// Generic Result Card
// ─────────────────────────────────────────────────────────────────────────
class _ResultCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final Widget child;

  const _ResultCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card header
          Row(
            children: [
              Icon(icon, color: iconColor, size: 22),
              const SizedBox(width: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// Numbered Action Item
// ─────────────────────────────────────────────────────────────────────────
class _ActionItem extends StatelessWidget {
  final int index;
  final String text;

  const _ActionItem({required this.index, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Number badge
          Container(
            width: 26,
            height: 26,
            decoration: const BoxDecoration(
              color: AppColors.primaryPale,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$index',
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textPrimary,
                    height: 1.5,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// Disclaimer Box
// ─────────────────────────────────────────────────────────────────────────
class _DisclaimerBox extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.warning.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border:
            Border.all(color: AppColors.warning.withOpacity(0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.warning_amber_rounded,
              color: AppColors.warning, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'This diagnosis is AI-generated for guidance only. Always consult a licensed veterinarian for serious conditions.',
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
