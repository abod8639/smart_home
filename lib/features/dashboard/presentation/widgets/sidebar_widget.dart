import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_home/core/theme/app_theme.dart';
import 'package:smart_home/core/utils/responsive.dart';
import 'package:smart_home/core/services/auth_service.dart';
import 'package:smart_home/core/widgets/app_network_image.dart';
import 'package:smart_home/features/dashboard/presentation/widgets/app_navigation.dart';

class SidebarWidget extends ConsumerWidget {
  final StatefulNavigationShell navigationShell;

  const SidebarWidget({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final width = Responsive.sidebarWidth(context) ?? 80.0;
    
    return SizedBox(
      width: width,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
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
                          for (final item in kAppNavItems) ...[
                            AppNavigationButton(
                              icon: item.icon,
                              isActive: navigationShell.currentIndex == item.index,
                              onTap: () => navigationShell.goBranch(
                                item.index,
                                initialLocation: item.index == navigationShell.currentIndex,
                              ),
                            ),
                            const SizedBox(height: 32),
                          ],
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
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            image: DecorationImage(
                              image: getAppImageProvider(
                                'https://avatars.githubusercontent.com/u/108903062?v=4',
                              ),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        GestureDetector(
                          onTap: () => ref.read(authServiceProvider.notifier).signOut(),
                          child: Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.red.withValues(alpha: 0.1),
                            ),
                            child: const Icon(Icons.logout, color: Colors.redAccent),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
