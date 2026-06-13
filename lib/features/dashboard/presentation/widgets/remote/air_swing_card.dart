import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_home/core/theme/app_theme.dart';
import 'package:smart_home/core/widgets/glass_container.dart';
import 'package:smart_home/features/dashboard/presentation/controllers/dashboard_controller.dart';
import 'package:smart_home/features/device/domain/entities/device_entity.dart';

class AirSwingCard extends StatefulWidget {
  final DeviceEntity device;
  final DashboardController controller;
  final bool verticalSwing;
  final bool horizontalSwing;
  final ValueChanged<bool> onVerticalSwingChanged;
  final ValueChanged<bool> onHorizontalSwingChanged;

  const AirSwingCard({
    super.key,
    required this.device,
    required this.controller,
    required this.verticalSwing,
    required this.horizontalSwing,
    required this.onVerticalSwingChanged,
    required this.onHorizontalSwingChanged,
  });

  @override
  State<AirSwingCard> createState() => _AirSwingCardState();
}

class _AirSwingCardState extends State<AirSwingCard> {
  final List<String> _customNames = List.filled(6, '');
  
  static const List<String> _customFieldKeys = [
    'irPlasmacluster',
    'irSuperJet',
    'irCoanda',
    'irMyArea',
    'irDisplay',
    'irClean',
  ];

  @override
  void initState() {
    super.initState();
    _loadCustomNames();
  }

  Future<void> _loadCustomNames() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        for (int i = 0; i < 6; i++) {
          _customNames[i] = prefs.getString('${widget.device.id}_custom_btn_$i') ?? '';
        }
      });
    }
  }

  Future<void> _saveCustomName(int index, String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('${widget.device.id}_custom_btn_$index', name);
    if (mounted) {
      setState(() {
        _customNames[index] = name;
      });
    }
  }

  void _showEditDialog(int index) {
    final TextEditingController nameController = TextEditingController(text: _customNames[index]);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1A1B2E),
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
          ),
          title: const Text(
            'إعداد الزر / Button Setup',
            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'اسم الزر / Button Name',
                  labelStyle: const TextStyle(color: Colors.white60),
                  enabledBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white24),
                  ),
                  focusedBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: AppTheme.primaryBlue),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4C86FF).withValues(alpha: 0.2),
                    foregroundColor: const Color(0xFF4C86FF),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: const Color(0xFF4C86FF).withValues(alpha: 0.5)),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  icon: const Icon(Icons.settings_remote_rounded),
                  label: const Text('نسخ الريموت / Learn IR'),
                  onPressed: () {
                    Navigator.pop(context);
                    widget.controller.learnAndSaveIrCode(context, widget.device.id, _customFieldKeys[index]);
                  },
                ),
              )
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء / Cancel', style: TextStyle(color: Colors.white54)),
            ),
            TextButton(
              onPressed: () {
                _saveCustomName(index, nameController.text.trim());
                Navigator.pop(context);
              },
              child: const Text('حفظ / Save', style: TextStyle(color: AppTheme.primaryBlue, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      }
    );
  }

  String? _getIrCodeForIndex(int index) {
    switch (index) {
      case 0: return widget.device.irPlasmacluster;
      case 1: return widget.device.irSuperJet;
      case 2: return widget.device.irCoanda;
      case 3: return widget.device.irMyArea;
      case 4: return widget.device.irDisplay;
      case 5: return widget.device.irClean;
      default: return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.swap_calls_rounded,
                color: AppTheme.primaryBlue,
                size: 18,
              ),
              SizedBox(width: 8),
              Text(
                'Air Swing & Custom Controls',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildSwingToggleButton(
                  icon: Icons.unfold_more_rounded,
                  label: 'Vertical Swing',
                  isSelected: widget.verticalSwing,
                  onTap: () {
                    widget.onVerticalSwingChanged(!widget.verticalSwing);
                    if (widget.device.irSwingV != null) {
                      widget.controller.sendIrCommand(context, widget.device.irSwingV!);
                    }
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSwingToggleButton(
                  icon: Icons.swap_horiz_rounded,
                  label: 'Horizontal Swing',
                  isSelected: widget.horizontalSwing,
                  onTap: () {
                    widget.onHorizontalSwingChanged(!widget.horizontalSwing);
                    if (widget.device.irSwingH != null) {
                      widget.controller.sendIrCommand(context, widget.device.irSwingH!);
                    }
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 3,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.2,
            children: List.generate(6, (index) {
              return _buildCustomGridButton(index);
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomGridButton(int index) {
    Timer? longPressTimer;
    final hasCode = _getIrCodeForIndex(index) != null;
    // final name = _customNames[index].isEmpty ? 'Btn ${index + 1}' : _customNames[index];

    return GestureDetector(
      onTapDown: (_) {
        longPressTimer = Timer(const Duration(seconds: 3), () {
          _showEditDialog(index);
        });
      },
      onTapUp: (_) {
        longPressTimer?.cancel();
      },
      onTapCancel: () {
        longPressTimer?.cancel();
      },
      onTap: () {
        final code = _getIrCodeForIndex(index);
        if (code != null) {
          widget.controller.sendIrCommand(context, code);
        } else {
          _showEditDialog(index);
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        decoration: BoxDecoration(
          color: hasCode
              ? AppTheme.primaryBlue.withValues(alpha: 0.12)
              : Colors.white.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: hasCode
                ? AppTheme.primaryBlue.withValues(alpha: 0.5)
                : Colors.white10,
            width: 1.2,
          ),
        ),
        child: null
      ),
    );
  }

  Widget _buildSwingToggleButton({
    required IconData? icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primaryBlue.withValues(alpha: 0.12)
              : Colors.white.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? AppTheme.primaryBlue.withValues(alpha: 0.5)
                : Colors.white10,
            width: 1.2,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                color: isSelected ? AppTheme.primaryBlue : Colors.white60,
                size: 18,
              ),
              const SizedBox(width: 8),
            ],
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  color: isSelected ? AppTheme.primaryBlue : Colors.white60,
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
