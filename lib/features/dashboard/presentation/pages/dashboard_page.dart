import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_home/features/dashboard/presentation/widgets/sidebar_widget.dart';
import 'package:smart_home/features/dashboard/presentation/controllers/dashboard_controller.dart';
import 'package:smart_home/features/dashboard/presentation/widgets/dashboard_main_view.dart';
import 'package:smart_home/features/settings/presentation/pages/settings_view.dart';

class DashboardPage extends GetView<DashboardController> {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Row(
            children: [
              // 1. Sidebar Navigation
              const SidebarWidget(),

              // 2. Main Content Area (Dynamic View Swapping)
              Expanded(
                child: Obx(() {
                  switch (controller.currentNavigationIndex.value) {
                    case 0:
                      return const DashboardMainView();
                    case 6:
                      return const SettingsView();
                    default:
                      return _buildUnderConstructionView();
                  }
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUnderConstructionView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.construction_outlined,
            size: 64,
            color: Colors.orangeAccent.withValues(alpha: 0.8),
          ),
          const SizedBox(height: 24),
          const Text(
            'Section Under Construction',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'This feature is being configured for your smart home setup.',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
