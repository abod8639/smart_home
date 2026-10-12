import 'package:flutter/material.dart';
import 'package:smart_home/core/theme/app_theme.dart';

/// Reusable application dialog adhering to the smart home design tokens,
/// providing consistent glassmorphic styling, unified border radius, and surface tint.
class AppDialog extends StatelessWidget {
  /// The title text or custom title widget.
  final Widget title;

  /// The dialog content body widget.
  final Widget content;

  /// Optional action buttons displayed at the bottom.
  final List<Widget>? actions;

  /// Padding around the content.
  final EdgeInsetsGeometry? contentPadding;

  /// Optional custom shape. Defaults to [AppRadii.shapeXxl].
  final ShapeBorder? shape;

  /// Background color of the dialog. Defaults to [AppTheme.cardBackground].
  final Color backgroundColor;

  /// Creates an [AppDialog].
  const AppDialog({
    super.key,
    required this.title,
    required this.content,
    this.actions,
    this.contentPadding,
    this.shape,
    this.backgroundColor = AppTheme.cardBackground,
  });

  /// Factory helper for standard dialogs with a string title and optional icon.
  factory AppDialog.standard({
    Key? key,
    required String title,
    IconData? icon,
    Color iconColor = AppTheme.primaryBlue,
    required Widget content,
    List<Widget>? actions,
    EdgeInsetsGeometry? contentPadding,
  }) {
    return AppDialog(
      key: key,
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, color: iconColor, size: 22),
            const SizedBox(width: 10),
          ],
          Flexible(
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      content: content,
      actions: actions,
      contentPadding: contentPadding,
    );
  }

  /// Displays this dialog using [showDialog].
  static Future<T?> show<T>({
    required BuildContext context,
    required WidgetBuilder builder,
    bool barrierDismissible = true,
  }) {
    return showDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: builder,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: backgroundColor,
      surfaceTintColor: Colors.transparent,
      shape: shape ??
          RoundedRectangleBorder(
            borderRadius: AppRadii.xxl,
            side: BorderSide(
              color: Colors.white.withValues(alpha: 0.1),
            ),
          ),
      title: title,
      content: content,
      actions: actions,
      contentPadding: contentPadding ??
          const EdgeInsets.fromLTRB(24.0, 20.0, 24.0, 24.0),
      actionsPadding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
    );
  }
}
