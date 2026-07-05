import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_home/core/utils/responsive.dart';
import 'package:smart_home/features/dashboard/presentation/widgets/sidebar_widget.dart';
import 'package:smart_home/features/dashboard/presentation/widgets/app_navigation.dart';

class DashboardPage extends ConsumerWidget {
  final StatefulNavigationShell navigationShell;

  const DashboardPage({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (!Responsive.isMobile(context)) ...[
              SidebarWidget(navigationShell: navigationShell),
            ],
            Expanded(child: navigationShell),
          ],
        ),
      ),
      bottomNavigationBar: Responsive.isMobile(context)
          ? MobileBottomNav(navigationShell: navigationShell)
          : null,
    );
  }
}
