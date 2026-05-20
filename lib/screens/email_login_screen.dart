import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_typography.dart';
import '../core/services/auth_service.dart';
import '../core/data/mock_data.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/social_circle_button.dart';
import 'signup_screen.dart';
import 'reset_password_screen.dart';
import 'main_navigation_screen.dart';
import 'address_setup_screen.dart';
import 'provider/provider_setup_screen.dart';
import 'provider/provider_navigation_screen.dart';

class EmailLoginScreen extends StatefulWidget {
  const EmailLoginScreen({super.key});

  @override
  State<EmailLoginScreen> createState() => _EmailLoginScreenState();
}

class _EmailLoginScreenState extends State<EmailLoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _rememberMe = false;
  bool _obscurePassword = true;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    setState(() {
      _errorMessage = null;
      _isLoading = true;
    });

    final result = await AuthService.signIn(
      email: _emailController.text,
      password: _passwordController.text,
      rememberMe: _rememberMe,
    );

    if (!mounted) return;

    if (result.success && result.user != null) {
      // Sync to MockData so the entire app immediately reflects the real user
      MockData.currentUserName = result.user!.name;
      MockData.currentUserEmail = result.user!.email;
      MockData.isUserRegisteredAsProvider = result.user!.isProvider;

      // Load user-scoped data (e.g. addresses, bookings, notifications) for the logged in user
      await MockData.init();

      if (!mounted) return;

      if (result.user!.isProvider) {
        final hasListing = MockData.providers.any((p) => p.id == result.user!.uid || p.name == result.user!.name);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => hasListing 
                ? const ProviderNavigationScreen() 
                : const ProviderSetupScreen(),
          ),
        );
      } else {
        final hasAddress = MockData.addresses.isNotEmpty;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => hasAddress 
                ? const MainNavigationScreen() 
                : const AddressSetupScreen(),
          ),
        );
      }
    } else {
      setState(() {
        _isLoading = false;
        _errorMessage = result.message;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Logo
                Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Icon(Icons.hive_outlined,
                            color: Colors.white, size: 18),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'HelperHive',
                      style: AppTypography.textTheme.titleLarge
                          ?.copyWith(color: AppColors.primary),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Heading
                Text(
                  'Hi, Welcome Back 👋',
                  style: AppTypography.textTheme.displayLarge
                      ?.copyWith(color: AppColors.textPrimaryLight, fontSize: 28),
                ),
                const SizedBox(height: 8),
                Text(
                  'Sign in to your account',
                  style: AppTypography.textTheme.bodyLarge
                      ?.copyWith(color: AppColors.textSecondaryLight),
                ),
                const SizedBox(height: 32),

                // Form Card
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Email Field
                      CustomTextField(
                        label: 'Email',
                        hintText: 'Input your email',
                        prefixIcon: Icons.mail_outline,
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 20),

                      // Password Field
                      CustomTextField(
                        label: 'Password',
                        hintText: 'Input your password',
                        prefixIcon: Icons.lock_outline,
                        isPassword: _obscurePassword,
                        controller: _passwordController,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: AppColors.textSecondaryLight,
                          ),
                          onPressed: () => setState(
                              () => _obscurePassword = !_obscurePassword),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Remember Me & Forgot Password
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              SizedBox(
                                width: 24,
                                height: 24,
                                child: Checkbox(
                                  value: _rememberMe,
                                  onChanged: (v) =>
                                      setState(() => _rememberMe = v ?? false),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(6)),
                                  activeColor: AppColors.primary,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Remember me',
                                style: AppTypography.textTheme.bodyMedium
                                    ?.copyWith(
                                        color: AppColors.textSecondaryLight),
                              ),
                            ],
                          ),
                          TextButton(
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const ResetPasswordScreen()),
                            ),
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: Text(
                              'Forgot Password?',
                              style: AppTypography.textTheme.bodyMedium
                                  ?.copyWith(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w500),
                            ),
                          ),
                        ],
                      ),

                      // Error message
                      if (_errorMessage != null) ...[
                        const SizedBox(height: 16),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.red.shade200),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.error_outline,
                                  color: Colors.red.shade600, size: 18),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _errorMessage!,
                                  style: TextStyle(
                                      color: Colors.red.shade700,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      const SizedBox(height: 32),

                      // Login Button
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _handleLogin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(32)),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                      color: Colors.white, strokeWidth: 2.5),
                                )
                              : Text(
                                  'Sign In',
                                  style:
                                      AppTypography.textTheme.bodyLarge?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Divider
                      Row(
                        children: [
                          Expanded(
                              child: Container(
                                  height: 1,
                                  color: AppColors.textMutedLight
                                      .withOpacity(0.3))),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              'Or Sign in with',
                              style: AppTypography.textTheme.labelSmall
                                  ?.copyWith(
                                      color: AppColors.textSecondaryLight),
                            ),
                          ),
                          Expanded(
                              child: Container(
                                  height: 1,
                                  color: AppColors.textMutedLight
                                      .withOpacity(0.3))),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Social Buttons (UI only — no Google SDK yet)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SocialCircleButton(
                            letter: 'G',
                            color: Colors.blue,
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                      'Google Sign-In coming soon. Use email for now.'),
                                  backgroundColor: AppColors.primary,
                                ),
                              );
                            },
                          ),
                          const SizedBox(width: 16),
                          SocialCircleButton(
                            icon: Icons.apple,
                            color: Colors.black,
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                      'Apple Sign-In coming soon. Use email for now.'),
                                  backgroundColor: AppColors.primary,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),

                      // Register Link
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Don't have an account? ",
                            style: AppTypography.textTheme.bodyMedium?.copyWith(
                                color: AppColors.textPrimaryLight,
                                fontWeight: FontWeight.w600),
                          ),
                          GestureDetector(
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const SignupScreen()),
                            ),
                            child: Text(
                              'Register',
                              style: AppTypography.textTheme.bodyMedium
                                  ?.copyWith(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w700),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
