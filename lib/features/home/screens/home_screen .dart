import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/router/app_router.dart';
import '../../auth/providers/auth_provider.dart';
import '../../chat/screens/chat_screen.dart';
import '../../crops/screens/crop_input_screen.dart';
import '../../livestock/screens/livestock_form_screen.dart';
import '../../profile/screens/profile_screen.dart';
import '../providers/home_provider.dart';
import '../widgets/home_dashboard.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {

  // ── The 5 tab bodies ─────────────────────────────────────────────
  static const List<Widget> _tabScreens = [
    HomeDashboard(),
    CropInputScreen(),
    LivestockFormScreen(),
    ChatScreen(),
    ProfileScreen(),
  ];

  void _onTabTapped(int index) {
    ref.read(bottomNavIndexProvider.notifier).state = index;
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = ref.watch(bottomNavIndexProvider);

    return Scaffold(
      // ── Tab body ───────────────────────────────────────────────
      body: IndexedStack(
        index: currentIndex,
        children: _tabScreens,
      ),

      // ── Bottom Navigation Bar ──────────────────────────────────
      bottomNavigationBar: _buildBottomNav(context, currentIndex),
    );
  }

  Widget _buildBottomNav(BuildContext context, int currentIndex) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          height: 68,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                context,
                index: 0,
                currentIndex: currentIndex,
                icon: Icons.home_outlined,
                activeIcon: Icons.home_rounded,
                label: AppStrings.navHome,
              ),
              _buildNavItem(
                context,
                index: 1,
                currentIndex: currentIndex,
                icon: Icons.grass_outlined,
                activeIcon: Icons.grass_rounded,
                label: AppStrings.navCrops,
              ),
              // ── Center FAB-style Livestock button ─────────────
              _buildCenterNavItem(context, currentIndex),
              _buildNavItem(
                context,
                index: 3,
                currentIndex: currentIndex,
                icon: Icons.chat_bubble_outline_rounded,
                activeIcon: Icons.chat_bubble_rounded,
                label: AppStrings.navChat,
              ),
              _buildNavItem(
                context,
                index: 4,
                currentIndex: currentIndex,
                icon: Icons.person_outline_rounded,
                activeIcon: Icons.person_rounded,
                label: AppStrings.navProfile,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Regular nav item ───────────────────────────────────────────────
  Widget _buildNavItem(
    BuildContext context, {
    required int index,
    required int currentIndex,
    required IconData icon,
    required IconData activeIcon,
    required String label,
  }) {
    final isActive = currentIndex == index;

    return Expanded(
      child: GestureDetector(
        onTap: () => _onTabTapped(index),
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: isActive
                    ? AppColors.primaryPale
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                isActive ? activeIcon : icon,
                color: isActive ? AppColors.primary : AppColors.grey400,
                size: 24,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight:
                    isActive ? FontWeight.w600 : FontWeight.normal,
                color: isActive ? AppColors.primary : AppColors.grey400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Center raised livestock button ─────────────────────────────────
  Widget _buildCenterNavItem(BuildContext context, int currentIndex) {
    final isActive = currentIndex == 2;

    return Expanded(
      child: GestureDetector(
        onTap: () => _onTabTapped(2),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Raised circle with shadow
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 45,
              height: 45,
              decoration: BoxDecoration(
                color: isActive ? AppColors.primary : AppColors.primaryLight,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.35),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                Icons.pets_rounded,
                color: AppColors.white,
                size: 26,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              AppStrings.navLivestock,
              style: TextStyle(
                fontSize: 11,
                fontWeight:
                    isActive ? FontWeight.w600 : FontWeight.normal,
                color: isActive ? AppColors.primary : AppColors.grey400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
