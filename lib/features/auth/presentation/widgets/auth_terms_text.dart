import 'package:flutter/material.dart';

/// Small disclaimer and terms acknowledgment text widget.
class AuthTermsText extends StatelessWidget {
  const AuthTermsText({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Text(
      'By signing in, you agree to our Terms and Conditions',
      textAlign: TextAlign.center,
      style: theme.textTheme.bodySmall?.copyWith(
        color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
        fontSize: 11,
      ),
    );
  }
}
