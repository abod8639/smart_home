import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_home/core/theme/app_theme.dart';
import 'package:smart_home/core/widgets/glass_container.dart';
import 'package:smart_home/features/settings/presentation/controllers/settings_controller.dart';

class SettingsView extends GetView<SettingsController> {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Page Title & Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Settings',
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                        fontSize: 28,
                        letterSpacing: 0.5,
                      ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Configure your smart home network & preferences',
                  style: TextStyle(color: AppTheme.textGrey, fontSize: 14),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.greenAccent.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.greenAccent.withValues(alpha: 0.2),
                ),
              ),
              child: const Row(
                children: [
                  Icon(Icons.wifi, color: Colors.greenAccent, size: 16),
                  SizedBox(width: 8),
                  Text(
                    'Hub Connected',
                    style: TextStyle(
                      color: Colors.greenAccent,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Main Content Row
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left Column: Profile & General Preferences
              Expanded(
                flex: 4,
                child: Column(
                  children: [
                    // Profile Card
                    _buildProfileCard(context),
                    const SizedBox(height: 24),
                    // General Preferences Card
                    Expanded(
                      child: _buildPreferencesCard(context),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 24),

              // Right Column: Hub Configuration & Safety Systems
              Expanded(
                flex: 5,
                child: Column(
                  children: [
                    // Hub Settings Panel
                    _buildHubConfigCard(context),
                    const SizedBox(height: 24),
                    // System Security and Action Card
                    Expanded(
                      child: _buildSafetyCard(context),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Profile Card Widget
  Widget _buildProfileCard(BuildContext context) {
    return GlassContainer(
      child: Row(
        children: [
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    image: AssetImage('assets/images/user_avatar.png'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  color: Colors.greenAccent,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppTheme.cardBackground,
                    width: 2,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Obx(() => Text(
                      controller.userName.value,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    )),
                const SizedBox(height: 4),
                Obx(() => Text(
                      controller.userRole.value,
                      style: const TextStyle(
                        color: AppTheme.textGrey,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.5,
                      ),
                    )),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: AppTheme.primaryBlue),
            onPressed: () => _showEditProfileDialog(context),
          ),
        ],
      ),
    );
  }

  // Preferences Card Widget
  Widget _buildPreferencesCard(BuildContext context) {
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
          _buildSettingsRow(
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
          _buildSettingsRow(
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
          _buildSettingsRow(
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

  // Smart Hub Configuration Widget
  Widget _buildHubConfigCard(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Smart Hub Status',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Icon(
                Icons.hub_outlined,
                color: AppTheme.accentCyan.withValues(alpha: 0.8),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Horizontal Info Rows
          Row(
            children: [
              Expanded(
                child: _buildInfoGridItem(
                  label: 'HUB IP ADDRESS',
                  value: '192.168.1.145',
                  icon: Icons.dns_outlined,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildInfoGridItem(
                  label: 'ACTIVE NODES',
                  value: '12 Devices',
                  icon: Icons.device_hub,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildInfoGridItem(
                  label: 'FIRMWARE',
                  value: 'v2.4.1 (Latest)',
                  icon: Icons.security_outlined,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Connection Protocol Switch
          const Text(
            'Primary Hub Protocol',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Obx(() => Row(
                children: controller.connectionModes.map((mode) {
                  final isSelected = controller.hubConnectionMode.value == mode;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: GestureDetector(
                        onTap: () => controller.selectConnectionMode(mode),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            gradient: isSelected
                                ? const LinearGradient(
                                    colors: [
                                      AppTheme.primaryPurple,
                                      AppTheme.primaryBlue,
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  )
                                : null,
                            color: isSelected
                                ? null
                                : Colors.black.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSelected
                                  ? Colors.transparent
                                  : Colors.white.withValues(alpha: 0.05),
                            ),
                          ),
                          child: Center(
                            child: Text(
                              mode,
                              style: TextStyle(
                                color: isSelected ? Colors.white : AppTheme.textGrey,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              )),
        ],
      ),
    );
  }

  // System Safety & Warning Action Card
  Widget _buildSafetyCard(BuildContext context) {
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
          _buildSettingsRow(
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

  // Helper row layout for settings details
  Widget _buildSettingsRow({
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget trailing,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppTheme.textGrey, size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(
                  color: AppTheme.textGrey,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        trailing,
      ],
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

  // Hub Info grid items
  Widget _buildInfoGridItem({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.05),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppTheme.textGrey, size: 18),
          const SizedBox(height: 12),
          Text(
            label,
            style: const TextStyle(
              color: AppTheme.textGrey,
              fontSize: 9,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  // Dialog to Edit profile name
  void _showEditProfileDialog(BuildContext context) {
    final textController = TextEditingController(text: controller.userName.value);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppTheme.cardBackground,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
          ),
          title: const Text(
            'Edit Profile Name',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          content: TextField(
            controller: textController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: 'Name',
              labelStyle: const TextStyle(color: AppTheme.textGrey),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
              ),
              focusedBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: AppTheme.primaryBlue),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: AppTheme.textGrey)),
            ),
            TextButton(
              onPressed: () {
                controller.updateUserName(textController.text);
                Navigator.pop(context);
              },
              child: const Text('Save', style: TextStyle(color: AppTheme.primaryBlue, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
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
