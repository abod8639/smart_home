import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_home/core/theme/app_theme.dart';
import 'package:smart_home/core/widgets/glass_container.dart';
import 'package:smart_home/features/settings/presentation/controllers/settings_controller.dart';

class HubConfigCard extends GetView<SettingsController> {
  const HubConfigCard({super.key});

  @override
  Widget build(BuildContext context) {
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
}
