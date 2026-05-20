import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../edit_profile_screen.dart';
import '../address_selection_screen.dart';
import '../notification_settings_screen.dart';
import '../security_settings_screen.dart';
import '../provider/provider_navigation_screen.dart';
import '../provider/provider_setup_screen.dart';
import 'new_auth_screen.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/storage_service.dart';
import '../../core/data/mock_data.dart';
import '../../main.dart';

class NewProfileSettingsScreen extends StatefulWidget {
  final VoidCallback? onBackTap;
  
  const NewProfileSettingsScreen({super.key, this.onBackTap});

  @override
  State<NewProfileSettingsScreen> createState() => _NewProfileSettingsScreenState();
}

class _NewProfileSettingsScreenState extends State<NewProfileSettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentUserName = AuthService.currentUser?.name ?? MockData.currentUserName;
    final currentUserEmail = AuthService.currentUser?.email ?? MockData.currentUserEmail;

    final List<Map<String, dynamic>> _menuOptions = [
      {
        "title": "Manage Profile",
        "icon": Icons.person_outline_rounded,
        "subtitle": "Edit personal details, bio, and credentials",
        "type": "navigation",
        "destination": const EditProfileScreen()
      },
      {
        "title": "Add Address",
        "icon": Icons.location_on_outlined,
        "subtitle": "Manage service and home addresses",
        "type": "navigation",
        "destination": const AddressSelectionScreen()
      },
      {
        "title": "Notification Settings",
        "icon": Icons.notifications_none_rounded,
        "subtitle": "Control email, SMS, and push notification alerts",
        "type": "navigation",
        "destination": const NotificationSettingsScreen()
      },
      {
        "title": "Security Settings",
        "icon": Icons.shield_outlined,
        "subtitle": "Manage two-factor auth and credentials security",
        "type": "navigation",
        "destination": const SecuritySettingsScreen()
      },
      {
        "title": isDark ? "Light Theme" : "Dark Theme",
        "icon": Icons.dark_mode_outlined,
        "subtitle": "Switch between dark and light appearance modes",
        "type": "theme_toggle"
      },
      {
        "title": "Switch to Provider",
        "icon": Icons.cached_rounded,
        "subtitle": "Access provider dashboard and manage listings",
        "type": "provider_switch"
      },
      {
        "title": "Contact Us",
        "icon": Icons.info_outline_rounded,
        "subtitle": "Get support or send feedback to our dev team",
        "type": "contact_us"
      },
      {
        "title": "Logout",
        "icon": Icons.logout_rounded,
        "subtitle": "Securely sign out of your account",
        "type": "logout"
      },
    ];

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF090909) : Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 1. Custom Transparent Navigation Bar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: widget.onBackTap ?? () => Navigator.maybePop(context),
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
                        border: Border.all(
                          color: isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.04),
                        ),
                      ),
                      child: Icon(
                        Icons.arrow_back_rounded,
                        color: isDark ? Colors.white : AppColors.textDark,
                        size: 20,
                      ),
                    ),
                  ),
                  Text(
                    "Settings",
                    style: GoogleFonts.nunito(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: isDark ? Colors.white : AppColors.textDark,
                    ),
                  ),
                  const SizedBox(width: 40), // Balanced spacing
                ],
              ),
              const SizedBox(height: 24),

              // 2. User Identity Hero Block
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const EditProfileScreen()),
                  ).then((_) => setState(() {}));
                },
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4), // Ring thickness spacing
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [AppColors.deepTeal, AppColors.pastelBlue],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Stack(
                        children: [
                          const CircleAvatar(
                            radius: 46,
                            backgroundColor: Color(0xFFC8E6C9),
                            backgroundImage: NetworkImage(
                              "https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&q=80&w=200",
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: AppColors.deepTeal,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.camera_alt_outlined, color: Colors.white, size: 14),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      currentUserName,
                      style: GoogleFonts.nunito(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: isDark ? Colors.white : AppColors.textDark,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      currentUserEmail,
                      style: GoogleFonts.nunito(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textMutedGray,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // 3. Promo / Action Hero Card ("Invite friends")
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF8A70FF), Color(0xFFC0AFFF)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF8A70FF).withOpacity(0.24),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                clipBehavior: Clip.antiAlias,
                child: Stack(
                  children: [
                    // Graphic Background Accents
                    Positioned(
                      right: -30,
                      top: -30,
                      child: CircleAvatar(
                        radius: 80,
                        backgroundColor: Colors.white.withOpacity(0.08),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(
                                  Icons.people_outline_rounded,
                                  color: Colors.white,
                                  size: 28,
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Invite friends!",
                                        style: GoogleFonts.nunito(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w800,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        "Share premium workflows & earn scheduling credentials.",
                                        style: GoogleFonts.nunito(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white.withOpacity(0.85),
                                          height: 1.3,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                          // Custom graphic illustration on the right
                          Container(
                            height: 52,
                            width: 52,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                // Heart overlay layers
                                Positioned(
                                  top: 10,
                                  child: Container(
                                    width: 32,
                                    height: 14,
                                    decoration: BoxDecoration(
                                      color: AppColors.deepTeal.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                ),
                                const Icon(
                                  Icons.favorite_rounded,
                                  color: AppColors.deepTeal,
                                  size: 22,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // 4. Settings List Grid Menu (The Option Stack)
              Container(
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF161616) : Colors.white,
                  borderRadius: BorderRadius.circular(28.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(isDark ? 0.2 : 0.03),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                  border: Border.all(
                    color: isDark ? Colors.white.withOpacity(0.06) : Colors.black.withOpacity(0.04),
                  ),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _menuOptions.length,
                  separatorBuilder: (context, index) {
                    return Divider(
                      color: isDark ? Colors.white10 : Colors.black.withOpacity(0.04),
                      indent: 48,
                      endIndent: 12,
                      height: 24,
                    );
                  },
                  itemBuilder: (context, index) {
                    final item = _menuOptions[index];
                    final bool isLast = index == _menuOptions.length - 1;
                    final bool isThemeOption = item['type'] == 'theme_toggle';

                    return ListTile(
                      dense: true,
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.white.withOpacity(0.04) : AppColors.surfaceLightGray,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          item['icon'],
                          color: isLast 
                              ? Colors.red 
                              : (isDark ? Colors.white70 : AppColors.textDark),
                          size: 20,
                        ),
                      ),
                      title: Text(
                        item['title'],
                        style: GoogleFonts.nunito(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: isLast
                              ? Colors.red
                              : (isDark ? Colors.white : AppColors.textDark),
                        ),
                      ),
                      subtitle: Text(
                        item['subtitle'],
                        style: GoogleFonts.nunito(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textMutedGray,
                        ),
                      ),
                      trailing: isThemeOption
                          ? Switch(
                              value: isDark,
                              onChanged: (v) {
                                setState(() {
                                  themeNotifier.value = v ? ThemeMode.dark : ThemeMode.light;
                                  StorageService.setDarkMode(v);
                                });
                              },
                              activeColor: AppColors.deepTeal,
                            )
                          : GestureDetector(
                              onTap: () => _handleItemAction(context, item),
                              child: Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isDark ? Colors.white.withOpacity(0.04) : AppColors.surfaceLightGray,
                                ),
                                child: Icon(
                                  Icons.arrow_forward_rounded,
                                  size: 14,
                                  color: isLast
                                      ? Colors.red
                                      : (isDark ? Colors.white70 : AppColors.textDark),
                                ),
                              ),
                            ),
                      onTap: isThemeOption ? null : () => _handleItemAction(context, item),
                    );
                  },
                ),
              ),
              const SizedBox(height: 80), // safe bar offset
            ],
          ),
        ),
      ),
    );
  }

  void _handleItemAction(BuildContext context, Map<String, dynamic> item) {
    final String type = item['type'];

    if (type == 'navigation') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => item['destination']),
      ).then((_) => setState(() {}));
    } else if (type == 'provider_switch') {
      StorageService.saveData('activeRole', 'Provider');
      // Check if the provider storefront actually exists in the database
      final bool isRegistered = MockData.providers.any((p) => p.id == AuthService.currentUser?.uid);
      
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => isRegistered 
              ? const ProviderNavigationScreen() 
              : const ProviderSetupScreen(),
        ),
        (route) => false,
      );
    } else if (type == 'contact_us') {
      _showContactUsDialog(context);
    } else if (type == 'logout') {
      _showLogoutDialog(context);
    }
  }

  void _showContactUsDialog(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF161616) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Center(
          child: Text(
            'Contact Support',
            style: GoogleFonts.nunito(
              fontWeight: FontWeight.w900,
              color: isDark ? Colors.white : AppColors.textDark,
            ),
          ),
        ),
        content: Text(
          'Need premium orchestration support? Send an email to support@premium-sync.io or call our priority assistance line.',
          textAlign: TextAlign.center,
          style: GoogleFonts.nunito(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: isDark ? Colors.white70 : AppColors.textSecondaryLight,
          ),
        ),
        actions: [
          Center(
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.deepTeal,
                foregroundColor: Colors.white,
                shape: const StadiumBorder(),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: Text(
                'Close',
                style: GoogleFonts.nunito(fontWeight: FontWeight.w800, color: Colors.white),
              ),
            ),
          )
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF161616) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Center(
          child: Text(
            'Confirm Logout',
            style: GoogleFonts.nunito(
              color: Colors.red,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        content: Text(
          'Are you sure you want to securely sign out of your premium account?',
          textAlign: TextAlign.center,
          style: GoogleFonts.nunito(
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white70 : AppColors.textDark,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: isDark ? Colors.white30 : AppColors.mutedGray.withOpacity(0.4)),
                      shape: const StadiumBorder(),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: Text(
                      'Cancel',
                      style: GoogleFonts.nunito(
                        fontWeight: FontWeight.w800,
                        color: isDark ? Colors.white70 : AppColors.textDark,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      Navigator.pop(context); // close dialog
                      await AuthService.signOut();
                      if (context.mounted) {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (_) => const NewAuthScreen()),
                          (route) => false,
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      shape: const StadiumBorder(),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: Text(
                      'Logout',
                      style: GoogleFonts.nunito(
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
