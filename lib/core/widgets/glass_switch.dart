import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// A reusable glassmorphic custom switch button with unified radius, shadows,
/// and smooth interactive state transitions.
class GlassSwitch extends StatelessWidget {
  /// Callback executed when toggling the switch state.
  final VoidCallback onToggle;

  /// Whether the switch is currently on.
  final bool isDeviceOn;

  /// The scaling factor for sizing the switch.
  final double scale;

  /// When true, the switch is in a loading/pending state waiting for device
  /// confirmation. Taps are ignored and a spinner is shown instead of the knob.
  final bool isPending;

  /// Optional active background color (defaults to [AppTheme.primaryBlue]).
  final Color? activeColor;

  /// Optional inactive background color.
  final Color? inactiveColor;

  /// Creates a constant [GlassSwitch] instance.
  const GlassSwitch({
    super.key,
    required this.onToggle,
    required this.isDeviceOn,
    this.scale = 1.0,
    this.isPending = false,
    this.activeColor,
    this.inactiveColor,
  });

  @override
  Widget build(BuildContext context) {
    final w = (52 * scale).clamp(44.0, 52.0);
    final h = (28 * scale).clamp(24.0, 28.0);
    final knob = (20 * scale).clamp(16.0, 20.0);
    final radius = h / 2;

    Color bgColor;
    if (isPending) {
      bgColor = const Color(0xFF78716C); // neutral amber-grey during pending
    } else if (isDeviceOn) {
      bgColor = activeColor ?? AppTheme.primaryBlue;
    } else {
      bgColor = inactiveColor ?? const Color(0xFF334155);
    }

    return GestureDetector(
      onTap: isPending ? null : onToggle,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        width: w,
        height: h,
        padding: EdgeInsets.all((4 * scale).clamp(3.0, 4.0)),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(radius),
          color: bgColor,
          boxShadow: isDeviceOn && !isPending
              ? AppShadows.glow(
                  activeColor ?? AppTheme.accentCyan,
                  blur: 8,
                  alpha: 0.3,
                )
              : AppShadows.none,
        ),
        child: isPending
            ? Center(
                child: SizedBox(
                  width: knob * 0.75,
                  height: knob * 0.75,
                  child: CircularProgressIndicator(
                    strokeWidth: 1.5,
                    color: Colors.white.withValues(alpha: 0.85),
                  ),
                ),
              )
            : AnimatedAlign(
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
