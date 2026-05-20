import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class CurvedBottomBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final VoidCallback onCenterTap;

  const CurvedBottomBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.onCenterTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: 72,
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF161616) : Colors.white,
        borderRadius: BorderRadius.circular(32.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.4 : 0.06),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Home
          _buildNavItem(context, 0, Icons.home_rounded, Icons.home_outlined),
          
          // Calendar
          _buildNavItem(context, 1, Icons.calendar_month, Icons.calendar_month_outlined),
          
          // AI Chat (Center Action)
          GestureDetector(
            onTap: onCenterTap,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.deepTeal,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.deepTeal.withOpacity(0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 28),
            ),
          ),
          
          // Messages
          _buildNavItem(context, 2, Icons.forum_rounded, Icons.forum_outlined),
          
          // Profile
          _buildNavItem(context, 3, Icons.person_rounded, Icons.person_outline_rounded),
        ],
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, int index, IconData activeIcon, IconData inactiveIcon) {
    final bool isActive = currentIndex == index;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    final Color selectedIconColor = isDark ? Colors.white : AppColors.charcoalDark;
    final Color selectedBgColor = isDark ? Colors.white.withOpacity(0.12) : AppColors.charcoalDark.withOpacity(0.08);

    return GestureDetector(
      onTap: () => onTap(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isActive ? selectedBgColor : Colors.transparent,
          borderRadius: BorderRadius.circular(20.0),
        ),
        child: Icon(
          isActive ? activeIcon : inactiveIcon,
          color: isActive ? selectedIconColor : AppColors.mutedGray,
          size: 24,
        ),
      ),
    );
  }
}
