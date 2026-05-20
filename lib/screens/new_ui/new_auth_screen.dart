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

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
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
        MockData.currentUserName = result.user!.name;
        MockData.currentUserEmail = result.user!.email;
        MockData.isUserRegisteredAsProvider = result.user!.isProvider;

        await MockData.init();

        if (!mounted) return;

        if (result.user!.isProvider) {
          await StorageService.saveData('activeRole', 'Provider');
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
      
      final result = await AuthService.signUp(
        name: _nameController.text,
        email: _emailController.text,
        password: _passwordController.text,
        isProvider: _isProvider,
      );

      if (!mounted) return;

      if (result.success && result.user != null) {
        final loginResult = await AuthService.signIn(
          email: _emailController.text,
          password: _passwordController.text,
        );

        if (!mounted) return;

        if (loginResult.success && loginResult.user != null) {
          MockData.currentUserName = loginResult.user!.name;
          MockData.currentUserEmail = loginResult.user!.email;
          MockData.isUserRegisteredAsProvider = loginResult.user!.isProvider;
        }

        await MockData.init();

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
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

  Future<void> _handleSocialAuth(String provider) async {
    setState(() {
      _errorMessage = null;
      _isLoading = true;
    });

    final result = await AuthService.signInWithSocial(provider: provider);

    if (!mounted) return;

    if (result.success && result.user != null) {
      MockData.currentUserName = result.user!.name;
      MockData.currentUserEmail = result.user!.email;
      MockData.isUserRegisteredAsProvider = result.user!.isProvider;

      await MockData.init();

      if (!mounted) return;

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
    } else {
      setState(() {
        _isLoading = false;
        _errorMessage = result.message;
      });
    }
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
                  // Vector Illustration Pattern
                  Positioned(
                    right: -20,
                    top: 20,
                    child: Opacity(
                      opacity: 0.12,
                      child: Icon(
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
                      child: Icon(
                        Icons.auto_awesome,
                        size: 90,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  // App branding & Welcome Message
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

                          // Full registration name field if sign-up mode
                          if (!_isLoginMode) ...[
                            _buildInputField(
                              controller: _nameController,
                              hintText: "Full Name",
                              prefixIcon: Icons.person_outline_rounded,
                              isDark: isDark,
                            ),
                            const SizedBox(height: 16),
                          ],

                          // Email Field Specs (TextFormField)
                          _buildInputField(
                            controller: _emailController,
                            hintText: "Email Address",
                            prefixIcon: Icons.alternate_email_rounded,
                            isDark: isDark,
                          ),
                          const SizedBox(height: 16),

                          // Password Field Specs (TextFormField)
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

                          // Forgot Password or Role Toggle
                          if (_isLoginMode) ...[
                            Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                "Forgot password?",
                                style: GoogleFonts.nunito(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.deepTeal,
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
                                      height: 44,
                                      decoration: BoxDecoration(
                                        color: !_isProvider
                                            ? AppColors.deepTeal
                                            : (isDark ? const Color(0xFF1E1E1E) : AppColors.surfaceLightGray),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(
                                        "Book Helpers",
                                        style: GoogleFonts.nunito(
                                          fontSize: 13,
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
                                      height: 44,
                                      decoration: BoxDecoration(
                                        color: _isProvider
                                            ? AppColors.deepTeal
                                            : (isDark ? const Color(0xFF1E1E1E) : AppColors.surfaceLightGray),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(
                                        "Provide Services",
                                        style: GoogleFonts.nunito(
                                          fontSize: 13,
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

                          // Dynamic Error Message Display
                          if (_errorMessage != null) ...[
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFECEC),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: const Color(0xFFFFCCCC)),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.error_outline_rounded, color: Color(0xFFD32F2F), size: 20),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      _errorMessage!,
                                      style: GoogleFonts.nunito(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: const Color(0xFFD32F2F),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],

                          // Action Links & Button Row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              GestureDetector(
                                onTap: _isLoading
                                    ? null
                                    : () {
                                        setState(() {
                                          _isLoginMode = !_isLoginMode;
                                          _errorMessage = null;
                                        });
                                      },
                                child: Text(
                                  _isLoginMode ? "Sign up" : "Already registered? Login",
                                  style: GoogleFonts.nunito(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.deepTeal,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                              ElevatedButton(
                                onPressed: _isLoading ? null : _handleAuth,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.deepTeal,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                                  shape: const StadiumBorder(),
                                  elevation: 0,
                                ),
                                child: _isLoading
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : Text(
                                        _isLoginMode ? "Login" : "Submit",
                                        style: GoogleFonts.nunito(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w800,
                                          color: Colors.white,
                                        ),
                                      ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 32),

                          // Social Authentication Splitter & Oauth Icons
                          Row(
                            children: [
                              Expanded(child: Divider(color: isDark ? Colors.white12 : Colors.black12)),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 14.0),
                                child: Text(
                                  "Or",
                                  style: GoogleFonts.nunito(
                                    fontSize: 12,
                                    color: AppColors.textMutedGray,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              Expanded(child: Divider(color: isDark ? Colors.white12 : Colors.black12)),
                            ],
                          ),
                          const SizedBox(height: 24),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildSocialIcon(Icons.facebook_rounded, Colors.blue[800]!, isDark, () => _handleSocialAuth('Facebook')),
                              const SizedBox(width: 20),
                              _buildSocialIcon(Icons.apple_rounded, isDark ? Colors.white : Colors.black, isDark, () => _handleSocialAuth('Apple')),
                              const SizedBox(width: 20),
                              _buildSocialIcon(Icons.alternate_email_rounded, Colors.red[700]!, isDark, () => _handleSocialAuth('Google')), // Google proxy
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Custom back round icon
          Positioned(
            top: 50,
            left: 16,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white30),
                ),
                child: const Icon(
                  Icons.arrow_back_rounded,
                  color: Colors.white,
                  size: 20,
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

  Widget _buildSocialIcon(IconData icon, Color color, bool isDark, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isDark ? const Color(0xFF1E1E1E) : AppColors.surfaceLightGray,
          border: Border.all(
            color: isDark ? Colors.white.withOpacity(0.06) : Colors.black.withOpacity(0.04),
          ),
        ),
        child: Icon(
          icon,
          color: color,
          size: 24,
        ),
      ),
    );
  }
}
