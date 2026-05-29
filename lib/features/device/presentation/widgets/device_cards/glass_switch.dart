import 'package:flutter/material.dart';
import 'package:smart_home/core/theme/app_theme.dart';

class GlassSwitch extends StatelessWidget {
  const GlassSwitch({
    super.key,
    required this.onToggle,
    required this.isDeviceOn,
    this.scale = 1.0,
  });

  final VoidCallback onToggle;
  final bool isDeviceOn;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final w = (52 * scale).clamp(44.0, 52.0);
    final h = (28 * scale).clamp(24.0, 28.0);
    final knob = (20 * scale).clamp(16.0, 20.0);
    final radius = h / 2;

    return GestureDetector(
      onTap: onToggle,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        width: w,
        height: h,
        padding: EdgeInsets.all((4 * scale).clamp(3.0, 4.0)),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(radius),
          color: isDeviceOn
              ? AppTheme.primaryBlue
              : const Color(0xFF334155),
          boxShadow: isDeviceOn
              ? [
                  BoxShadow(
                    color: const Color.fromARGB(
                      81,
                      0,
                      229,
                      255,
                    ).withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 250),
          alignment: isDeviceOn
              ? Alignment.centerRight
              : Alignment.centerLeft,
          child: Container(
            width: knob,
            height: knob,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
