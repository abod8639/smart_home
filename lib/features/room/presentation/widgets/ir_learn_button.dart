import 'package:flutter/material.dart';
import 'package:smart_home/core/utils/responsive.dart';

/// An animated button used to record/re-record an IR remote command.
class IrLearnButton extends StatelessWidget {
  /// Whether there is already an IR code recorded for this command.
  final bool hasCode;

  /// The callback to invoke when the button is tapped.
  final VoidCallback onTap;

  /// Creates an [IrLearnButton].
  const IrLearnButton({
    super.key,
    required this.hasCode,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);
    final double btnHeight = isMobile ? 32.0 : 36.0;
    final double fontSize = isMobile ? 11.0 : 12.0;
    final double iconSize = isMobile ? 13.0 : 15.0;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: btnHeight,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: hasCode
                ? [
                    Colors.white.withValues(alpha: 0.07),
                    Colors.white.withValues(alpha: 0.04)
                  ]
                : [
                    const Color(0xFF4C86FF).withValues(alpha: 0.3),
                    const Color(0xFF4C86FF).withValues(alpha: 0.15),
                  ],
          ),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: hasCode
                ? Colors.white.withValues(alpha: 0.1)
                : const Color(0xFF4C86FF).withValues(alpha: 0.5),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              hasCode ? Icons.replay_rounded : Icons.settings_remote_rounded,
              size: iconSize,
              color: hasCode ? Colors.white54 : const Color(0xFF4C86FF),
            ),
            const SizedBox(width: 4),
            Text(
              hasCode ? 'Re-Record' : 'Record',
              style: TextStyle(
                color: hasCode ? Colors.white54 : Colors.white,
                fontSize: fontSize,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
