import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class GlassContainer extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BorderRadiusGeometry? borderRadius;
  final VoidCallback? onTap;
  final bool isHighlighted;

  const GlassContainer({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.borderRadius,
    this.onTap,
    this.isHighlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    // Cyberpunk tends to use sharper edges, so we reduce the default border radius
    final defaultBorderRadius = borderRadius ?? BorderRadius.circular(8);
    
    // Determine border and glow colors based on highlight state
    final borderColor = isHighlighted ? AppTheme.neonCyan : Colors.white.withValues(alpha: 0.1);
    final glowColor = isHighlighted ? AppTheme.neonCyan.withValues(alpha: 0.3) : Colors.black.withValues(alpha: 0.5);

    return Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: defaultBorderRadius,
        boxShadow: [
          BoxShadow(
            color: glowColor,
            blurRadius: isHighlighted ? 15 : 10,
            spreadRadius: isHighlighted ? 2 : 0,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: defaultBorderRadius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15.0, sigmaY: 15.0),
          child: Material(
            color: AppTheme.surfaceDark.withValues(alpha: 0.6),
            child: InkWell(
              onTap: onTap,
              splashColor: AppTheme.neonPink.withValues(alpha: 0.2),
              highlightColor: AppTheme.neonCyan.withValues(alpha: 0.1),
              child: Container(
                padding: padding ?? const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: defaultBorderRadius,
                  border: Border.all(
                    color: borderColor,
                    width: isHighlighted ? 2.0 : 1.0,
                  ),
                ),
                child: child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
