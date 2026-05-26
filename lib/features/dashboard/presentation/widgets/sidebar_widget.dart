import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_home/core/theme/app_theme.dart';
import 'package:smart_home/features/dashboard/presentation/controllers/dashboard_controller.dart';

class SidebarWidget extends GetView<DashboardController> {
  const SidebarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      margin: const EdgeInsets.only(right: 24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Top Navigation Icons
          Container(
            padding: const EdgeInsets.symmetric(vertical: 24),
            decoration: BoxDecoration(
              color: AppTheme.cardBackground.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(40),
            ),
            child: Column(
              children: [
                _buildNavItem(Icons.home_filled, 0),
                const SizedBox(height: 32),
                _buildNavItem(Icons.bolt, 1),
                const SizedBox(height: 32),
                _buildNavItem(Icons.storage, 2),
                const SizedBox(height: 32),
                _buildNavItem(Icons.notifications_none, 3),
                const SizedBox(height: 32),
                _buildNavItem(Icons.pie_chart_outline, 4),
                const SizedBox(height: 32),
                _buildNavItem(Icons.videocam_outlined, 5),
                const SizedBox(height: 32),
                _buildNavItem(Icons.settings_outlined, 6),
                const SizedBox(height: 32),
                const Icon(Icons.keyboard_arrow_down, color: AppTheme.textGrey),
              ],
            ),
          ),

          // Bottom Avatar and Logout
          Column(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    image: AssetImage('assets/images/user_avatar.png'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.red.withValues(alpha: 0.1),
                ),
                child: const Icon(Icons.logout, color: Colors.redAccent),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, int index) {
    return Obx(() {
      final isActive = controller.currentNavigationIndex.value == index;
      return GestureDetector(
        onTap: () => controller.changeTab(index),
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: isActive
              ? BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.1),
                )
              : null,
          child: Icon(
            icon,
            color: isActive ? Colors.white : AppTheme.textGrey,
            size: 28,
          ),
        ),
      );
    });
  }
}
