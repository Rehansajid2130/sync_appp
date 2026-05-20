import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme/app_colors.dart';
import 'new_ui/new_navigation_wrapper.dart';

class BookingSuccessScreen extends StatelessWidget {
  final bool isPending;
  const BookingSuccessScreen({super.key, this.isPending = false});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.offWhite,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 40.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              // Morphic Success Icon
              Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  color: AppColors.pastelGreen.withOpacity(0.3),
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.pastelGreen, width: 2),
                ),
                child: Center(
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: AppColors.pastelGreen,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.green.withOpacity(0.2),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.check_rounded, color: Color(0xFF1A6B3C), size: 60),
                  ),
                ),
              ),
              const SizedBox(height: 48),
              Text(
                isPending ? 'Request Sent!' : 'Booking Confirmed!',
                style: GoogleFonts.nunito(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  color: isDark ? Colors.white : AppColors.charcoalDark,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                isPending
                    ? 'Your service request has been sent successfully. The provider will review and approve it shortly.'
                    : 'Great news! Your booking is confirmed. Our expert professional is getting ready to serve you.',
                textAlign: TextAlign.center,
                style: GoogleFonts.nunito(
                  fontSize: 16,
                  color: isDark ? Colors.white70 : AppColors.mutedGray,
                  height: 1.6,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              // Bottom Action Panel
              Container(
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF111111) : Colors.white,
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: [
                    if (!isDark)
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                  ],
                ),
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: 58,
                      child: ElevatedButton(
                        onPressed: () {
                          // Navigate to NewNavigationWrapper which uses NewHomeDashboard
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(builder: (context) => const NewNavigationWrapper()),
                            (route) => false,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.deepTeal,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                        ),
                        child: Text(
                          'Done, Back Home',
                          style: GoogleFonts.nunito(fontWeight: FontWeight.w900, fontSize: 18),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () {
                        // For now back to home, but could navigate to specific booking details
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (context) => const NewNavigationWrapper()),
                          (route) => false,
                        );
                      },
                      child: Text(
                        'View Booking Status',
                        style: GoogleFonts.nunito(
                          color: AppColors.deepTeal,
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                        ),
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
