import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../core/services/auth_service.dart';
import '../splash_screen.dart';
import '../../core/data/mock_data.dart';
import '../../core/services/review_service.dart';
import '../../models/review.dart';
import 'package:intl/intl.dart';
import 'edit_business_profile_screen.dart';
import '../../core/services/storage_service.dart';
import '../../models/service_provider.dart';

class ProviderStorefrontScreen extends StatefulWidget {
  const ProviderStorefrontScreen({super.key});

  @override
  State<ProviderStorefrontScreen> createState() => _ProviderStorefrontScreenState();
}

class _ProviderStorefrontScreenState extends State<ProviderStorefrontScreen> {
  final List<Map<String, dynamic>> _services = [
    {'name': 'Full House Cleaning', 'icon': Icons.cleaning_services_rounded},
    {'name': 'Kitchen Sanitizing', 'icon': Icons.kitchen_rounded},
    {'name': 'Window Washing', 'icon': Icons.window_rounded},
  ];

  final List<String> _portfolioImages = [
    'https://images.unsplash.com/photo-1581578731548-c64695cc6952?auto=format&fit=crop&q=80&w=400',
    'https://images.unsplash.com/photo-1527515637462-cff94eecc1ac?auto=format&fit=crop&q=80&w=400',
    'https://images.unsplash.com/photo-1556909114-f6e7ad7d3136?auto=format&fit=crop&q=80&w=400',
    'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?auto=format&fit=crop&q=80&w=400',
  ];

