import 'package:flutter/material.dart';
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
      backgroundColor: isDark ? const Color(0xFF090909) : const Color(0xFFE0F2F1),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF161616) : Colors.white, 
                        shape: BoxShape.circle,
                        boxShadow: [
                          if (!isDark) BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))
                        ]
                      ),
                      child: Icon(Icons.arrow_back, size: 20, color: isDark ? Colors.white : Colors.black),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        'Notifications',
                        style: TextStyle(
                          fontSize: 20, 
                          fontWeight: FontWeight.w800, 
                          color: isDark ? Colors.white : Colors.black,
                          letterSpacing: -0.5
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 40),
                ],
              ),
            ),
            Expanded(
              child: Container(
                width: double.infinity,
                margin: const EdgeInsets.only(top: 20),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF161616) : Colors.white,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(40),
                    topRight: Radius.circular(40),
                  ),
                  boxShadow: [
                    if (!isDark) BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, -5))
                  ]
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(topLeft: Radius.circular(40), topRight: Radius.circular(40)),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(32),
                    itemCount: settingsKeys.length,
                    itemBuilder: (context, index) {
                      final key = settingsKeys[index];
                      final value = MockData.notificationSettings[key]!;
                      
                      return Container(
                        margin: const EdgeInsets.only(bottom: 20),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF262626) : Colors.grey[50],
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.02)),
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
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: isDark ? Colors.white : AppColors.textPrimaryLight,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _getSubtitle(key),
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: isDark ? Colors.white38 : Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Switch.adaptive(
                              value: value,
                              onChanged: (v) {
                                setState(() {
                                  MockData.notificationSettings[key] = v;
                                  MockData.saveSettings();
                                });
                              },
                              activeColor: AppColors.primary,
                              activeTrackColor: AppColors.primary.withOpacity(0.3),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getSubtitle(String key) {
    switch (key) {
      case 'General Notification': return 'Basic app alerts and messages';
      case 'App Updates': return 'News about new features and versions';
      case 'Service Reminders': return 'Reminders for your upcoming bookings';
      case 'Payment Request': return 'Alerts for invoices and payments';
      case 'Discount Available': return 'Exclusive deals and coupons';
      case 'Promotions': return 'Marketing and special offers';
      default: return 'Notification preference';
    }
  }
}
