import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_home/core/theme/app_theme.dart';

class AppNavItem {
  final IconData icon;
  final int index;

  const AppNavItem({required this.icon, required this.index});
}

const List<AppNavItem> kAppNavItems = [
  AppNavItem(icon: Icons.home_rounded, index: 0),
  AppNavItem(icon: Icons.storage_rounded, index: 1),
  AppNavItem(icon: Icons.notifications_rounded, index: 2),
  AppNavItem(icon: Icons.pie_chart_rounded, index: 3),
  AppNavItem(icon: Icons.settings_rounded, index: 4),
];

class MobileBottomNav extends ConsumerWidget {
  final StatefulNavigationShell navigationShell;

  const MobileBottomNav({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      color: Colors.transparent, // Ensures scaffold bottom navigation background is transparent
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
      child: SafeArea(
        top: false,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
            child: Container(
              height: 72,
              decoration: BoxDecoration(
                color: AppTheme.cardBackground.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.08),
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.4),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: kAppNavItems.map((item) {
                  final isActive = navigationShell.currentIndex == item.index;
                  return AppNavigationButton(
                    icon: item.icon,
                    isActive: isActive,
                    onTap: () => navigationShell.goBranch(
                      item.index,
                      initialLocation: item.index == navigationShell.currentIndex,
                    ),
                    iconSize: 24,
                    padding: const EdgeInsets.all(10),
                  );
                }).toList(),
              ),
            ),
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
      child: AnimatedScale(
        scale: isActive ? 1.12 : 1.0,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutBack,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: padding,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: isActive
                ? const LinearGradient(
                    colors: [AppTheme.primaryPurple, AppTheme.primaryBlue],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            color: isActive
                ? null
                : Colors.white.withValues(alpha: 0.03),
            border: Border.all(
              color: isActive
                  ? Colors.white.withValues(alpha: 0.25)
                  : Colors.white.withValues(alpha: 0.05),
              width: 1.0,
            ),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: AppTheme.primaryPurple.withValues(alpha: 0.35),
                      blurRadius: 12,
                      spreadRadius: 1,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Icon(
            icon,
            color: isActive ? Colors.white : AppTheme.textGrey,
            size: iconSize,
          ),
        ),
      ),
    );
  }
}
