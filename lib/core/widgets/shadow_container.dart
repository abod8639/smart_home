import 'package:flutter/material.dart';
import 'package:smart_home/core/theme/app_radii.dart';
import 'package:smart_home/core/theme/app_shadows.dart';
import 'package:smart_home/core/theme/app_theme.dart';

/// Reusable container with unified border radius and box shadow support.
class ShadowContainer extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry padding;
  final BorderRadiusGeometry borderRadius;
  final List<BoxShadow>? boxShadow;
  final bool borderGradient;
  final Color? backgroundColor;

  const ShadowContainer({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.padding = const EdgeInsets.all(16.0),
    this.borderRadius = AppRadii.xxl,
    this.boxShadow,
    this.borderGradient = true,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor ?? AppTheme.cardBackground.withValues(alpha: 0.3),
        borderRadius: borderRadius,
        boxShadow: boxShadow ?? AppShadows.card,
        border: borderGradient
            ? Border.all(
                color: AppTheme.cardBackground.withValues(alpha: 0.5),
                width: 1.5,
              )
            : null,
      ),
      child: child,
    );
  }
}