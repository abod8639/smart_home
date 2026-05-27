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
          child:  ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              itemCount: kAppNavItems.length,
              separatorBuilder: (_, _) => const SizedBox(width: 4),
              itemBuilder: (context, i) {
                final item = kAppNavItems[i];
                final isActive =
                    controller.currentNavigationIndex.value == item.index;
                return AppNavigationButton(
                  icon: item.icon,
                  isActive: isActive,
                  onTap: () => controller.changeTab(item.index),
                  iconSize: 24,
                  padding: const EdgeInsets.all(8),
                );
              },
            ),
          
        ),
      ),
    );
  }
}

class AppNavigationButton extends StatelessWidget {
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;
  final double iconSize;
  final EdgeInsetsGeometry padding;

  const AppNavigationButton({
    super.key,
    required this.icon,
    required this.isActive,
    required this.onTap,
    this.iconSize = 28,
    this.padding = const EdgeInsets.all(12),
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: padding,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isActive
              ? Colors.white.withValues(alpha: 0.1)
              : Colors.transparent,
        ),
        child: Icon(
          icon,
          color: isActive ? Colors.white : AppTheme.textGrey,
          size: iconSize,
        ),
      ),
    );
  }
}
