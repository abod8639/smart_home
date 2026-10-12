import 'package:flutter/material.dart';
import 'package:smart_home/core/theme/app_radii.dart';
import 'package:smart_home/core/theme/app_shadows.dart';
import 'package:smart_home/core/theme/app_theme.dart';

/// Reusable application button supporting primary, secondary, and social configurations,
/// loading states, custom icons, and unified border radius tokens.
class AppButton extends StatelessWidget {
  /// Button label text.
  final String text;

  /// Callback when pressed. If null or if [isLoading] is true, the button is disabled.
  final VoidCallback? onPressed;

  /// Whether the button is in a loading state.
  final bool isLoading;

  /// Optional leading icon or widget (e.g. Google logo).
  final Widget? icon;

  /// Background color of the button.
  final Color? backgroundColor;

  /// Foreground color of text and icon.
  final Color? foregroundColor;

  /// Border radius applied to the button shape. Defaults to [AppRadii.lg].
  final BorderRadiusGeometry borderRadius;

  /// Custom padding inside the button.
  final EdgeInsetsGeometry padding;

  /// Optional fixed width.
  final double? width;

  /// Optional fixed height.
  final double height;

  /// Border side for outline styling.
  final BorderSide? border;

  /// Box shadow list for custom elevation. Defaults to [AppShadows.card] if elevated.
  final List<BoxShadow>? boxShadow;

  const AppButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
    this.backgroundColor,
    this.foregroundColor,
    this.borderRadius = AppRadii.lg,
    this.padding = const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
    this.width = double.infinity,
    this.height = 54.0,
    this.border,
    this.boxShadow,
  });

  /// Factory constructor for a white/light social sign-in button (e.g. Google Sign-In).
  factory AppButton.social({
    Key? key,
    required String text,
    required VoidCallback? onPressed,
    required Widget icon,
    bool isLoading = false,
    double? width = double.infinity,
  }) {
    return AppButton(
      key: key,
      text: text,
      onPressed: onPressed,
      icon: icon,
      isLoading: isLoading,
      backgroundColor: Colors.white,
      foregroundColor: Colors.black87,
      boxShadow: AppShadows.card,
      width: width,
    );
  }

  /// Factory constructor for an accent/primary call-to-action button.
  factory AppButton.primary({
    Key? key,
    required String text,
    required VoidCallback? onPressed,
    Widget? icon,
    bool isLoading = false,
    double? width = double.infinity,
  }) {
    return AppButton(
      key: key,
      text: text,
      onPressed: onPressed,
      icon: icon,
      isLoading: isLoading,
      backgroundColor: AppTheme.primaryBlue,
      foregroundColor: AppTheme.backgroundDark,
      boxShadow: AppShadows.primaryGlow,
      width: width,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveBgColor = backgroundColor ?? theme.colorScheme.primary;
    final effectiveFgColor = foregroundColor ?? theme.colorScheme.onPrimary;
    final isInteractive = onPressed != null && !isLoading;

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        boxShadow: isInteractive ? (boxShadow ?? AppShadows.card) : AppShadows.none,
      ),
      child: Material(
        color: effectiveBgColor,
        shape: RoundedRectangleBorder(
          borderRadius: borderRadius,
          side: border ?? BorderSide.none,
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: isInteractive ? onPressed : null,
          child: Padding(
            padding: padding,
            child: Center(
              child: isLoading
                  ? SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: effectiveFgColor.withValues(alpha: 0.8),
                      ),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (icon != null) ...[
                          icon!,
                          const SizedBox(width: 12),
                        ],
                        Text(
                          text,
                          style: TextStyle(
                            color: effectiveFgColor,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
