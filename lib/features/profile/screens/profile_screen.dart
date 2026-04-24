import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/router/app_router.dart';
import '../../../shared/widgets/loading_overlay.dart';
import '../providers/profile_provider.dart';
import '../widgets/profile_widgets.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(profileProvider);

    // Show snackbars for success / error
    ref.listen(profileProvider, (prev, next) {
      if (next.successMessage != null &&
          next.successMessage != prev?.successMessage) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.successMessage!),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10)),
          ),
        );
        ref.read(profileProvider.notifier).clearMessages();
      }
      if (next.errorMessage != null &&
          next.errorMessage != prev?.errorMessage) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10)),
          ),
        );
        ref.read(profileProvider.notifier).clearMessages();
      }
    });

    return LoadingOverlay(
      isLoading: state.isLoading || state.isSaving,
      message: state.isSaving ? 'Saving...' : 'Loading profile...',
      child: Scaffold(
        backgroundColor: AppColors.scaffoldBg,
        body: state.isLoading
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.primary))
            : _buildBody(context, ref, state),
      ),
    );
  }

  Widget _buildBody(
      BuildContext context, WidgetRef ref, ProfileState state) {
    final user = state.user;

    return CustomScrollView(
      slivers: [
        // ── Green header ─────────────────────────────────────
        _buildSliverHeader(context, ref, state),

        // ── Content ──────────────────────────────────────────
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              const SizedBox(height: 20),

              // ── Account Info ────────────────────────────
              ProfileSectionCard(
                title: 'ACCOUNT INFO',
                children: [
                  ProfileInfoTile(
                    icon: Icons.person_outline_rounded,
                    label: 'Full Name',
                    value: user?.fullName ?? '—',
                  ),
                  ProfileInfoTile(
                    icon: Icons.email_outlined,
                    label: 'Email',
                    value: user?.email ?? '—',
                  ),
                  ProfileInfoTile(
                    icon: Icons.agriculture_outlined,
                    label: AppStrings.farmName,
                    value: (user?.farmName?.isNotEmpty == true)
                        ? user!.farmName!
                        : 'Not set',
                    onTap: () =>
                        _showEditFarmNameDialog(context, ref, state),
                  ),
                  ProfileInfoTile(
                    icon: Icons.calendar_today_outlined,
                    label: 'Member Since',
                    value: _formatDate(user?.createdAt),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // ── App Settings ────────────────────────────
              ProfileSectionCard(
                title: 'APP SETTINGS',
                children: [
                  SettingsRow(
                    icon: Icons.notifications_outlined,
                    label: AppStrings.notifications,
                    trailing: Switch(
                      value: true,
                      activeColor: AppColors.primary,
                      onChanged: (_) {},
                    ),
                  ),
                  SettingsRow(
                    icon: Icons.language_outlined,
                    label: AppStrings.language,
                    trailing: const Text(
                      'English',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                    onTap: () {},
                  ),
                  SettingsRow(
                    icon: Icons.dark_mode_outlined,
                    label: 'Dark Mode',
                    trailing: Switch(
                      value: false,
                      activeColor: AppColors.primary,
                      onChanged: (_) {},
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // ── About ────────────────────────────────────
              ProfileSectionCard(
                title: 'ABOUT',
                children: [
                  SettingsRow(
                    icon: Icons.info_outline_rounded,
                    label: AppStrings.aboutApp,
                    onTap: () => _showAboutDialog(context),
                  ),
                  SettingsRow(
                    icon: Icons.privacy_tip_outlined,
                    label: 'Privacy Policy',
                    onTap: () {},
                  ),
                  SettingsRow(
                    icon: Icons.star_outline_rounded,
                    label: 'Rate the App',
                    onTap: () {},
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // ── Logout ───────────────────────────────────
              ProfileSectionCard(
                children: [
                  SettingsRow(
                    icon: Icons.logout_rounded,
                    label: AppStrings.logout,
                    iconColor: AppColors.error,
                    textColor: AppColors.error,
                    trailing: const SizedBox.shrink(),
                    onTap: () => _showLogoutDialog(context, ref),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // ── Version ──────────────────────────────────
              Center(
                child: Text(
                  AppStrings.version,
                  style: const TextStyle(
                    color: AppColors.textHint,
                    fontSize: 12,
                  ),
                ),
              ),
            ]),
          ),
        ),
      ],
    );
  }

  // ── Sliver header with avatar ──────────────────────────────────────
  Widget _buildSliverHeader(
      BuildContext context, WidgetRef ref, ProfileState state) {
    final user = state.user;

    return SliverAppBar(
      expandedHeight: 220,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: AppColors.primary,
      automaticallyImplyLeading: false,
      title: Text(
        AppStrings.profileTitle,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: AppColors.white,
              fontWeight: FontWeight.w600,
            ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh_outlined, color: AppColors.white),
          onPressed: () =>
              ref.read(profileProvider.notifier).loadUser(),
          tooltip: 'Refresh',
        ),
      ],
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
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 48),
                // Avatar
                ProfileAvatar(
                  name: user?.fullName ?? 'Farmer',
                  radius: 44,
                ),
                const SizedBox(height: 14),
                // Name
                Text(
                  user?.fullName ?? 'Loading...',
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 4),
                // Farm name badge
                if (user?.farmName?.isNotEmpty == true)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.agriculture_rounded,
                            color: AppColors.white, size: 14),
                        const SizedBox(width: 5),
                        Text(
                          user!.farmName!,
                          style: const TextStyle(
                            color: AppColors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Edit Farm Name Dialog ──────────────────────────────────────────
  void _showEditFarmNameDialog(
      BuildContext context, WidgetRef ref, ProfileState state) {
    final ctrl =
        TextEditingController(text: state.user?.farmName ?? '');
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        title: const Text('Edit Farm Name'),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'e.g. Green Valley Farm',
            prefixIcon: Icon(Icons.agriculture_outlined),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await ref
                  .read(profileProvider.notifier)
                  .updateFarmName(ctrl.text);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  // ── Logout Confirmation Dialog ─────────────────────────────────────
  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        title: const Text('Log Out'),
        content: const Text(
            'Are you sure you want to log out of Smart Farm Assistant?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await ref.read(profileProvider.notifier).logout();
              if (context.mounted) context.go(AppRoutes.login);
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error),
            child: const Text('Log Out'),
          ),
        ],
      ),
    );
  }

  // ── About Dialog ──────────────────────────────────────────────────
  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: AppStrings.appName,
      applicationVersion: '1.0.0',
      applicationLegalese: '© 2025 SmartFarm AI - UIN Salatiga',
      children: [
        const SizedBox(height: 16),
        const Text(
          'An AI-powered smart farming assistant that helps farmers diagnose livestock diseases, '
          'recommend crops, and make data-driven agricultural decisions.',
        ),
      ],
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '—';
    return '${date.day}/${date.month}/${date.year}';
  }
}
