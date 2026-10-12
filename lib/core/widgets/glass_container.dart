import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Reusable glassmorphic container with blur filter, unified border radius, and shadow support.
class GlassContainer extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry padding;
  final BorderRadiusGeometry borderRadius;
  final bool borderGradient;
  final List<BoxShadow>? boxShadow;
  final Color? backgroundColor;

  const GlassContainer({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.padding = const EdgeInsets.all(6.0),
    this.borderRadius = AppRadii.xxl,
    this.borderGradient = true,
    this.boxShadow,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        boxShadow: boxShadow ?? AppShadows.subtle,
      ),
      child: ClipRRect(
        borderRadius: borderRadius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            width: width,
            height: height,
            padding: padding,
            decoration: BoxDecoration(
              color: backgroundColor ?? AppTheme.cardBackground.withValues(alpha: 0.1),
              borderRadius: borderRadius,
              border: borderGradient
                  ? Border.all(
                      color: Colors.white.withValues(alpha: 0.15),
                      width: 1.5,
                    )
                  : null,
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
