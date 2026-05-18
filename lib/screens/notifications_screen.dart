import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_typography.dart';
import '../core/data/mock_data.dart';
import 'package:intl/intl.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  int _selectedTabIndex = 0;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Filter notifications based on tab
    final filteredNotifications = _selectedTabIndex == 0 
        ? MockData.notifications 
        : MockData.notifications.where((n) => !n.isRead).toList();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leadingWidth: 80,
        leading: Padding(
          padding: const EdgeInsets.only(left: 24.0, top: 8, bottom: 8),
          child: Container(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF161616) : Colors.black.withOpacity(0.05),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : Colors.black, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
        title: Text(
          'Notifications',
          style: AppTypography.textTheme.titleLarge?.copyWith(
            color: isDark ? Colors.white : AppColors.textPrimaryLight,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 24.0, top: 8, bottom: 8),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF161616) : Colors.black.withOpacity(0.05),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: Icon(Icons.check_circle_outline, color: isDark ? Colors.white : Colors.black, size: 20),
                onPressed: () {
                  setState(() {
                    for (var n in MockData.notifications) {
                      n.isRead = true;
                    }
                    MockData.saveNotifications();
                  });
                },
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF161616) : Colors.black.withOpacity(0.03),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  children: [
                    _buildTab(0, 'All (${MockData.notifications.length})', isDark),
                    _buildTab(1, 'Unread (${MockData.notifications.where((n) => !n.isRead).length})', isDark),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: filteredNotifications.isEmpty 
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.notifications_off_outlined, size: 64, color: isDark ? Colors.white24 : Colors.black12),
                        const SizedBox(height: 16),
                        Text('No notifications yet', style: TextStyle(color: isDark ? Colors.white54 : Colors.grey)),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    itemCount: filteredNotifications.length,
                    itemBuilder: (context, index) {
                      final n = filteredNotifications[index];
                      return _buildNotificationTile(
                        notification: n,
                        isDark: isDark,
                      );
                    },
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTab(int index, String title, bool isDark) {
    final isSelected = _selectedTabIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTabIndex = index),
        child: Container(
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(24),
          ),
          alignment: Alignment.center,
          child: Text(
            title,
            style: AppTypography.textTheme.bodyMedium?.copyWith(
              color: isSelected ? Colors.white : (isDark ? Colors.white54 : AppColors.textSecondaryLight),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationTile({
    required AppNotification notification,
    required bool isDark,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: GestureDetector(
        onTap: () {
          setState(() {
            notification.isRead = true;
            MockData.saveNotifications();
          });
        },
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: isDark ? (notification.isRead ? const Color(0xFF161616) : Colors.green.withOpacity(0.1)) 
                             : (notification.isRead ? Colors.black.withOpacity(0.04) : Colors.green.withOpacity(0.05)),
                shape: BoxShape.circle,
              ),
              child: Icon(
                notification.icon, 
                color: notification.isRead ? (isDark ? Colors.white54 : AppColors.textSecondaryLight) : AppColors.primary, 
                size: 24
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        notification.title,
                        style: AppTypography.textTheme.bodyLarge?.copyWith(
                          color: isDark ? Colors.white : AppColors.textPrimaryLight,
                          fontWeight: notification.isRead ? FontWeight.w500 : FontWeight.w700,
                        ),
                      ),
                      Text(
                        DateFormat('hh:mm a').format(notification.timestamp),
                        style: TextStyle(fontSize: 10, color: isDark ? Colors.white38 : Colors.grey),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notification.subtitle,
                    style: AppTypography.textTheme.bodyMedium?.copyWith(
                      color: isDark ? Colors.white70 : AppColors.textSecondaryLight,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
