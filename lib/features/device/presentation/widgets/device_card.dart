import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/device_entity.dart';
import '../providers/device_providers.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../../core/theme/app_theme.dart';

class DeviceCard extends ConsumerWidget {
  final DeviceEntity device;

  const DeviceCard({super.key, required this.device});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GlassContainer(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                _getDeviceIcon(device.type),
                color: device.isOn ? AppTheme.neonBlue : Colors.white54,
                size: 32,
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    device.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    device.room,
                    style: const TextStyle(
                      color: Colors.white54,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ],
          ),
          _buildActionWidget(ref),
        ],
      ),
    );
  }

  Widget _buildActionWidget(WidgetRef ref) {
    if (device.isLoading) {
      // Visual feedback while waiting for WebSocket confirmation
      return const SizedBox(
        width: 48,
        height: 48,
        child: Center(
          child: CircularProgressIndicator(
            color: AppTheme.neonPurple,
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: () {
        ref.read(deviceControllerProvider.notifier).toggleDevice(device.id, device.isOn);
      },
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: device.isOn ? AppTheme.neonBlue.withValues(alpha: 0.2) : Colors.transparent,
          border: Border.all(
            color: device.isOn ? AppTheme.neonBlue : Colors.white30,
            width: 2,
          ),
          boxShadow: device.isOn
              ? [
                  BoxShadow(
                    color: AppTheme.neonBlue.withValues(alpha: 0.5),
                    blurRadius: 10,
                    spreadRadius: 2,
                  )
                ]
              : null,
        ),
        child: Icon(
          Icons.power_settings_new,
          color: device.isOn ? AppTheme.neonBlue : Colors.white30,
        ),
      ),
    );
  }

  IconData _getDeviceIcon(String type) {
    switch (type.toLowerCase()) {
      case 'light':
        return Icons.lightbulb_outline;
      case 'ac':
        return Icons.ac_unit;
      case 'tv':
        return Icons.tv;
      default:
        return Icons.devices;
    }
  }
}
