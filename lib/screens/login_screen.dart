import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_typography.dart';
import '../widgets/social_auth_button.dart';
import 'email_login_screen.dart';
import 'main_navigation_screen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Top Section
            Expanded(
              child: Column(
                children: [
                  const SizedBox(height: 24),
                  // Logo Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.all_inclusive,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'HelperHive',
                        style: AppTypography.textTheme.titleLarge?.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  // Illustration Placeholder
                  Container(
                    width: double.infinity,
                    height: 250,
                    margin: const EdgeInsets.symmetric(horizontal: 40),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.laptop_mac,
                        size: 100,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const Spacer(),
                ],
              ),
            ),

            // Bottom Green Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              decoration: const BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(32),
                  topRight: Radius.circular(32),
                ),
              ),
              child: Column(
                children: [
                  Text(
                    'Let\'s Explore\nHelperHive',
                    textAlign: TextAlign.center,
                    style: AppTypography.textTheme.displayLarge?.copyWith(
                      color: Colors.white,
                      height: 1.3,
                      fontSize: 28,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Google Button
                  SocialAuthButton(
                    icon: _buildGoogleIcon(),
                    text: 'Sign in with Google',
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => const MainNavigationScreen()),
                      );
                    },
                  ),
                  const SizedBox(height: 16),

                  // Apple Button
                  SocialAuthButton(
                    icon: const Icon(Icons.apple, color: Colors.black, size: 28),
                    text: 'Sign in with Apple',
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => const MainNavigationScreen()),
                      );
                    },
                  ),
                  const SizedBox(height: 24),

                  // Divider
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 1,
                          color: Colors.white.withOpacity(0.5),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'Or Sign in with',
                          style: AppTypography.textTheme.bodyMedium?.copyWith(
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          height: 1,
                          color: Colors.white.withOpacity(0.5),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Email Button
                  SocialAuthButton(
                    icon: const SizedBox.shrink(), // No icon for email button in design
                    text: 'Sign in with Email',
                    backgroundColor: Colors.black,
                    textColor: Colors.white,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const EmailLoginScreen()),
                      );
                    },
                  ),
                  const SizedBox(height: 16), // Bottom padding
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Temporary Google Icon builder (since we don't have font_awesome or svg asset yet)
  Widget _buildGoogleIcon() {
    return Container(
      width: 24,
      height: 24,
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
      child: const Center(
        child: Text(
          'G',
          style: TextStyle(
            color: Colors.blue,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
