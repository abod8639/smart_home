import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_home/core/widgets/app_button.dart';
import 'package:smart_home/core/widgets/app_network_image.dart';
import '../controllers/auth_controller.dart';
import '../widgets/auth_header.dart';
import '../widgets/auth_terms_text.dart';

/// Clean Architecture Login page orchestrating authentication through [AuthController].
class LoginPage extends ConsumerWidget {
  const LoginPage({super.key});

  static const String _googleLogoUrl =
      'https://www.google.com/images/branding/googleg/1x/googleg_standard_color_128dp.png';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final authState = ref.watch(authControllerProvider);
    final authController = ref.read(authControllerProvider.notifier);

    // Listen to error states to display feedback
    ref.listen<AuthState>(authControllerProvider, (previous, next) {
      if (next.errorMessage != null && next.errorMessage != previous?.errorMessage) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!),
            backgroundColor: Colors.redAccent.withValues(alpha: 0.85),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    });

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              theme.colorScheme.surface,
              theme.colorScheme.surface.withBlue(40).withRed(20),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(height: 20),

                // Reusable Header widget
                const AuthHeader(),

                // Action area with reusable AppButton and terms text
                Column(
                  children: [
                    AppButton.social(
                      text: 'Sign in with Google',
                      isLoading: authState.isLoading,
                      onPressed: authState.isLoading
                          ? null
                          : () => authController.signInWithGoogle(),
                      icon: AppNetworkImage(
                        imageUrl: _googleLogoUrl,
                        height: 24,
                        width: 24,
                        errorWidget: (context, error, stackTrace) => const Icon(
                          Icons.login_rounded,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const AuthTermsText(),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
