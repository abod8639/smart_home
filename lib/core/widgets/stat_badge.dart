import 'package:flutter/material.dart';
import '../theme/app_radii.dart';
import '../theme/app_shadows.dart';
import '../theme/app_theme.dart';

/// A reusable glassmorphic status badge / stat chip widget for displaying
/// telemetry, states, or device metadata with unified tokens.
class StatBadge extends StatelessWidget {
  /// Optional leading or indicator icon.
  final IconData? icon;

  /// The primary stat text or value (e.g. "24°C", "85%").
  final String value;

  /// Optional secondary subtitle or description (e.g. "Battery", "Auto mode").
  final String? label;

  /// Optional tap callback for interactive chips.
  final VoidCallback? onTap;

  /// Color of the icon.
  final Color? iconColor;

  /// Color of the primary value text.
  final Color valueColor;

  /// Color of the secondary label text.
  final Color labelColor;

  /// Custom border radius (defaults to [AppRadii.md]).
  final BorderRadius borderRadius;

  /// Background fill color.
  final Color? backgroundColor;

  /// Optional custom border.
  final BoxBorder? border;

  /// Optional custom box shadows (defaults to subtle depth).
  final List<BoxShadow>? boxShadow;

  /// Inner padding.
  final EdgeInsetsGeometry padding;

  /// Layout orientation: when true, aligns value and label in a column.
  final bool isVertical;

  /// Optional icon size.
  final double iconSize;

  /// Optional value font size.
  final double? valueFontSize;

  /// Optional label font size.
  final double? labelFontSize;

  const StatBadge({
    super.key,
    this.icon,
    required this.value,
    this.label,
    this.onTap,
    this.iconColor,
    this.valueColor = Colors.white,
    this.labelColor = AppTheme.textGrey,
    this.borderRadius = AppRadii.md,
    this.backgroundColor,
    this.border,
    this.boxShadow,
    this.padding = const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    this.isVertical = false,
    this.iconSize = 16.0,
    this.valueFontSize,
    this.labelFontSize,
  });

  @override
  Widget build(BuildContext context) {
    final bg = backgroundColor ?? Colors.black.withValues(alpha: 0.2);
    final borderDecoration = border ??
        Border.all(
          color: Colors.white.withValues(alpha: 0.04),
          width: 1,
        );

    Widget content;
    if (isVertical) {
      content = Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (icon != null) ...[
            Icon(icon, color: iconColor ?? AppTheme.textGrey, size: iconSize),
            const SizedBox(height: 2),
          ],
          Text(
            value,
            style: TextStyle(
              color: valueColor,
              fontWeight: FontWeight.bold,
              fontSize: valueFontSize ?? 12,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          if (label != null) ...[
            const SizedBox(height: 1),
            Text(
              label!,
              style: TextStyle(
                color: labelColor,
                fontSize: labelFontSize ?? 9,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      );
    } else {
      content = Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null) ...[
            Icon(icon, color: iconColor ?? AppTheme.textGrey, size: iconSize),
            const SizedBox(width: 6),
          ],
          Flexible(
            child: label == null
                ? Text(
                    value,
                    style: TextStyle(
                      color: valueColor,
                      fontWeight: FontWeight.w500,
                      fontSize: valueFontSize ?? 12,
                    ),
                    overflow: TextOverflow.ellipsis,
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        value,
                        style: TextStyle(
                          color: valueColor,
                          fontWeight: FontWeight.bold,
                          fontSize: valueFontSize ?? 11,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        label!,
                        style: TextStyle(
                          color: labelColor,
                          fontSize: labelFontSize ?? 8,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
          ),
        ],
      );
    }

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: padding,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: borderRadius,
          border: borderDecoration,
          boxShadow: boxShadow ?? AppShadows.subtle,
        ),
        child: content,
      ),
    );
  }
}
