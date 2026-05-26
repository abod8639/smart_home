import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_home/core/theme/app_theme.dart';
import 'package:smart_home/core/widgets/glass_container.dart';
import 'package:smart_home/features/settings/presentation/controllers/settings_controller.dart';
import 'package:smart_home/features/settings/presentation/widgets/settings_row.dart';

class SafetyCard extends GetView<SettingsController> {
  const SafetyCard({super.key});

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Safety & Security',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),

          // Hub Auto-Backups Switch
          SettingsRow(
            icon: Icons.backup_outlined,
            title: 'Automatic Backups',
            subtitle: 'Daily system config save to cloud',
            trailing: Obx(() => Switch(
                  value: controller.autoBackups.value,
                  onChanged: (_) => controller.toggleAutoBackups(),
                  activeThumbColor: AppTheme.primaryBlue,
                  activeTrackColor: AppTheme.primaryBlue.withValues(alpha: 0.3),
                  inactiveThumbColor: AppTheme.textGrey,
                  inactiveTrackColor: Colors.white.withValues(alpha: 0.1),
                )),
          ),
          const Divider(color: Colors.white10, height: 24),

          // Security Lock Timeout Slider
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Security Lock Timeout',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Obx(() => Text(
                        '${controller.lockTimeout.value.round()} min',
                        style: const TextStyle(
                          color: AppTheme.primaryBlue,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      )),
                ],
              ),
              const SizedBox(height: 4),
              const Text(
                'Inactive duration before auto lock validation',
                style: TextStyle(color: AppTheme.textGrey, fontSize: 12),
              ),
              const SizedBox(height: 12),
              Obx(() => SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: Colors.white,
                      inactiveTrackColor: Colors.white.withValues(alpha: 0.1),
                      thumbColor: Colors.white,
                      overlayColor: Colors.white.withValues(alpha: 0.1),
                      trackHeight: 4,
                      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
                    ),
                    child: Slider(
                      value: controller.lockTimeout.value,
                      min: 1.0,
                      max: 30.0,
                      onChanged: (val) => controller.updateLockTimeout(val),
                    ),
                  )),
            ],
          ),
          const Spacer(),

          // Danger Zone / Reset Network Button
          GestureDetector(
            onTap: () => _showResetConfirmation(context),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: Colors.redAccent.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.redAccent.withValues(alpha: 0.2),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.restart_alt_outlined, color: Colors.redAccent, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'RESET SMART NETWORK',
                    style: TextStyle(
                      color: Colors.redAccent,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Danger zone reset dialog confirmation
  void _showResetConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppTheme.cardBackground,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: BorderSide(color: Colors.redAccent.withValues(alpha: 0.2)),
          ),
          title: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.redAccent),
              SizedBox(width: 10),
              Text(
                'Reset Smart Hub',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: const Text(
            'This will clear all connected Zigbee nodes, reset settings to defaults, and restart the network. This action cannot be undone.',
            style: TextStyle(color: AppTheme.textGrey, height: 1.4),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: AppTheme.textGrey)),
            ),
            TextButton(
              onPressed: () {
                // Mock reset action
                Navigator.pop(context);
                Get.snackbar(
                  'System Reset',
                  'Network reconfiguration has been triggered.',
                  backgroundColor: AppTheme.cardBackground.withValues(alpha: 0.8),
                  colorText: Colors.redAccent,
                  borderColor: Colors.redAccent.withValues(alpha: 0.2),
                  borderWidth: 1,
                  snackPosition: SnackPosition.BOTTOM,
                  maxWidth: 400,
                  margin: const EdgeInsets.only(bottom: 24),
                );
              },
              child: const Text(
                'Reset Hub',
                style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }
}
