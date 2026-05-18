import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_typography.dart';
import 'notifications_screen.dart';
import 'address_setup_screen.dart';
import 'search_results_screen.dart';

class HomeDashboardScreen extends StatelessWidget {
  const HomeDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(left: 24, right: 24, top: 24, bottom: 120),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context, isDark),
              const SizedBox(height: 24),
              _buildPromoBanner(),
              const SizedBox(height: 24),
              _buildSectionTitle('Services', isDark, onSeeAll: () {}),
              const SizedBox(height: 16),
              _buildServicesGrid(isDark),
              const SizedBox(height: 24),
              _buildSectionTitle('Popular Service', isDark, onSeeAll: () {}),
              const SizedBox(height: 16),
              _buildPopularServicesList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark) {
    return Row(
      children: [
        const CircleAvatar(
          radius: 24,
          backgroundColor: AppColors.primaryLight,
          child: Icon(Icons.person, color: AppColors.primary),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hello Fajar Kun 👋',
                style: AppTypography.textTheme.bodyMedium?.copyWith(
                  color: isDark ? Colors.white70 : AppColors.textSecondaryLight,
                ),
              ),
              const SizedBox(height: 4),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AddressSetupScreen()),
                  );
                },
                child: Row(
                  children: [
                    Icon(Icons.location_on_outlined, size: 16, color: isDark ? Colors.white : AppColors.textPrimaryLight),
                    const SizedBox(width: 4),
                    Text(
                      'New York, US',
                      style: AppTypography.textTheme.titleMedium?.copyWith(
                        color: isDark ? Colors.white : AppColors.textPrimaryLight,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(Icons.keyboard_arrow_down, size: 16, color: isDark ? Colors.white : AppColors.textPrimaryLight),
                  ],
                ),
              ),
            ],
          ),
        ),
        _buildCircleAction(
          Icons.search,
          isDark,
          color: AppColors.primary,
          iconColor: Colors.white,
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SearchResultsScreen())),
        ),
        const SizedBox(width: 12),
        _buildCircleAction(
          Icons.notifications_outlined,
          isDark,
          hasBadge: true,
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const NotificationsScreen())),
        ),
      ],
    );
  }

  Widget _buildCircleAction(IconData icon, bool isDark, {Color? color, Color? iconColor, bool hasBadge = false, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: color ?? (isDark ? const Color(0xFF161616) : Colors.white),
          shape: BoxShape.circle,
          border: color == null ? Border.all(color: isDark ? Colors.white10 : AppColors.textMutedLight.withOpacity(0.2)) : null,
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Icon(icon, color: iconColor ?? (isDark ? Colors.white : AppColors.textPrimaryLight)),
            if (hasBadge)
              Positioned(
                top: 14,
                right: 14,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Colors.redAccent,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPromoBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Up to 20% Off on\nCleaning Services',
            style: AppTypography.textTheme.displayLarge?.copyWith(
              color: Colors.white,
              fontSize: 22,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF161616), // Matching midnight theme
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Text(
                  'Booking Now',
                  style: AppTypography.textTheme.labelLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  color: Color(0xFF161616),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_outward, color: Colors.white, size: 20),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, bool isDark, {required VoidCallback onSeeAll}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: AppTypography.textTheme.titleLarge?.copyWith(
            color: isDark ? Colors.white : AppColors.textPrimaryLight,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        GestureDetector(
          onTap: onSeeAll,
          child: Row(
            children: [
              Text(
                'See All',
                style: AppTypography.textTheme.bodyMedium?.copyWith(
                  color: isDark ? Colors.white70 : AppColors.textPrimaryLight,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 4),
              Icon(Icons.arrow_forward, size: 16, color: isDark ? Colors.white70 : AppColors.textPrimaryLight),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildServicesGrid(bool isDark) {
    final List<Map<String, dynamic>> services = [
      {'name': 'Cleaning', 'icon': Icons.cleaning_services_outlined},
      {'name': 'Repairing', 'icon': Icons.handyman_outlined},
      {'name': 'Painting', 'icon': Icons.format_paint_outlined},
      {'name': 'Laundry', 'icon': Icons.local_laundry_service_outlined},
      {'name': 'Appliance', 'icon': Icons.build_outlined},
      {'name': 'Plumbing', 'icon': Icons.plumbing_outlined},
      {'name': 'Shifting', 'icon': Icons.local_shipping_outlined},
      {'name': 'More', 'icon': Icons.grid_view_outlined},
    ];

    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 24,
        crossAxisSpacing: 16,
        childAspectRatio: 0.75,
      ),
      itemCount: services.length,
      itemBuilder: (context, index) {
        return Column(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF161616) : Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: isDark ? Colors.white10 : AppColors.textMutedLight.withOpacity(0.1)),
                boxShadow: isDark ? null : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Icon(
                services[index]['icon'],
                color: AppColors.primary,
                size: 28,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              services[index]['name'],
              style: AppTypography.textTheme.labelMedium?.copyWith(
                color: isDark ? Colors.white70 : AppColors.textPrimaryLight,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        );
      },
    );
  }

  Widget _buildPopularServicesList() {
    return Column(
      children: [
        _buildServiceCard(
          title: 'House Cleaning',
          price: '\$20',
          rating: '5.0',
          color1: const Color(0xFF91CBAE),
          color2: const Color(0xFF67B790),
        ),
        const SizedBox(height: 16),
        _buildServiceCard(
          title: 'Washing Clothes',
          price: '\$15',
          rating: '4.9',
          color1: const Color(0xFF7DD5F5),
          color2: const Color(0xFF4CBEEB),
        ),
      ],
    );
  }

  Widget _buildServiceCard({
    required String title,
    required String price,
    required String rating,
    required Color color1,
    required Color color2,
  }) {
    return Container(
      width: double.infinity,
      height: 140,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color1, color2],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: AppTypography.textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 20),
                    const SizedBox(width: 4),
                    Text(
                      rating,
                      style: AppTypography.textTheme.bodyMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Text(
              price,
              style: AppTypography.textTheme.displayLarge?.copyWith(
                color: Colors.white,
                fontSize: 28,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
