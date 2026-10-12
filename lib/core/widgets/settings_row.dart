import 'package:flutter/material.dart';
import 'package:smart_home/core/theme/app_theme.dart';

/// Reusable settings tile / row widget with leading icon, title, subtitle, and trailing widget.
/// Adheres to centralized [AppRadii] and design tokens for consistent spacing and curvature.
class SettingsRow extends StatelessWidget {
  /// Leading icon indicating the setting action or category.
  final IconData icon;

  /// Main title text for the setting item.
  final String title;

  /// Subtitle providing additional description or current status.
  final String subtitle;

  /// Trailing control widget (e.g. switch, dropdown, button, or badge).
  final Widget trailing;

  /// Optional tap handler when the row itself is interactive.
  final VoidCallback? onTap;

  const SettingsRow({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final content = Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: AppRadii.md,
          ),
          child: Icon(icon, color: AppTheme.textGrey, size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(
                  color: AppTheme.textGrey,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        trailing,
      ],
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: AppRadii.md,
        child: content,
      );
    }

    return content;
  }
}
