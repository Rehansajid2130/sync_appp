import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme/app_colors.dart';
import '../core/services/auth_service.dart';
import '../core/services/storage_service.dart';
import '../core/data/mock_data.dart';
import 'new_ui/new_navigation_wrapper.dart';
import 'new_ui/new_auth_screen.dart';
import 'onboarding_screen.dart';
import 'address_setup_screen.dart';
import 'provider/provider_setup_screen.dart';
import 'provider/provider_navigation_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _scaleAnimation =
        CurvedAnimation(parent: _controller, curve: Curves.elasticOut);
    _fadeAnimation =
        CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();
    _bootstrap();
  }

  /// Initialises all services then decides where to route.
  Future<void> _bootstrap() async {
    // Run init and the 3-second splash concurrently
    await Future.wait([
      MockData.init(),
      Future.delayed(const Duration(seconds: 3)),
    ]);

    if (!mounted) return;

    // 1. Try to restore a saved login session
    final user = await AuthService.restoreSession();

    if (user != null) {
      // Sync the restored user into MockData
      MockData.currentUserName = user.name;
      MockData.currentUserEmail = user.email;
      MockData.isUserRegisteredAsProvider = user.isProvider;

      if (!mounted) return;
      if (user.isProvider) {
        final activeRole = StorageService.getData('activeRole') ?? 'Provider';
        if (activeRole == 'Customer') {
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
          final hasListing = MockData.providers.any((p) => p.id == user.uid || p.name == user.name);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => hasListing 
                  ? const ProviderNavigationScreen() 
                  : const ProviderSetupScreen(),
            ),
          );
        }
      } else {
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
      return;
    }

    // 2. No session — show onboarding only if first time, otherwise force login
    if (StorageService.isFirstTime()) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const OnboardingScreen()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const NewAuthScreen()),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark 
              ? [const Color(0xFF090909), const Color(0xFF1A1A1A)]
              : [AppColors.deepTeal, AppColors.pastelBlue],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ScaleTransition(
                scale: _scaleAnimation,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white24, width: 2),
                  ),
                  child: const Icon(
                    Icons.sync_alt_rounded,
                    color: Colors.white,
                    size: 70,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  children: [
                    Text(
                      'HelperHive',
                      style: GoogleFonts.nunito(
                        fontSize: 40,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Your home, sorted.',
                      style: GoogleFonts.nunito(
                        fontSize: 16,
                        color: Colors.white70,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
