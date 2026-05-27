import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_home/core/theme/app_theme.dart';
import 'package:smart_home/features/dashboard/presentation/controllers/dashboard_controller.dart';

class AppNavItem {
  final IconData icon;
  final int index;

  const AppNavItem({required this.icon, required this.index});
}

const List<AppNavItem> kAppNavItems = [
  AppNavItem(icon: Icons.home_filled, index: 0),
  AppNavItem(icon: Icons.bolt, index: 1),
  AppNavItem(icon: Icons.storage, index: 2),
  AppNavItem(icon: Icons.notifications_none, index: 3),
  AppNavItem(icon: Icons.pie_chart_outline, index: 4),
  AppNavItem(icon: Icons.videocam_outlined, index: 5),
  AppNavItem(icon: Icons.settings_outlined, index: 6),
];

class AppNavigationRail extends GetView<DashboardController> {
  final double width;

  const AppNavigationRail({super.key, this.width = 72});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      color: Colors.transparent,
      child: Obx(
        () => Column(
          children: [
            const SizedBox(height: 16),
            Expanded(
              child: NavigationRail(
                extended: false,
                minWidth: width,
                backgroundColor: Colors.transparent,
                selectedIndex: controller.currentNavigationIndex.value,
                onDestinationSelected: controller.changeTab,
                labelType: NavigationRailLabelType.none,
                destinations: kAppNavItems
                    .map(
                      (item) => NavigationRailDestination(
                        icon: Icon(item.icon, color: AppTheme.textGrey),
                        selectedIcon: Icon(item.icon, color: Colors.white),
                        label: const Text(''),
                      ),
                    )
                    .toList(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image: AssetImage('assets/images/user_avatar.png'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Icon(
                    Icons.logout,
                    color: Colors.redAccent.withValues(alpha: 0.8),
                    size: 22,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MobileBottomNav extends GetView<DashboardController> {
  const MobileBottomNav({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardBackground.withValues(alpha: 0.95),
        border: Border(
          top: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            itemCount: kAppNavItems.length,
            separatorBuilder: (_, _) => const SizedBox(width: 4),
            itemBuilder: (context, i) {
              final item = kAppNavItems[i];
              final isActive =
                  controller.currentNavigationIndex.value == item.index;
              return _MobileNavButton(
                icon: item.icon,
                isActive: isActive,
                onTap: () => controller.changeTab(item.index),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _MobileNavButton extends StatelessWidget {
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;

  const _MobileNavButton({
    required this.icon,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 52,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: isActive
                ? Colors.white.withValues(alpha: 0.12)
                : Colors.transparent,
          ),
          child: Icon(
            icon,
            color: isActive ? Colors.white : AppTheme.textGrey,
            size: 26,
          ),
        ),
      ),
    );
  }
}
