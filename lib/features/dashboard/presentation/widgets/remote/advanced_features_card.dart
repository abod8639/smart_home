import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_home/core/theme/app_theme.dart';
import 'package:smart_home/core/widgets/glass_container.dart';
import 'package:smart_home/features/dashboard/presentation/controllers/dashboard_controller.dart';
import 'package:smart_home/features/device/domain/entities/device_entity.dart';

class AdvancedFeaturesCard extends StatelessWidget {
  final DeviceEntity device;
  final DashboardController controller;
  final bool isPlasmaclusterOn;
  final bool isSuperJetOn;
  final bool isCoandaOn;
  final bool isMyAreaOn;
  final bool isDisplayOn;
  final ValueChanged<bool> onPlasmaclusterChanged;
  final ValueChanged<bool> onSuperJetChanged;
  final ValueChanged<bool> onCoandaChanged;
  final ValueChanged<bool> onMyAreaChanged;
  final ValueChanged<bool> onDisplayChanged;

  const AdvancedFeaturesCard({
    super.key,
    required this.device,
    required this.controller,
    required this.isPlasmaclusterOn,
    required this.isSuperJetOn,
    required this.isCoandaOn,
    required this.isMyAreaOn,
    required this.isDisplayOn,
    required this.onPlasmaclusterChanged,
    required this.onSuperJetChanged,
    required this.onCoandaChanged,
    required this.onMyAreaChanged,
    required this.onDisplayChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.stars_rounded, color: AppTheme.primaryBlue, size: 18),
              SizedBox(width: 8),
              Text(
                'Advanced Features',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.3,
            children: [
              buildFeatureToggle(
                icon: Icons.bubble_chart,
                label: 'Plasmacluster',
                isSelected: isPlasmaclusterOn,
                onTap: () {
                  final newVal = !isPlasmaclusterOn;
                  onPlasmaclusterChanged(newVal);
                  if (device.irPlasmacluster != null) {
                    controller.sendIrCommand(device.irPlasmacluster!);
                  } else {
                    _showFeatureToast('Plasmacluster', newVal);
                  }
                },
              ),
              buildFeatureToggle(
                icon: Icons.speed_rounded,
                label: 'Super Jet',
                isSelected: isSuperJetOn,
                activeColor: const Color(0xFF60A5FA),
                onTap: () {
                  final newVal = !isSuperJetOn;
                  onSuperJetChanged(newVal);
                  if (device.irSuperJet != null) {
                    controller.sendIrCommand(device.irSuperJet!);
                  } else {
                    _showFeatureToast('Super Jet', newVal);
                  }
                },
              ),
              buildFeatureToggle(
                icon: Icons.air,
                label: 'Coanda',
                isSelected: isCoandaOn,
                onTap: () {
                  final newVal = !isCoandaOn;
                  onCoandaChanged(newVal);
                  if (device.irCoanda != null) {
                    controller.sendIrCommand(device.irCoanda!);
                  } else {
                    _showFeatureToast('Coanda', newVal);
                  }
                },
              ),
              buildFeatureToggle(
                icon: Icons.person_pin_circle_rounded,
                label: 'My Area',
                isSelected: isMyAreaOn,
                onTap: () {
                  final newVal = !isMyAreaOn;
                  onMyAreaChanged(newVal);
                  if (device.irMyArea != null) {
                    controller.sendIrCommand(device.irMyArea!);
                  } else {
                    _showFeatureToast('My Area', newVal);
                  }
                },
              ),
              buildFeatureToggle(
                icon: Icons.light_mode_outlined,
                label: 'Display',
                isSelected: isDisplayOn,
                onTap: () {
                  final newVal = !isDisplayOn;
                  onDisplayChanged(newVal);
                  if (device.irDisplay != null) {
                    controller.sendIrCommand(device.irDisplay!);
                  } else {
                    _showFeatureToast('AC Display', newVal);
                  }
                },
              ),
              // Action Button (not toggle)
              GestureDetector(
                onTap: () {
                  if (device.irClean != null) {
                    controller.sendIrCommand(device.irClean!);
                  } else {
                    Get.snackbar(
                      'Clean',
                      'Clean mode not set to this AC.',
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: const Color(0xFF1E293B),
                      colorText: Colors.white,
                      duration: const Duration(seconds: 2),
                    );
                  }
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.04),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.white10, width: 1.2),
                  ),
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.cleaning_services_rounded, color: Colors.white60, size: 22),
                      SizedBox(height: 6),
                      Text(
                        'Clean',
                        style: TextStyle(color: Colors.white60, fontSize: 11),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }



  void _showFeatureToast(String featureName, bool isOn) {
    final status = isOn ? 'تفعيل' : 'إيقاف';
    Get.snackbar(
      '$featureName / ${featureName}',
      'تم $status خاصية $featureName',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF1E293B),
      colorText: Colors.white,
      duration: const Duration(seconds: 1),
    );
  }
}

  Widget buildFeatureToggle({
    required IconData? icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    Color? activeColor,
  }) {
    final color = activeColor ?? AppTheme.primaryBlue;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: .12) : Colors.white.withValues(alpha: .04),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? color.withValues(alpha: .5) : Colors.white10,
            width: 1.2,
          ),
          boxShadow: isSelected
              ? [BoxShadow(color: color.withOpacity(0.2), blurRadius: 8, spreadRadius: -2)]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) 
            Icon(
              icon,
              color: isSelected ? color : Colors.white60,
              size: 22,
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? color : Colors.white60,
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }