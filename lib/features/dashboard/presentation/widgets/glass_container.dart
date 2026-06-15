import 'dart:ui';
import 'package:flutter/material.dart';

/// A glassmorphic container widget with backdrop blur, rounded corners, and a subtle border.
class GlassContainer extends StatelessWidget {
  /// The widget to render inside the container.
  final Widget child;

  /// Creates a [GlassContainer].
  const GlassContainer({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.04),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
          ),
          child: child,
        ),
      ),
    );
  }
}
