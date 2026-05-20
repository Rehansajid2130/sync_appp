import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../core/services/auth_service.dart';
import '../../core/data/mock_data.dart';
import '../../widgets/new_ui/radial_time_picker.dart';
import '../booking_date_screen.dart';
import '../../models/service_provider.dart';
import '../../core/routes/app_routes.dart';

class NewProviderDetailScreen extends StatefulWidget {
  final Map<String, dynamic>? providerData;

  const NewProviderDetailScreen({super.key, this.providerData});

  @override
  State<NewProviderDetailScreen> createState() => _NewProviderDetailScreenState();
}

class _NewProviderDetailScreenState extends State<NewProviderDetailScreen> {
  int _activeTabIndex = 0;
  bool _isBioExpanded = false;

  final List<String> _tabs = ["About", "Reviews", "Availability"];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Extract provider from arguments
    final args = widget.providerData ?? ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final ServiceProvider? realProvider = args?['provider'] as ServiceProvider?;
    final Map<String, dynamic> provider = args?['providerData'] ?? 
        {
          "name": realProvider?.name ?? "Dr. Jonah Hill",
          "specialty": "${realProvider?.category ?? "Cognitive Behavioral"} Specialist",
          "rating": realProvider?.rating.toString() ?? "4.9",
          "reviews": realProvider?.reviewCount.toString() ?? "120",
          "slots": "Immediate Slot Open",
          "image": "https://images.unsplash.com/photo-1559839734-2b71ea197ec2?auto=format&fit=crop&q=80&w=600",
        };

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF090909) : Colors.white,
      body: Stack(
        children: [
          // 1. Body Scroll Sheet
          Positioned.fill(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top half: Stack background image blending smoothly
                  Stack(
                    children: [
                      Container(
                        height: 380,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: NetworkImage(provider['image']),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      // Smooth gradient overlay to blend into canvas background
                      Container(
                        height: 380,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.transparent,
                              (isDark ? const Color(0xFF090909) : Colors.white).withOpacity(0.4),
                              isDark ? const Color(0xFF090909) : Colors.white,
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                      ),
                      // Info Overlays layered on top of the image
                      Positioned(
                        left: 16,
                        right: 16,
                        bottom: 20,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Specialty subtitle
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: AppColors.pastelBlue,
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          provider['specialty'].toString().split(' - ').first,
                                          style: GoogleFonts.nunito(
                                            color: AppColors.charcoalDark,
                                            fontSize: 11,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      // Provider name
                                      Text(
                                        provider['name'],
                                        style: GoogleFonts.nunito(
                                          fontSize: 28,
                                          fontWeight: FontWeight.w900,
                                          color: isDark ? Colors.white : AppColors.textDark,
                                          letterSpacing: -0.8,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // Direct message circular icon button
                                GestureDetector(
                                  onTap: () {
                                    final name = AuthService.currentUser?.name ?? MockData.currentUserName;
                                    final providerName = provider['name'];
                                    
                                    // Check if there's an accepted/confirmed booking with this provider
                                    final hasConfirmedBooking = MockData.bookings.any((b) => 
                                      b.clientName == name && 
                                      b.providerName == providerName && 
                                      b.status == 'Upcoming'
                                    );

                                    if (hasConfirmedBooking) {
                                      final booking = MockData.bookings.firstWhere((b) => 
                                        b.clientName == name && 
                                        b.providerName == providerName && 
                                        b.status == 'Upcoming'
                                      );
                                      Navigator.pushNamed(
                                        context,
                                        AppRoutes.chatDetail,
                                        arguments: {
                                          'providerName': providerName,
                                          'providerImage': provider['image'],
                                          'bookingId': booking.id,
                                        },
                                      );
                                    } else {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            "Chat is locked. Confirm your booking first to start messaging.",
                                            style: GoogleFonts.nunito(fontWeight: FontWeight.w700),
                                          ),
                                          backgroundColor: AppColors.charcoalDark,
                                          behavior: SnackBarBehavior.floating,
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                          action: SnackBarAction(
                                            label: "Book Now",
                                            textColor: AppColors.pastelBlue,
                                            onPressed: () => _navigateToBookingScreen(context, provider),
                                          ),
                                        ),
                                      );
                                    }
                                  },
                                  child: Container(
                                    width: 50,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      color: isDark ? const Color(0xFF161616) : Colors.white,
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.08),
                                          blurRadius: 16,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                      border: Border.all(
                                        color: isDark ? Colors.white10 : Colors.black.withOpacity(0.05),
                                      ),
                                    ),
                                    child: Icon(
                                      Icons.forum_outlined,
                                      color: isDark ? Colors.white : AppColors.textDark,
                                      size: 22,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            // Ratings and Rate Row
                            Row(
                              children: [
                                const Icon(Icons.star_rounded, color: Color(0xFFEAA200), size: 18),
                                const SizedBox(width: 4),
                                Text(
                                  "${provider['rating']} (${provider['reviews']} reviews)",
                                  style: GoogleFonts.nunito(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                    color: isDark ? Colors.white70 : AppColors.textDark,
                                  ),
                                ),
                                ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  // 2. Performance Matrix Banner Grid
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF161616) : AppColors.offWhite,
                        borderRadius: BorderRadius.circular(24.0),
                        border: Border.all(
                          color: isDark ? Colors.white.withOpacity(0.05) : AppColors.mutedGray.withOpacity(0.15),
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 18.0),
                      child: Row(
                        children: [
                          _buildStatColumn("Rating", "${provider['rating']} ★", isDark),
                          Container(width: 1, height: 32, color: isDark ? Colors.white10 : Colors.black12),
                          _buildStatColumn("Reviews", "${provider['reviews']}", isDark),
                          Container(width: 1, height: 32, color: isDark ? Colors.white10 : Colors.black12),
                          _buildStatColumn("Experience", "Verified", isDark),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 3. Tab-Bar Controller System
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: List.generate(_tabs.length, (index) {
                        final bool isActive = _activeTabIndex == index;
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _activeTabIndex = index;
                            });
                          },
                          child: Padding(
                            padding: const EdgeInsets.only(right: 28.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _tabs[index],
                                  style: GoogleFonts.nunito(
                                    fontSize: 16,
                                    fontWeight: isActive ? FontWeight.w900 : FontWeight.w700,
                                    color: isActive 
                                        ? (isDark ? Colors.white : AppColors.textDark) 
                                        : AppColors.textMutedGray,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                // Animated line strip running underneath selected header
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  height: 3,
                                  width: isActive ? 24 : 0,
                                  decoration: BoxDecoration(
                                    color: AppColors.deepTeal,
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                  const SizedBox(height: 18),

                  // 4. Tab Body Content Panels
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: _buildActiveTabBody(isDark),
                  ),
                  const SizedBox(height: 120), // Spacer for sticky bottom button
                ],
              ),
            ),
          ),

          // 2. Floating Custom Back Button
          Positioned(
            top: 50,
            left: 16,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF161616) : Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.arrow_back_rounded,
                  color: isDark ? Colors.white : AppColors.textDark,
                  size: 20,
                ),
              ),
            ),
          ),

          // 3. Fixed Sticky Bottom Action Button
          Positioned(
            left: 16,
            right: 16,
            bottom: 24,
            child: SafeArea(
              child: ElevatedButton(
                onPressed: () => _navigateToBookingScreen(context, provider),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.deepTeal,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 56),
                  shape: const StadiumBorder(),
                  elevation: 4,
                  shadowColor: AppColors.deepTeal.withOpacity(0.3),
                ),
                child: Text(
                  "Book Appointment Now",
                  style: GoogleFonts.nunito(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatColumn(String label, String value, bool isDark) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: GoogleFonts.nunito(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: isDark ? Colors.white : AppColors.textDark,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.nunito(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.textMutedGray,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveTabBody(bool isDark) {
    if (_activeTabIndex == 0) {
      // About Tab Body (Long-form paragraph & Bio expansion)
      final String fullBio = "Dr. Jonah Hill is a highly skilled Cognitive Behavioral Therapist with over 12 years of clinical research and practice specializing in acute anxiety disorders, cognitive reprogramming, and stress management. His patient-first philosophy integrates evidence-based treatments with modern mindfulness strategies. Dr. Jonah has successfully guided thousands of individuals toward sustainable mental wellness and balanced life coordination in top-tier healthcare infrastructures across the country.";
      
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Biography",
            style: GoogleFonts.nunito(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: isDark ? Colors.white : AppColors.textDark,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _isBioExpanded ? fullBio : "${fullBio.substring(0, 160)}...",
            style: GoogleFonts.nunito(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white70 : AppColors.textSecondaryLight,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 4),
          GestureDetector(
            onTap: () {
              setState(() {
                _isBioExpanded = !_isBioExpanded;
              });
            },
            child: Text(
              _isBioExpanded ? "see less" : "see more...",
              style: GoogleFonts.nunito(
                color: AppColors.deepTeal,
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      );
    } else if (_activeTabIndex == 1) {
      // Reviews Tab Body (global score metrics and stars)
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Patient Reviews",
            style: GoogleFonts.nunito(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: isDark ? Colors.white : AppColors.textDark,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text(
                "4.9",
                style: GoogleFonts.nunito(
                  fontSize: 48,
                  fontWeight: FontWeight.w900,
                  color: isDark ? Colors.white : AppColors.textDark,
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: List.generate(5, (index) {
                      return const Icon(Icons.star_rounded, color: Color(0xFFEAA200), size: 20);
                    }),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Based on 140 ratings",
                    style: GoogleFonts.nunito(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textMutedGray,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Short review snip
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withOpacity(0.02) : AppColors.surfaceLightGray,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Marcus Vance",
                      style: GoogleFonts.nunito(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: isDark ? Colors.white : AppColors.textDark,
                      ),
                    ),
                    Text(
                      "Yesterday",
                      style: GoogleFonts.nunito(
                        fontSize: 11,
                        color: AppColors.textMutedGray,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  "Outstanding session! Dr. Jonah instantly made me feel heard. The schedule layout was seamless and snapping coordinates with the picker was super clean.",
                  style: GoogleFonts.nunito(
                    fontSize: 12,
                    color: isDark ? Colors.white70 : AppColors.textSecondaryLight,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    } else {
      // Availability Tab
      final args = widget.providerData ?? ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      final ServiceProvider? realProvider = args?['provider'] as ServiceProvider?;
      final List<String> slots = realProvider?.availableTimes ?? ["09:00 AM", "11:00 AM", "02:00 PM", "04:00 PM"];

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Working Schedule",
            style: GoogleFonts.nunito(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: isDark ? Colors.white : AppColors.textDark,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            "This provider is available at the following time slots:",
            style: GoogleFonts.nunito(
              fontSize: 13,
              color: isDark ? Colors.white60 : AppColors.textSecondaryLight,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: slots.map((slot) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.deepTeal.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.deepTeal.withOpacity(0.1)),
              ),
              child: Text(
                slot,
                style: GoogleFonts.nunito(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: AppColors.deepTeal,
                ),
              ),
            )).toList(),
          ),
        ],
      );
    }
  }

  void _navigateToBookingScreen(BuildContext context, Map<String, dynamic> providerMap) {
    // Try to get the real provider object first
    final args = widget.providerData ?? ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final ServiceProvider? realProvider = args?['provider'] as ServiceProvider?;

    final mockProvider = realProvider ?? ServiceProvider(
      id: 'mock_provider_${providerMap['name']}',
      name: providerMap['name']?.toString() ?? 'Provider',
      category: providerMap['specialty']?.toString() ?? 'Service',
      rating: double.tryParse(providerMap['rating']?.toString() ?? '4.9') ?? 4.9,
      reviewCount: int.tryParse(providerMap['reviews']?.toString() ?? '100') ?? 100,
      location: 'Virtual / Home',
      icon: Icons.person,
      avatarColor: AppColors.primary,
      availableTimes: [],
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BookingDateScreen(provider: mockProvider),
      ),
    );
  }
}
