import 'package:flutter/material.dart';
import 'package:smart_home/core/theme/app_theme.dart';

/// Reusable application property row displaying a label and value pair,
/// commonly used in device properties, room details, and info panels.
class AppPropertyRow extends StatelessWidget {
  /// The descriptive title or label of the property.
  final String label;

  /// The formatted display value of the property.
  final String value;

  /// Optional trailing widget (e.g. status indicator, icon, or badge).
  final Widget? trailing;

  /// Custom text style for the label.
  final TextStyle? labelStyle;

  /// Custom text style for the value.
  final TextStyle? valueStyle;

  /// Vertical spacing between the label and the value.
  final double spacing;

  /// Alignment of the row content.
  final CrossAxisAlignment crossAxisAlignment;

  /// Creates an [AppPropertyRow].
  const AppPropertyRow({
    super.key,
    required this.label,
    required this.value,
    this.trailing,
    this.labelStyle,
    this.valueStyle,
    this.spacing = 4.0,
    this.crossAxisAlignment = CrossAxisAlignment.start,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveLabelStyle = labelStyle ??
        const TextStyle(
          color: AppTheme.textGrey,
          fontSize: 12,
        );

    final effectiveValueStyle = valueStyle ??
        const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        );

    final textColumn = Column(
      crossAxisAlignment: crossAxisAlignment,
      children: [
        Text(
          label,
          style: effectiveLabelStyle,
        ),
        SizedBox(height: spacing),
        Text(
          value,
          style: effectiveValueStyle,
        ),
      ],
    );

    if (trailing == null) {
      return textColumn;
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(child: textColumn),
        trailing!,
      ],
    );
  }
}
