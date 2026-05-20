import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme/app_colors.dart';
import '../core/services/storage_service.dart';
import 'new_ui/new_auth_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> _onboardingData = [
    {
      'title': 'Find Expert Help',
      'description': 'Discover top-rated professionals for all your home needs, from cleaning to repairs.',
      'image': '🏠',
    },
    {
      'title': 'Easy Booking',
      'description': 'Schedule services at your convenience with just a few taps on your phone.',
      'image': '📅',
    },
    {
      'title': 'Premium Quality',
      'description': 'We ensure every service provider is vetted and committed to excellence.',
      'image': '✨',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.offWhite,
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (value) => setState(() => _currentPage = value),
              itemCount: _onboardingData.length,
              itemBuilder: (context, index) => _buildPage(index, isDark),
            ),
          ),
          _buildBottomControls(isDark),
        ],
      ),
    );
  }

  Widget _buildPage(int index, bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(40.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 240, height: 240,
            decoration: BoxDecoration(
              color: AppColors.deepTeal.withOpacity(0.08), 
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.deepTeal.withOpacity(0.1), width: 1),
            ),
            child: Center(child: Text(_onboardingData[index]['image']!, style: const TextStyle(fontSize: 100))),
          ),
          const SizedBox(height: 60),
          Text(
            _onboardingData[index]['title']!,
            textAlign: TextAlign.center,
            style: GoogleFonts.nunito(
              fontSize: 32, 
              fontWeight: FontWeight.w900, 
              color: isDark ? Colors.white : AppColors.charcoalDark,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            _onboardingData[index]['description']!,
            textAlign: TextAlign.center,
            style: GoogleFonts.nunito(
              fontSize: 17, 
              color: isDark ? Colors.white70 : AppColors.mutedGray, 
              height: 1.6,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomControls(bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 60),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              _onboardingData.length,
              (index) => AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.only(right: 8),
                height: 8,
                width: _currentPage == index ? 32 : 8,
                decoration: BoxDecoration(
                  color: _currentPage == index ? AppColors.deepTeal : AppColors.mutedGray.withOpacity(0.3), 
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
          const SizedBox(height: 40),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () {
                if (_currentPage == _onboardingData.length - 1) {
                  _completeOnboarding();
                } else {
                  _pageController.nextPage(
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeInOut,
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.deepTeal,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
                elevation: 0,
              ),
              child: Text(
                _currentPage == _onboardingData.length - 1 ? 'Get Started' : 'Continue',
                style: GoogleFonts.nunito(fontSize: 18, fontWeight: FontWeight.w800),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _completeOnboarding() async {
    await StorageService.setFirstTime(false);
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const NewAuthScreen()),
      );
    }
  }
}