  void _addService() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: isDark ? const Color(0xFF161616) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Add New Service', style: GoogleFonts.nunito(fontSize: 17, fontWeight: FontWeight.w900, color: isDark ? Colors.white : AppColors.charcoalDark)),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF262626) : AppColors.surfaceLightGray,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: TextField(
                  controller: controller,
                  autofocus: true,
                  style: GoogleFonts.nunito(color: isDark ? Colors.white : AppColors.charcoalDark, fontWeight: FontWeight.w700),
                  decoration: InputDecoration(
                    hintText: 'e.g. Carpet Deep Cleaning',
                    hintStyle: GoogleFonts.nunito(color: AppColors.mutedGray, fontWeight: FontWeight.w600),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.all(16),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        foregroundColor: AppColors.mutedGray,
                        side: BorderSide(color: AppColors.mutedGray.withOpacity(0.3)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: Text('Cancel', style: GoogleFonts.nunito(fontWeight: FontWeight.w800)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        if (controller.text.trim().isNotEmpty) {
                          setState(() => _services.add({'name': controller.text.trim(), 'icon': Icons.check_circle_outline_rounded}));
                          Navigator.pop(context);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.deepTeal,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: Text('Add', style: GoogleFonts.nunito(color: Colors.white, fontWeight: FontWeight.w800)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _addPhoto() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Selecting photo from gallery...', style: GoogleFonts.nunito(color: Colors.white, fontWeight: FontWeight.w700)),
        backgroundColor: AppColors.deepTeal,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        duration: const Duration(seconds: 1),
      ),
    );
    Future.delayed(const Duration(seconds: 1), () {
      setState(() => _portfolioImages.insert(0, 'https://picsum.photos/400/400?random=${DateTime.now().millisecond}'));
    });
  }

  void _viewPhoto(String url) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Image.network(url, fit: BoxFit.cover),
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(color: Colors.white24, shape: BoxShape.circle),
                child: const Icon(Icons.close_rounded, color: Colors.white, size: 24),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final user = AuthService.currentUser;
    final provider = MockData.providers.firstWhere(
      (p) => p.id == user?.uid || p.name == user?.name,
      orElse: () => ServiceProvider(
        id: user?.uid ?? 'james_anderson',
        name: user?.name ?? 'James Anderson',
        category: 'Cleaning',
        rating: 4.9,
        reviewCount: 128,
        location: 'Situ Udik, Bogor',
        icon: Icons.cleaning_services_outlined,
        avatarColor: const Color(0xFF91CBAE),
        availableTimes: const ['08:00 AM', '10:00 AM', '01:00 PM', '03:00 PM'],
        description: 'Professional cleaning specialist with over 5 years of experience in residential and commercial spaces.',
        experience: 5,
      ),
    );

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF090909) : const Color(0xFFF9F9FB),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Hero Header Sliver
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: AppColors.charcoalDark,
            elevation: 0,
            automaticallyImplyLeading: false,
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: GestureDetector(
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EditBusinessProfileScreen())).then((_) => setState(() {})),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), shape: BoxShape.circle),
                    child: const Icon(Icons.edit_rounded, color: Colors.white, size: 18),
                  ),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Background gradient
                  Container(color: AppColors.charcoalDark),
                  // Subtle pattern
                  Positioned.fill(
                    child: Opacity(
                      opacity: 0.04,
                      child: GridView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 8),
                        itemCount: 64,
                        itemBuilder: (_, __) => Container(
                          margin: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                        ),
                      ),
                    ),
                  ),
                  // Content
                  SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 16),
                          Container(
                            width: 90,
                            height: 90,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white24, width: 2),
                            ),
                            child: Icon(provider.icon, size: 50, color: Colors.white),
                          ),
                          const SizedBox(height: 14),
                          Text(
                            provider.name,
                            style: GoogleFonts.nunito(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                                decoration: BoxDecoration(
                                  color: AppColors.deepTeal.withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: AppColors.deepTeal.withOpacity(0.5)),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.verified_rounded, color: Colors.white, size: 13),
                                    const SizedBox(width: 4),
                                    Text('Verified Pro', style: GoogleFonts.nunito(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w800)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Stats Row
                  _buildStatsRow(provider, isDark),
                  const SizedBox(height: 28),

                  // About
                  _buildSectionHeader('About Me', isDark),
                  const SizedBox(height: 12),
                  Text(
                    provider.description.isNotEmpty
                        ? provider.description
                        : 'Professional cleaning specialist with over 5 years of experience in residential and commercial spaces. I use eco-friendly products and state-of-the-art equipment to ensure the highest quality.',
                    style: GoogleFonts.nunito(color: isDark ? Colors.white70 : AppColors.mutedGray, height: 1.6, fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 28),

                  // Services
                  _buildSectionHeader('My Services', isDark, action: 'Add Service', onAction: _addService),
                  const SizedBox(height: 12),
                  ..._services.map((s) => _buildServiceItem(s['name'] as String, s['icon'] as IconData, isDark)),
                  const SizedBox(height: 28),

                  // Portfolio
                  _buildSectionHeader('Portfolio', isDark, action: 'Add Photo', onAction: _addPhoto),
                  const SizedBox(height: 12),
                  _buildPortfolioGrid(isDark),
                  const SizedBox(height: 28),

                  // Reviews Section
                  _buildSectionHeader('Reviews', isDark),
                  const SizedBox(height: 12),
                  _buildReviewsSection(isDark, AuthService.currentUser?.uid ?? 'provider_id_here'),
                  const SizedBox(height: 28),

                  // Switch to Client
                  _buildSwitchButton(isDark),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(ServiceProvider provider, bool isDark) {
    return Row(
      children: [
        _buildStatCard(provider.rating.toString(), 'Rating', Icons.star_rounded, AppColors.pastelYellow, const Color(0xFF9E7C00), isDark),
        const SizedBox(width: 10),
        _buildStatCard(provider.reviewCount.toString(), 'Jobs Done', Icons.task_alt_rounded, AppColors.pastelGreen, const Color(0xFF1A6B3C), isDark),
        const SizedBox(width: 10),
        _buildStatCard('${provider.experience} yr', 'Experience', Icons.workspace_premium_rounded, AppColors.pastelBlue, AppColors.deepTeal, isDark),
      ],
    );
  }

  Widget _buildStatCard(String value, String label, IconData icon, Color bg, Color accent, bool isDark) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF161616) : bg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isDark ? Colors.white.withOpacity(0.06) : Colors.transparent),
        ),
        child: Column(
          children: [
            Icon(icon, color: isDark ? Colors.white60 : accent, size: 22),
            const SizedBox(height: 8),
            Text(value, style: GoogleFonts.nunito(fontWeight: FontWeight.w900, fontSize: 18, color: isDark ? Colors.white : accent)),
            Text(label, style: GoogleFonts.nunito(color: isDark ? Colors.white38 : accent.withOpacity(0.7), fontSize: 10, fontWeight: FontWeight.w800)),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, bool isDark, {String? action, VoidCallback? onAction}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.w900, color: isDark ? Colors.white : AppColors.charcoalDark)),
        if (action != null)
          GestureDetector(
            onTap: onAction,
            child: Text(action, style: GoogleFonts.nunito(color: AppColors.deepTeal, fontWeight: FontWeight.w800, fontSize: 13)),
          ),
      ],
    );
  }

  Widget _buildServiceItem(String name, IconData icon, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF161616) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: isDark ? Colors.white.withOpacity(0.06) : Colors.black.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: AppColors.deepTeal.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: AppColors.deepTeal, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(name, style: GoogleFonts.nunito(fontWeight: FontWeight.w700, fontSize: 13, color: isDark ? Colors.white : AppColors.charcoalDark)),
          ),
          const Icon(Icons.check_circle_rounded, color: AppColors.deepTeal, size: 18),
        ],
      ),
    );
  }

  Widget _buildPortfolioGrid(bool isDark) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _portfolioImages.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1.0,
      ),
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () => _viewPhoto(_portfolioImages[index]),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Image.network(
              _portfolioImages[index],
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                color: isDark ? const Color(0xFF161616) : AppColors.surfaceLightGray,
                child: Icon(Icons.image_outlined, color: AppColors.mutedGray, size: 32),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSwitchButton(bool isDark) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: OutlinedButton.icon(
        onPressed: () async {
          await StorageService.saveData('activeRole', 'Customer');
          if (context.mounted) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const SplashScreen()),
              (route) => false,
            );
          }
        },
        icon: const Icon(Icons.swap_horiz_rounded, size: 18),
        label: Text('Switch to Client Mode', style: GoogleFonts.nunito(fontWeight: FontWeight.w800, fontSize: 13)),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
          foregroundColor: Colors.red.shade400,
          side: BorderSide(color: Colors.red.shade200),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        ),
      ),
    );
  }

  Widget _buildReviewsSection(bool isDark, String providerId) {
    return FutureBuilder<List<Review>>(
      future: ReviewService.getProviderReviews(providerId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final reviews = snapshot.data ?? [];
        if (reviews.isEmpty) {
          return Text(
            "No reviews yet. Be the first to leave one after your booking!",
            style: GoogleFonts.nunito(
              color: isDark ? Colors.white60 : AppColors.mutedGray,
              fontSize: 13,
            ),
          );
        }
        
        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: reviews.length,
          itemBuilder: (context, index) {
            final review = reviews[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF161616) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: isDark ? Colors.white.withOpacity(0.06) : Colors.black.withOpacity(0.05)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        review.clientName,
                        style: GoogleFonts.nunito(
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                          color: isDark ? Colors.white : AppColors.textDark,
                        ),
                      ),
                      Row(
                        children: [
                          Icon(Icons.star_rounded, color: AppColors.pastelYellow, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            review.rating.toString(),
                            style: GoogleFonts.nunito(
                              fontWeight: FontWeight.w800,
                              fontSize: 13,
                              color: isDark ? Colors.white : AppColors.textDark,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (review.comment.isNotEmpty)
                    Text(
                      review.comment,
                      style: GoogleFonts.nunito(
                        color: isDark ? Colors.white70 : AppColors.mutedGray,
                        fontSize: 13,
                      ),
                    ),
                  const SizedBox(height: 8),
                  Text(
                    DateFormat('MMM d, yyyy').format(review.timestamp),
                    style: GoogleFonts.nunito(
                      fontSize: 11,
                      color: isDark ? Colors.white38 : AppColors.mutedGray.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
