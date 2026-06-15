import 'package:flutter/material.dart';
import 'package:smart_home/core/utils/responsive.dart';

/// An animated button used to send an IR command to a device.
class IrSendButton extends StatelessWidget {
  /// Whether the IR command is currently being sent.
  final bool isSending;

  /// The callback to invoke when the button is tapped.
  final VoidCallback? onTap;

  /// Creates an [IrSendButton].
  const IrSendButton({
    super.key,
    required this.isSending,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);
    final double btnHeight = isMobile ? 32.0 : 36.0;
    final double padding = isMobile ? 10.0 : 14.0;
    final double fontSize = isMobile ? 11.0 : 12.0;
    final double iconSize = isMobile ? 13.0 : 14.0;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: btnHeight,
        padding: EdgeInsets.symmetric(horizontal: padding),
        decoration: BoxDecoration(
          color: Colors.green.withValues(alpha: isSending ? 0.05 : 0.12),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: Colors.greenAccent.withValues(alpha: isSending ? 0.2 : 0.4),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: isSending
              ? [
                  SizedBox(
                    width: isMobile ? 11 : 13,
                    height: isMobile ? 11 : 13,
                    child: const CircularProgressIndicator(
                      strokeWidth: 1.8,
                      color: Colors.greenAccent,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Sending...',
                    style: TextStyle(
                        color: Colors.greenAccent,
                        fontSize: fontSize,
                        fontWeight: FontWeight.w600),
                  ),
                ]
              : [
                  Icon(Icons.send_rounded, size: iconSize, color: Colors.greenAccent),
                  const SizedBox(width: 6),
                  Text(
                    'Send',
                    style: TextStyle(
                        color: Colors.greenAccent,
                        fontSize: fontSize,
                        fontWeight: FontWeight.w600),
                  ),
                ],
        ),
      ),
    );
  }
}
