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
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Obx(() {
                    if (controller.isCheckingHub.value) {
                      return const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      );
                    }
                    final connected = controller.isHubReachable.value;
                    return Row(
                      children: [
                        Icon(
                          Icons.circle,
                          size: 10,
                          color: connected ? Colors.greenAccent : Colors.redAccent,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          connected ? 'Online' : 'Offline',
                          style: TextStyle(
                            color: connected ? Colors.greenAccent : Colors.redAccent,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    );
                  }),
                  const SizedBox(width: 12),
                  Icon(
                    Icons.hub_outlined,
                    color: AppTheme.accentCyan.withValues(alpha: 0.8),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Horizontal Info Rows
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => _showEditIpDialog(context),
                  child: Obx(() => _buildInfoGridItem(
                    label: 'HUB IP ADDRESS',
                    value: controller.ipAddress.value,
                    icon: Icons.dns_outlined,
                  )),
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

  // Dialog to Edit Hub IP Address
  void _showEditIpDialog(BuildContext context) {
    final textController = TextEditingController(text: controller.ipAddress.value);

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
            'Edit Hub IP Address',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          content: TextField(
            controller: textController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: 'ESP32 Hub IP Address',
              labelStyle: const TextStyle(color: AppTheme.textGrey),
              hintText: 'e.g. 192.168.1.145',
              hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.2)),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
              ),
              focusedBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: AppTheme.primaryBlue),
              ),
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: AppTheme.textGrey)),
            ),
            TextButton(
              onPressed: () async {
                await controller.updateIpAddress(textController.text.trim());
                if (context.mounted) Navigator.pop(context);
              },
              child: const Text('Save', style: TextStyle(color: AppTheme.primaryBlue, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }
}
