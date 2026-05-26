import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class GlassContainer extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry padding;
  final BorderRadiusGeometry borderRadius;
  final bool borderGradient;

  const GlassContainer({
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
    return ClipRRect(
      borderRadius: borderRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          width: width,
          height: height,
          padding: padding,
          decoration: BoxDecoration(
            color: AppTheme.cardBackground.withOpacity(0.5),
            borderRadius: borderRadius,
            border: borderGradient
                ? Border.all(
                    color: Colors.white.withOpacity(0.1),
                    width: 1.5,
                  )
                : null,
          ),
          child: child,
        ),
      ),
    );
  }
}
