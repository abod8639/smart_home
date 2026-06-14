import 'package:flutter/material.dart';
import 'package:smart_home/core/theme/app_theme.dart';

/// A glassmorphic custom switch button.
class GlassSwitch extends StatelessWidget {
  /// Creates a constant [GlassSwitch] instance.
  const GlassSwitch({
    super.key,
    required this.onToggle,
    required this.isDeviceOn,
    this.scale = 1.0,
  });

  /// Callback executed when toggling the switch state.
  final VoidCallback onToggle;
  /// Whether the switch is currently on.
  final bool isDeviceOn;
  /// The scaling factor for sizing the switch.
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
