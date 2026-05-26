import 'package:flutter/material.dart';
import 'package:smart_home/core/theme/app_theme.dart';

class ShadowContainer extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry padding;
  final BorderRadiusGeometry borderRadius;
  final bool borderGradient;

  const ShadowContainer({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.padding = const EdgeInsets.all(16.0),
    this.borderRadius = const BorderRadius.all(Radius.circular(24.0)),
    this.borderGradient = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      padding: padding,
      decoration: BoxDecoration(
        color: AppTheme.cardBackground.withValues(alpha: 0.3),
        borderRadius: borderRadius,
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