import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_home/core/theme/app_theme.dart';
import 'package:smart_home/core/widgets/glass_container.dart';
import 'package:smart_home/core/utils/responsive.dart';
import 'package:smart_home/core/services/notification_service.dart';
import 'package:smart_home/features/settings/presentation/widgets/settings_row.dart';

class FcmTokenCard extends ConsumerWidget {
  const FcmTokenCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationService = ref.read(notificationServiceProvider.notifier);
    final isMobile = Responsive.isMobile(context);

    return GlassContainer(
      padding: EdgeInsets.all(isMobile ? 16 : 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              const Icon(
                Icons.notifications_active_outlined,
                color: AppTheme.primaryPurple,
                size: 24,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Firebase Cloud Messaging (FCM)',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isMobile ? 16 : 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // 1. Permission Status
          Consumer(builder: (context, ref, _) {
            final hasPermission = ref.watch(hasNotificationPermissionProvider);
            return SettingsRow(
              icon: Icons.security_outlined,
              title: 'Notification Status',
              subtitle: hasPermission
                  ? 'Authorized to show push alerts'
                  : 'Push notifications are disabled',
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: hasPermission
                      ? Colors.greenAccent.withValues(alpha: 0.1)
                      : Colors.redAccent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: hasPermission
                        ? Colors.greenAccent.withValues(alpha: 0.3)
                        : Colors.redAccent.withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  hasPermission ? 'Enabled' : 'Disabled',
                  style: TextStyle(
                    color: hasPermission ? Colors.greenAccent : Colors.redAccent,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            );
          }),

          const Divider(color: Colors.white10, height: 32),

          // 2. Request Permission (Only show if not authorized)
          Consumer(builder: (context, ref, _) {
            final hasPermission = ref.watch(hasNotificationPermissionProvider);
            if (hasPermission) return const SizedBox.shrink();

            return Column(
              children: [
                SettingsRow(
                  icon: Icons.add_moderator_outlined,
                  title: 'Request Permission',
                  subtitle: 'Enable system notifications for this app',
                  trailing: ElevatedButton(
                    onPressed: notificationService.requestPermission,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryPurple.withValues(alpha: 0.2),
                      foregroundColor: AppTheme.primaryPurple,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: const BorderSide(color: AppTheme.primaryPurple, width: 0.5),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Allow',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const Divider(color: Colors.white10, height: 32),
              ],
            );
          }),

          // 3. FCM Device Token Row
          Consumer(builder: (context, ref, _) {
            final token = ref.watch(fcmTokenProvider);
            final hasToken = token.isNotEmpty;

            // Shorten the token for display
            final displayToken = hasToken
                ? '${token.substring(0, 8)}...${token.substring(token.length - 8)}'
                : 'Retrieving token...';

            return SettingsRow(
              icon: Icons.key_outlined,
              title: 'Device Registration Token',
              subtitle: displayToken,
              trailing: IconButton(
                icon: const Icon(Icons.copy_outlined, color: AppTheme.primaryBlue),
                onPressed: hasToken ? notificationService.copyTokenToClipboard : null,
                tooltip: 'Copy Token',
              ),
            );
          }),
        ],
      ),
    );
  }
}
