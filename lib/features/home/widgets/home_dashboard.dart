import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/router/app_router.dart';
import '../providers/home_provider.dart';
import 'feature_card.dart';
import 'quick_stat_card.dart';

/// The content shown when the Home tab is active.
/// Separated from HomeScreen (shell) so the shell can swap tab content.
class HomeDashboard extends ConsumerWidget {
  const HomeDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: CustomScrollView(
        slivers: [
          // ── Green header banner with greeting ───────────────
          _buildSliverHeader(context, userAsync),

          // ── Body content ────────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const SizedBox(height: 20),

                // ── Quick stats row ──────────────────────────
                _buildStatsRow(context),

                const SizedBox(height: 28),

                // ── Section label ────────────────────────────
                Text(
                  AppStrings.quickActions,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                ),

                const SizedBox(height: 16),

                // ── Feature cards grid ───────────────────────
                _buildFeatureGrid(context),

                const SizedBox(height: 28),

                // ── Tips banner ──────────────────────────────
                _buildTipsBanner(context),

                const SizedBox(height: 12),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  // ── Sliver app bar with green gradient header ──────────────────────
  Widget _buildSliverHeader(BuildContext context, AsyncValue userAsync) {
    return SliverAppBar(
      expandedHeight: 180,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: AppColors.primary,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.primary, AppColors.primaryLight],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Greeting row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Name greeting
                            userAsync.when(
                              data: (user) => Text(
                                '${AppStrings.homeGreeting} ${_firstName(user?.fullName)}! 👋',
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineSmall
                                    ?.copyWith(
                                      color: AppColors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              loading: () => Text(
                                '${AppStrings.homeGreeting} Farmer! 👋',
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineSmall
                                    ?.copyWith(
                                      color: AppColors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              error: (_, __) => const SizedBox.shrink(),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              AppStrings.homeSubtitle,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: AppColors.white.withOpacity(0.85),
                                  ),
                            ),
                          ],
                        ),
                      ),

                      // Avatar circle
                      userAsync.when(
                        data: (user) => _buildAvatar(user?.fullName),
                        loading: () => _buildAvatar(null),
                        error: (_, __) => _buildAvatar(null),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      // Collapsed title when scrolled
      title: Text(
        AppStrings.appName,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: AppColors.white,
              fontWeight: FontWeight.w600,
            ),
      ),
      titleSpacing: 20,
    );
  }

  Widget _buildAvatar(String? name) {
    final letter = (name?.isNotEmpty == true) ? name![0].toUpperCase() : 'F';
    return CircleAvatar(
      radius: 26,
      backgroundColor: AppColors.white.withOpacity(0.25),
      child: Text(
        letter,
        style: const TextStyle(
          color: AppColors.white,
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // ── Stats row ──────────────────────────────────────────────────────
  Widget _buildStatsRow(BuildContext context) {
    return Row(
      children: [
        QuickStatCard(
          label: 'AI Ready',
          value: 'Online',
          icon: Icons.psychology_outlined,
          color: AppColors.primary,
        ),
        const SizedBox(width: 12),
        QuickStatCard(
          label: 'Diagnoses',
          value: 'Active',
          icon: Icons.health_and_safety_outlined,
          color: AppColors.teal,
        ),
      ],
    );
  }

  // ── 2x2 feature cards grid ─────────────────────────────────────────
  Widget _buildFeatureGrid(BuildContext context) {
    final features = [
      _FeatureItem(
        title: 'Livestock\nDiagnosis',
        subtitle: 'Detect diseases early with AI analysis',
        icon: Icons.pets_outlined,
        color: AppColors.primary,
        iconBgColor: AppColors.primaryPale,
        route: AppRoutes.livestockForm,
      ),
      _FeatureItem(
        title: 'Crop\nAdvisor',
        subtitle: 'Get smart crop recommendations',
        icon: Icons.grass_outlined,
        color: AppColors.teal,
        iconBgColor: AppColors.tealPale,
        route: AppRoutes.cropInput,
      ),
      _FeatureItem(
        title: 'AI\nAssistant',
        subtitle: 'Chat with your smart farm advisor',
        icon: Icons.smart_toy_outlined,
        color: const Color(0xFF7B61FF),
        iconBgColor: const Color(0xFFF0EEFF),
        route: AppRoutes.chat,
      ),
      _FeatureItem(
        title: 'My\nProfile',
        subtitle: 'Manage your farm & account settings',
        icon: Icons.person_outline_rounded,
        color: const Color(0xFFFF8C42),
        iconBgColor: const Color(0xFFFFF3EB),
        route: AppRoutes.profile,
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        // childAspectRatio: 0.88,
        childAspectRatio: 0.83
      ),
      itemCount: features.length,
      itemBuilder: (context, i) => FeatureCard(
        title: features[i].title,
        subtitle: features[i].subtitle,
        icon: features[i].icon,
        color: features[i].color,
        iconBgColor: features[i].iconBgColor,
        onTap: () => context.push(features[i].route),
      ),
    );
  }

  // ── Tip of the day banner ──────────────────────────────────────────
  Widget _buildTipsBanner(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withOpacity(0.08),
            AppColors.teal.withOpacity(0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primaryPale,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.tips_and_updates_outlined,
              color: AppColors.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tip of the Day',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Early detection of livestock symptoms can prevent disease spread. Check your animals daily.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                        height: 1.4,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _firstName(String? fullName) {
    if (fullName == null || fullName.isEmpty) return 'Farmer';
    return fullName.split(' ').first;
  }
}

// ── Internal data class ────────────────────────────────────────────────
class _FeatureItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final Color iconBgColor;
  final String route;

  const _FeatureItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.iconBgColor,
    required this.route,
  });
}
