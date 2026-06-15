import 'package:flutter/material.dart';
import 'package:smart_home/core/theme/app_theme.dart';

/// A bottom sheet widget that lets the user configure or cancel the AC sleep timer.
class SleepTimerSheet extends StatelessWidget {
  /// The active sleep timer duration remaining, if any.
  final Duration? timeLeft;

  /// Callback invoked when a specific duration is selected.
  /// Pass `Duration.zero` to turn off/cancel the timer.
  final ValueChanged<Duration> onDurationSelected;

  /// Creates a [SleepTimerSheet].
  const SleepTimerSheet({
    super.key,
    required this.timeLeft,
    required this.onDurationSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      decoration: const BoxDecoration(
        color: Color(0xFF0F172A),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(
          top: BorderSide(color: Colors.white10, width: 1),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const Text(
            'Sleep Timer',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Set when to automatically turn off the air conditioner.',
            style: TextStyle(color: AppTheme.textGrey, fontSize: 12),
          ),
          const SizedBox(height: 20),
          _buildTimerOption(context, 'Turn Off Timer', const Duration(seconds: 0)),
          _buildTimerOption(context, '30 Minutes', const Duration(minutes: 30)),
          _buildTimerOption(context, '1 Hour', const Duration(hours: 1)),
          _buildTimerOption(context, '2 Hours', const Duration(hours: 2)),
          _buildTimerOption(context, '4 Hours', const Duration(hours: 4)),
        ],
      ),
    );
  }

  Widget _buildTimerOption(BuildContext context, String label, Duration duration) {
    final isCurrent = (duration.inSeconds == 0 && timeLeft == null) ||
        (timeLeft != null && timeLeft!.inMinutes == duration.inMinutes);

    return InkWell(
      onTap: () {
        Navigator.pop(context);
        onDurationSelected(duration);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isCurrent ? AppTheme.primaryBlue.withValues(alpha: 0.1) : Colors.white.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isCurrent ? AppTheme.primaryBlue.withValues(alpha: 0.5) : Colors.white10,
          ),
        ),
        child: Row(
          children: [
            Icon(
              duration.inSeconds == 0 ? Icons.timer_off_outlined : Icons.timer_outlined,
              color: isCurrent ? AppTheme.primaryBlue : Colors.white70,
              size: 20,
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                color: isCurrent ? AppTheme.primaryBlue : Colors.white,
                fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            const Spacer(),
            if (isCurrent)
              const Icon(Icons.check_circle, color: AppTheme.primaryBlue, size: 18),
          ],
        ),
      ),
    );
  }
}
