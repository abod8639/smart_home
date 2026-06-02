import 'package:flutter/material.dart';
import 'package:smart_home/core/theme/app_theme.dart';
import 'package:smart_home/core/widgets/glass_container.dart';
import 'package:smart_home/features/dashboard/presentation/controllers/dashboard_controller.dart';
import 'package:smart_home/features/device/domain/entities/device_entity.dart';

class _AcModeData {
  final String label;
  final IconData icon;
  final Color color;

  const _AcModeData(this.label, this.icon, this.color);
}

class AcModeSelectionCard extends StatelessWidget {
  final DeviceEntity device;
  final DashboardController controller;

  const AcModeSelectionCard({
    super.key,
    required this.device,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final currentMode = device.mode ?? 'Auto mode';

    final modes = [
      const _AcModeData('Auto mode', Icons.autorenew_outlined, Color(0xFF00E5FF)),
      const _AcModeData('Cool mode', Icons.ac_unit_outlined, Color(0xFF60A5FA)),
      const _AcModeData('Heat mode', Icons.whatshot_outlined, Color(0xFFFB923C)),
      const _AcModeData('Dry mode', Icons.water_drop_outlined, Color(0xFF2DD4BF)),
      const _AcModeData('Eco mode', Icons.eco_outlined, Color(0xFF4ADE80)),
    ];

    return GlassContainer(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.tune_rounded, color: AppTheme.primaryBlue, size: 18),
              SizedBox(width: 8),
              Text(
                'AC Mode',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: modes.map((m) {
                final isSelected = currentMode == m.label;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: GestureDetector(
                    onTap: () => controller.setAcMode(device.id, m.label),
                    child: AnimatedContainer(
                      width: 72,
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? m.color.withOpacity(0.12)
                            : Colors.white.withOpacity(0.04),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isSelected
                              ? m.color.withOpacity(0.5)
                              : Colors.white10,
                          width: 1.2,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: m.color.withOpacity(0.2),
                                  blurRadius: 8,
                                  spreadRadius: -2,
                                )
                              ]
                            : null,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            m.icon,
                            color: isSelected ? m.color : Colors.white60,
                            size: 22,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            m.label.split(' ')[0],
                            style: TextStyle(
                              color: isSelected ? m.color : Colors.white60,
                              fontSize: 11,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
