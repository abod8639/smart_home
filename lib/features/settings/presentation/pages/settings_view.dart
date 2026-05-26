import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_home/core/theme/app_theme.dart';
import 'package:smart_home/features/settings/presentation/controllers/settings_controller.dart';
import 'package:smart_home/features/settings/presentation/widgets/profile_card.dart';
import 'package:smart_home/features/settings/presentation/widgets/preferences_card.dart';
import 'package:smart_home/features/settings/presentation/widgets/hub_config_card.dart';
import 'package:smart_home/features/settings/presentation/widgets/device_management_card.dart';

import 'package:smart_home/features/settings/presentation/widgets/device_placement_card.dart';

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
        const SizedBox(height: 14),

        // Main Content Row
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left Column: Profile & General Preferences
              Expanded(
                flex: 4,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const ProfileCard(),
                      const SizedBox(height: 14),
                      const PreferencesCard(),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 14),

              // Right Column: Hub Configuration, Device Placement & Device Management
              Expanded(
                flex: 5,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const HubConfigCard(),
                      const SizedBox(height: 14),
                      SizedBox(
                        height: 320,
                        child: DevicePlacementCard(),
                      ),
                      const SizedBox(height: 14),
                      const SizedBox(
                        height: 280,
                        child: DeviceManagementCard(),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
