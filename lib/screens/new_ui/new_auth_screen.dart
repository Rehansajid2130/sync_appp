import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/storage_service.dart';
import '../../core/data/mock_data.dart';
import 'new_navigation_wrapper.dart';
import '../address_setup_screen.dart';
import '../provider/provider_setup_screen.dart';
import '../provider/provider_navigation_screen.dart';
import '../create_new_password_screen.dart';

class NewAuthScreen extends StatefulWidget {
  const NewAuthScreen({super.key});

  @override
  State<NewAuthScreen> createState() => _NewAuthScreenState();
}

class _NewAuthScreenState extends State<NewAuthScreen> {
  bool _isLoginMode = true;
  bool _obscurePassword = true;
  bool _isProvider = false;
  bool _isLoading = false;
  String? _errorMessage;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _handleAuth() async {
    setState(() {
      _errorMessage = null;
      _isLoading = true;
    });

    if (_isLoginMode) {
      final result = await AuthService.signIn(
        email: _emailController.text,
        password: _passwordController.text,
        rememberMe: true,
      );

      if (!mounted) return;

      if (result.success && result.user != null) {
        if (!mounted) return;

        if (result.user!.isProvider) {
          await StorageService.saveData('activeRole', 'Provider');
          final hasListing = MockData.providers.any((p) => p.id == result.user!.uid);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => hasListing 
                  ? const ProviderNavigationScreen() 
                  : const ProviderSetupScreen(),
            ),
          );
        } else {
          await StorageService.saveData('activeRole', 'Customer');
          final hasAddress = MockData.addresses.isNotEmpty;
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => hasAddress 
                  ? const NewNavigationWrapper() 
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
    } else {
      if (_nameController.text.trim().isEmpty) {
        setState(() {
          _isLoading = false;
          _errorMessage = "Please enter your name.";
        });
        return;
      }
      if (_phoneController.text.trim().isEmpty) {
        setState(() {
          _isLoading = false;
          _errorMessage = "Please enter your phone number so users can contact you.";
        });
        return;
      }
      
      final result = await AuthService.signUp(
        name: _nameController.text,
        email: _emailController.text,
        password: _passwordController.text,
        phone: _phoneController.text,
        isProvider: _isProvider,
      );

      if (!mounted) return;

      if (result.success && result.user != null) {
        // Automatically login after signup
        final loginResult = await AuthService.signIn(
          email: _emailController.text,
          password: _passwordController.text,
        );

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Account created successfully!"),
            backgroundColor: AppColors.secondaryGreen,
          ),
        );

        if (_isProvider) {
          await StorageService.saveData('activeRole', 'Provider');
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const ProviderSetupScreen()),
          );
        } else {
          await StorageService.saveData('activeRole', 'Customer');
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const AddressSetupScreen()),
          );
        }
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = result.message;
        });
      }
    }
  }

  Future<void> _handleForgotPassword() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      setState(() {
        _errorMessage = "Please enter your email to reset the password.";
      });
      return;
    }
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateNewPasswordScreen(email: email),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF090909) : Colors.white,
      body: Stack(
        children: [
          // 1. Immersive Background Brand Media Canvas (Top 40%)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: MediaQuery.of(context).size.height * 0.44,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.deepTeal, AppColors.pastelBlue],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Stack(
                children: [
                  Positioned(
                    right: -20,
                    top: 20,
                    child: Opacity(
                      opacity: 0.12,
                      child: const Icon(
                        Icons.insights_outlined,
                        size: 280,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Positioned(
                    left: 30,
                    bottom: 70,
                    child: Opacity(
                      opacity: 0.1,
                      child: const Icon(
                        Icons.auto_awesome,
                        size: 90,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white24, width: 2),
                          ),
                          child: const Icon(
                            Icons.sync_alt_rounded,
                            color: Colors.white,
                            size: 36,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          "SYNC APP",
                          style: GoogleFonts.nunito(
                            fontSize: 26,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: 2.0,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Premium Service Orchestration",
                          style: GoogleFonts.nunito(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 2. The Float Bottom Sheet Card
          Positioned.fill(
            child: NotificationListener<OverscrollIndicatorNotification>(
              onNotification: (notification) {
                notification.disallowIndicator();
                return true;
              },
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                child: Column(
                  children: [
                    SizedBox(height: MediaQuery.of(context).size.height * 0.38),
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF121211) : Colors.white,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(36.0),
                          topRight: Radius.circular(36.0),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.12),
                            blurRadius: 24,
                            offset: const Offset(0, -6),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _isLoginMode ? "Welcome Back" : "Create Account",
                            style: GoogleFonts.nunito(
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                              color: isDark ? Colors.white : AppColors.textDark,
                              letterSpacing: -0.6,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            _isLoginMode 
                                ? "Enter your scheduling credentials to sync." 
                                : "Join the premium service optimization network.",
                            style: GoogleFonts.nunito(
                              fontSize: 13,
                              color: AppColors.textMutedGray,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 28),

                          if (!_isLoginMode) ...[
                            _buildInputField(
                              controller: _nameController,
                              hintText: "Full Name",
                              prefixIcon: Icons.person_outline_rounded,
                              isDark: isDark,
                            ),
                            const SizedBox(height: 16),
                            _buildInputField(
                              controller: _phoneController,
                              hintText: "Phone Number",
                              prefixIcon: Icons.phone_outlined,
                              isDark: isDark,
                            ),
                            const SizedBox(height: 16),
                          ],

                          _buildInputField(
                            controller: _emailController,
                            hintText: "Email Address",
                            prefixIcon: Icons.alternate_email_rounded,
                            isDark: isDark,
                          ),
                          const SizedBox(height: 16),

                          _buildInputField(
                            controller: _passwordController,
                            hintText: "Password",
                            prefixIcon: Icons.lock_outline_rounded,
                            suffixIcon: _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                            obscureText: _obscurePassword,
                            isDark: isDark,
                            onSuffixTap: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                          const SizedBox(height: 12),

                          if (_isLoginMode) ...[
                            Align(
                              alignment: Alignment.centerRight,
                              child: GestureDetector(
                                onTap: _handleForgotPassword,
                                child: Text(
                                  "Forgot password?",
                                  style: GoogleFonts.nunito(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.deepTeal,
                                  ),
                                ),
                              ),
                            ),
                          ] else ...[
                            const SizedBox(height: 12),
                            Text(
                              "I want to:",
                              style: GoogleFonts.nunito(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  color: isDark ? Colors.white70 : AppColors.textDark,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _isProvider = false;
                                      });
                                    },
                                    child: Container(
                                      height: 48,
                                      decoration: BoxDecoration(
                                        color: !_isProvider
                                            ? AppColors.deepTeal
                                            : (isDark ? const Color(0xFF1E1E1E) : AppColors.surfaceLightGray),
                                        borderRadius: BorderRadius.circular(12),
                                        border: !_isProvider ? Border.all(color: Colors.greenAccent, width: 2) : null,
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(
                                        "Book Helpers",
                                        style: GoogleFonts.nunito(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w800,
                                          color: !_isProvider
                                              ? Colors.white
                                              : (isDark ? Colors.white70 : AppColors.textDark),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _isProvider = true;
                                      });
                                    },
                                    child: Container(
                                      height: 48,
                                      decoration: BoxDecoration(
                                        color: _isProvider
                                            ? AppColors.deepTeal
                                            : (isDark ? const Color(0xFF1E1E1E) : AppColors.surfaceLightGray),
                                        borderRadius: BorderRadius.circular(12),
                                        border: _isProvider ? Border.all(color: Colors.greenAccent, width: 2) : null,
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(
                                        "Provide Services",
                                        style: GoogleFonts.nunito(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w800,
                                          color: _isProvider
                                              ? Colors.white
                                              : (isDark ? Colors.white70 : AppColors.textDark),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                          const SizedBox(height: 24),

                          if (_errorMessage != null) ...[
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              decoration: BoxDecoration(
                                color: _errorMessage!.contains('successfully') || _errorMessage!.contains('sent')
                                    ? const Color(0xFFE8F5E9)
                                    : const Color(0xFFFFECEC),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: _errorMessage!.contains('successfully') || _errorMessage!.contains('sent')
                                      ? Colors.green
                                      : const Color(0xFFFFCCCC)
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    _errorMessage!.contains('successfully') || _errorMessage!.contains('sent')
                                      ? Icons.check_circle_outline
                                      : Icons.error_outline_rounded, 
                                    color: _errorMessage!.contains('successfully') || _errorMessage!.contains('sent')
                                      ? Colors.green
                                      : const Color(0xFFD32F2F), 
                                    size: 20
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      _errorMessage!,
                                      style: GoogleFonts.nunito(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: _errorMessage!.contains('successfully') || _errorMessage!.contains('sent')
                                          ? Colors.green[800]
                                          : const Color(0xFFD32F2F),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],

                          // Main Action Button (Sign In / Sign Up)
                          SizedBox(
                            width: double.infinity,
                            height: 54,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _handleAuth,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.deepTeal,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                elevation: 0,
                              ),
                              child: _isLoading
                                  ? const SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(strokeWidth: 3, color: Colors.white),
                                    )
                                  : Text(
                                      _isLoginMode ? "Login" : "Sign Up",
                                      style: GoogleFonts.nunito(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w800,
                                        color: Colors.white,
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Toggle Mode Button
                          Center(
                            child: GestureDetector(
                              onTap: _isLoading
                                  ? null
                                  : () {
                                      setState(() {
                                        _isLoginMode = !_isLoginMode;
                                        _errorMessage = null;
                                      });
                                    },
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  _isLoginMode ? "Don't have an account? Sign up" : "Already registered? Login",
                                  style: GoogleFonts.nunito(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.deepTeal,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String hintText,
    required IconData prefixIcon,
    IconData? suffixIcon,
    bool obscureText = false,
    required bool isDark,
    VoidCallback? onSuffixTap,
  }) {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : AppColors.surfaceLightGray,
        borderRadius: BorderRadius.circular(16.0),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        children: [
          Icon(prefixIcon, color: AppColors.textMutedGray, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              obscureText: obscureText,
              style: GoogleFonts.nunito(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : AppColors.textDark,
              ),
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: GoogleFonts.nunito(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textMutedGray,
                ),
                border: InputBorder.none,
                isDense: true,
              ),
            ),
          ),
          if (suffixIcon != null)
            GestureDetector(
              onTap: onSuffixTap,
              child: Icon(suffixIcon, color: AppColors.textMutedGray, size: 20),
            ),
        ],
      ),
    );
  }
}
