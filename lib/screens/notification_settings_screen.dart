import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme/app_colors.dart';
import '../core/data/mock_data.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final settingsKeys = MockData.notificationSettings.keys.toList();

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.offWhite,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF161616) : Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  if (!isDark)
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                ],
              ),
              child: Icon(Icons.arrow_back_ios_new_rounded, color: isDark ? Colors.white : AppColors.charcoalDark, size: 16),
            ),
          ),
        ),
        title: Text(
          'Notifications',
          style: GoogleFonts.nunito(
            color: isDark ? Colors.white : AppColors.charcoalDark,
            fontWeight: FontWeight.w900,
            fontSize: 20,
          ),
        ),
      ),
      body: SafeArea(
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF111111) : Colors.white,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(40),
              topRight: Radius.circular(40),
            ),
          ),
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            physics: const BouncingScrollPhysics(),
            itemCount: settingsKeys.length,
            itemBuilder: (context, index) {
              final key = settingsKeys[index];
              final value = MockData.notificationSettings[key]!;

              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1A1A1A) : AppColors.offWhite,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.04),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            key,
                            style: GoogleFonts.nunito(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: isDark ? Colors.white : AppColors.charcoalDark,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _getSubtitle(key),
                            style: GoogleFonts.nunito(
                              fontSize: 12,
                              color: isDark ? Colors.white60 : AppColors.mutedGray,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: value,
                      onChanged: (v) {
                        setState(() {
                          MockData.notificationSettings[key] = v;
                          MockData.saveSettings();
                        });
                      },
                      activeColor: AppColors.deepTeal,
                      activeTrackColor: AppColors.deepTeal.withOpacity(0.2),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  String _getSubtitle(String key) {
    switch (key) {
      case 'General Notification': return 'Basic app alerts and notification messages';
      case 'App Updates': return 'News about new features and major version rollouts';
      case 'Service Reminders': return 'Reminders for your upcoming scheduled bookings';
      case 'Payment Request': return 'Alerts for invoice completion and dispatch payments';
      case 'Discount Available': return 'Exclusive coupons and localized service deals';
      case 'Promotions': return 'Marketing offers, newsletters, and partner promos';
      default: return 'Configure your notification alerts';
    }
  }
}
