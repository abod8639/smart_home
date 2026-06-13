import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_home/core/utils/responsive.dart';
import 'package:smart_home/features/dashboard/presentation/widgets/sidebar_widget.dart';
import 'package:smart_home/features/dashboard/presentation/widgets/app_navigation.dart';
import 'package:smart_home/features/dashboard/presentation/controllers/dashboard_controller.dart';
import 'package:smart_home/features/dashboard/presentation/widgets/dashboard_main_view.dart';
import 'package:smart_home/features/settings/presentation/pages/settings_view.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // final gap = Responsive.contentGap(context);

    return Scaffold(
      body: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (!Responsive.isMobile(context)) ...[
              const SidebarWidget(),
              // SizedBox(width: gap),
            ],
            Expanded(child: _buildMainContent(ref)),
          ],
        ),
      ),
      bottomNavigationBar: Responsive.isMobile(context) ? const MobileBottomNav() : null,
    );
  }

  Widget _buildMainContent(WidgetRef ref) {
    final currentNavigationIndex = ref.watch(dashboardControllerProvider.select((state) => state.currentNavigationIndex));
    
    switch (currentNavigationIndex) {
      case 0:
        return const DashboardMainView();
      case 6:
        return const SettingsView();
      default:
        return _buildUnderConstructionView();
    }
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
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
