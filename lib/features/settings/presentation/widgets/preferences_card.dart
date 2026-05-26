import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_home/core/theme/app_theme.dart';
import 'package:smart_home/core/widgets/glass_container.dart';
import 'package:smart_home/features/settings/presentation/controllers/settings_controller.dart';
import 'package:smart_home/features/settings/presentation/widgets/settings_row.dart';

class PreferencesCard extends GetView<SettingsController> {
  const PreferencesCard({super.key});

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'General Preferences',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),

          // Temperature Unit Option
          SettingsRow(
            icon: Icons.thermostat_outlined,
            title: 'Temperature Unit',
            subtitle: 'Choose Celsius or Fahrenheit',
            trailing: Obx(() => Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildToggleOption(
                      label: '°C',
                      isActive: controller.isCelsius.value,
                      onTap: () {
                        if (!controller.isCelsius.value) controller.toggleTempUnit();
                      },
                    ),
                    _buildToggleOption(
                      label: '°F',
                      isActive: !controller.isCelsius.value,
                      onTap: () {
                        if (controller.isCelsius.value) controller.toggleTempUnit();
                      },
                    ),
                  ],
                )),
          ),
          const Divider(color: Colors.white10, height: 32),

          // Voice Assistant Option
          SettingsRow(
            icon: Icons.mic_none_outlined,
            title: 'Voice Assistant',
            subtitle: 'Default hub controller assistant',
            trailing: Obx(() => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.05),
                    ),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: controller.selectedVoiceAssistant.value,
                      dropdownColor: AppTheme.cardBackground,
                      icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white70),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                      onChanged: (val) {
                        if (val != null) {
                          controller.selectVoiceAssistant(val);
                        }
                      },
                      items: controller.voiceAssistants.map((assistant) {
                        return DropdownMenuItem(
                          value: assistant,
                          child: Text(assistant),
                        );
                      }).toList(),
                    ),
                  ),
                )),
          ),
          const Divider(color: Colors.white10, height: 32),

          // Push Notifications Option
          SettingsRow(
            icon: Icons.notifications_none_outlined,
            title: 'Push Notifications',
            subtitle: 'Alerts for device safety and changes',
            trailing: Obx(() => Switch(
                  value: controller.notificationsEnabled.value,
                  onChanged: (_) => controller.toggleNotifications(),
                  activeThumbColor: AppTheme.primaryBlue,
                  activeTrackColor: AppTheme.primaryBlue.withValues(alpha: 0.3),
                  inactiveThumbColor: AppTheme.textGrey,
                  inactiveTrackColor: Colors.white.withValues(alpha: 0.1),
                )),
          ),
        ],
      ),
    );
  }

  // Segmented selection toggle button
  Widget _buildToggleOption({
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? Colors.white : Colors.black.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.black : Colors.white70,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
