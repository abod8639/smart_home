import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_home/core/theme/app_theme.dart';
import 'package:smart_home/core/widgets/glass_container.dart';
import 'package:smart_home/core/utils/responsive.dart';
import 'package:smart_home/features/settings/presentation/controllers/settings_controller.dart';
import 'package:smart_home/features/settings/presentation/widgets/settings_row.dart';
import 'package:smart_home/features/settings/presentation/widgets/matter_commissioning_dialog.dart';

class GoogleHomeCard extends GetView<SettingsController> {
  const GoogleHomeCard({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);

    return GlassContainer(
      padding: EdgeInsets.all(isMobile ? 16 : 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card Header with Google branding color accents
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    const Icon(
                      Icons.home_outlined,
                      color: AppTheme.accentCyan,
                      size: 24,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Google Home Services',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: isMobile ? 16 : 18,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Simulated Google dots
              Row(
                children: [
                  _buildGoogleDot(Colors.blueAccent),
                  const SizedBox(width: 4),
                  _buildGoogleDot(Colors.redAccent),
                  const SizedBox(width: 4),
                  _buildGoogleDot(Colors.amberAccent),
                  const SizedBox(width: 4),
                  _buildGoogleDot(Colors.greenAccent),
                ],
              )
            ],
          ),
          const SizedBox(height: 20),

          // 1. Google Account Binding Row
          Obx(() {
            final isLinked = controller.isGoogleLinked.value;
            final isSyncing = controller.isSyncing.value;

            return SettingsRow(
              icon: Icons.account_circle_outlined,
              title: 'Google Account',
              subtitle: isLinked
                  ? controller.googleEmail.value
                  : 'Link with Google Smart Home',
              trailing: isSyncing
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(AppTheme.accentCyan),
                      ),
                    )
                  : ElevatedButton(
                      onPressed: controller.toggleGoogleLink,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isLinked
                            ? Colors.white.withValues(alpha: 0.1)
                            : AppTheme.primaryBlue.withValues(alpha: 0.2),
                        foregroundColor: isLinked ? Colors.white : AppTheme.accentCyan,
                        padding: EdgeInsets.symmetric(horizontal: isMobile ? 10 : 14, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: isLinked
                                ? Colors.white24
                                : AppTheme.accentCyan.withValues(alpha: 0.3),
                          ),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        isLinked ? 'Disconnect' : 'Connect',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ),
            );
          }),

          const Divider(color: Colors.white10, height: 32),

          // 2. Google Home Graph Sync
          Obx(() {
            final isLinked = controller.isGoogleLinked.value;
            final isSyncing = controller.isSyncing.value;

            return Opacity(
              opacity: isLinked ? 1.0 : 0.4,
              child: SettingsRow(
                icon: Icons.sync_outlined,
                title: 'Sync Smart Devices',
                subtitle: 'Last synced: ${controller.lastSyncTime.value}',
                trailing: isSyncing && isLinked
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(AppTheme.accentCyan),
                        ),
                      )
                    : IconButton(
                        icon: const Icon(Icons.refresh, color: Colors.white70),
                        onPressed: isLinked ? controller.syncGoogleDevices : null,
                      ),
              ),
            );
          }),

          const Divider(color: Colors.white10, height: 32),

          // 3. Matter Commissioning (Adding new device)
          Obx(() {
            final isLinked = controller.isGoogleLinked.value;

            return Opacity(
              opacity: isLinked ? 1.0 : 0.4,
              child: SettingsRow(
                icon: Icons.grid_3x3_outlined,
                title: 'Commission Matter Device',
                subtitle: 'Setup a new certified Matter device',
                trailing: ElevatedButton(
                  onPressed: isLinked
                      ? () => _openMatterCommissioning(context)
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isLinked
                        ? AppTheme.accentCyan.withValues(alpha: 0.15)
                        : Colors.white.withValues(alpha: 0.05),
                    foregroundColor: isLinked ? AppTheme.accentCyan : Colors.white24,
                    padding: EdgeInsets.symmetric(horizontal: isMobile ? 10 : 14, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.add, size: 14),
                      SizedBox(width: 4),
                      Text(
                        'Setup Node',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildGoogleDot(Color color) {
    return Container(
      width: 6,
      height: 6,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }

  void _openMatterCommissioning(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const MatterCommissioningDialog(),
    );
  }
}
