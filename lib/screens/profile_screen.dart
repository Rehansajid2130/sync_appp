import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_typography.dart';
import '../core/services/storage_service.dart';
import '../core/data/mock_data.dart';
import 'provider/provider_navigation_screen.dart';
import 'provider/provider_setup_screen.dart';
import 'edit_profile_screen.dart';
import 'address_selection_screen.dart';
import 'notification_settings_screen.dart';
import 'security_settings_screen.dart';
import 'main_navigation_screen.dart';
import 'review_screen.dart';
import '../main.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 20),
              _buildHeader(),
              const SizedBox(height: 32),
              _buildUserInfo(),
              const SizedBox(height: 32),
              _buildBookingStatsCard(isDark),
              const SizedBox(height: 32),
              _buildGeneralSection(isDark),
              const SizedBox(height: 120), // Bottom nav padding
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Spacer(),
        Text(
          'Profile',
          style: AppTypography.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
            fontSize: 22,
          ),
        ),
        const Spacer(),
      ],
    );
  }

  Widget _buildUserInfo() {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const EditProfileScreen())),
      child: Row(
        children: [
          Stack(
            children: [
              const CircleAvatar(
                radius: 44,
                backgroundColor: Color(0xFFC8E6C9),
                child: Icon(Icons.person, size: 48, color: Colors.white),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.camera_alt_outlined, color: Colors.white, size: 16),
                ),
              ),
            ],
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Fajar Kun',
                  style: AppTypography.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    fontSize: 24,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'fajar123@gmail.com',
                  style: AppTypography.textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondaryLight,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
              color: Color(0xFF1A1A2E),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.settings_outlined, color: Colors.white, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingStatsCard(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'My Booking Service',
          style: AppTypography.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
            color: isDark ? Colors.white : AppColors.textPrimaryLight,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF66BB6A), Color(0xFFA5D6A7)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF66BB6A).withOpacity(0.3),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStatItem(Icons.calendar_today_outlined, 'Upcoming', '1', isDark: isDark, onTap: () {
                MainNavigationScreen.of(context)?.setIndex(1);
              }),
              _buildStatItem(Icons.local_shipping_outlined, 'Completed', '3', isDark: isDark, onTap: () {
                MainNavigationScreen.of(context)?.setIndex(1);
              }),
              _buildStatItem(Icons.star_outline, 'Give a Rating', null, isDark: isDark, onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ReviewScreen(
                      providerName: 'James Anderson',
                      serviceCategory: 'Cleaning',
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem(IconData icon, String label, String? badge, {required bool isDark, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Stack(
            children: [
              Icon(icon, color: Colors.white, size: 30),
              if (badge != null)
                Positioned(
                  right: -4,
                  top: -4,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      badge,
                      style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildGeneralSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'General',
          style: AppTypography.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
            color: isDark ? Colors.white : AppColors.textPrimaryLight,
          ),
        ),
        const SizedBox(height: 16),
        _buildMenuItem(Icons.location_on_outlined, 'Add Address', isDark: isDark, onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const AddressSelectionScreen()));
        }),
        _buildMenuItem(Icons.notifications_none_outlined, 'Notification', isDark: isDark, onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const NotificationSettingsScreen()));
        }),
        _buildMenuItem(Icons.security_outlined, 'Security', isDark: isDark, onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const SecuritySettingsScreen()));
        }),
        _buildMenuItem(Icons.dark_mode_outlined, isDark ? 'Light Theme' : 'Dark Theme', isDark: isDark, trailing: Switch(
          value: isDark,
          onChanged: (v) {
            themeNotifier.value = v ? ThemeMode.dark : ThemeMode.light;
            StorageService.setDarkMode(v);
          },
          activeColor: AppColors.primary,
        )),
        _buildMenuItem(Icons.cached, 'Switch to Provider', isDark: isDark, onTap: () {
          // Check if the current user is registered as a provider
          final bool isRegistered = MockData.isUserRegisteredAsProvider;
          
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => isRegistered 
                  ? const ProviderNavigationScreen() 
                  : const ProviderSetupScreen(),
            ),
          );
        }),
        _buildMenuItem(Icons.info_outline, 'Contact Us', isDark: isDark),
        _buildMenuItem(Icons.logout, 'Logout', isDark: isDark, isLogout: true, onTap: _showLogoutDialog),
      ],
    );
  }

  Widget _buildMenuItem(IconData icon, String title, {required bool isDark, Widget? trailing, bool isLogout = false, VoidCallback? onTap}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.2 : 0.02),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF262626) : const Color(0xFFF1F4F8),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: isLogout ? Colors.red : (isDark ? Colors.white : const Color(0xFF1A1A2E)), size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: AppTypography.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: isLogout ? Colors.red : (isDark ? Colors.white : AppColors.textPrimaryLight),
                  ),
                ),
              ),
              trailing ?? Icon(Icons.chevron_right, color: isDark ? Colors.white54 : AppColors.textMutedLight),
            ],
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Center(
          child: Text(
            'Logout?',
            style: TextStyle(color: Colors.red, fontWeight: FontWeight.w800),
          ),
        ),
        content: const Text(
          'Are you sure to want logout?',
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
        actions: [
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  ),
                  child: const Text('Cancel', style: TextStyle(color: Colors.black)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    // Actual logout logic here
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  ),
                  child: const Text('Logout', style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
