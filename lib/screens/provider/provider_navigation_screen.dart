import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import 'provider_dashboard_screen.dart';
import '../calendar_screen.dart';
import '../bookings_screen.dart';
import '../inbox_screen.dart';
import 'provider_storefront_screen.dart';

class ProviderNavigationScreen extends StatefulWidget {
  const ProviderNavigationScreen({super.key});

  @override
  State<ProviderNavigationScreen> createState() => _ProviderNavigationScreenState();
}

class _ProviderNavigationScreenState extends State<ProviderNavigationScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const ProviderDashboardScreen(),
    const CalendarScreen(isProvider: true),
    const InboxScreen(isProvider: true),
    const BookingsScreen(isProvider: true),
    const ProviderStorefrontScreen(),
  ];

  final List<IconData> _activeIcons = [Icons.dashboard, Icons.calendar_month, Icons.chat_bubble, Icons.history, Icons.storefront];
  final List<IconData> _inactiveIcons = [Icons.dashboard_outlined, Icons.calendar_month_outlined, Icons.chat_bubble_outline, Icons.history_outlined, Icons.storefront_outlined];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      // We wrap the body in a Stack but give IndexedStack a defined size
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            children: [
              SizedBox(
                width: constraints.maxWidth,
                height: constraints.maxHeight,
                child: IndexedStack(
                  index: _currentIndex,
                  children: _pages,
                ),
              ),
              Positioned(
                bottom: 24, left: 24, right: 24,
                child: _buildFloatingBottomBar(isDark),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFloatingBottomBar(bool isDark) {
    return Container(
      height: 70,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A1A).withOpacity(0.95) : Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(35),
        border: Border.all(color: isDark ? Colors.white10 : Colors.black.withOpacity(0.05)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.4 : 0.08),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(_pages.length, (index) => 
          _buildNavItem(index, _activeIcons[index], _inactiveIcons[index]),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData activeIcon, IconData inactiveIcon) {
    bool isActive = _currentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Icon(
          isActive ? activeIcon : inactiveIcon,
          color: isActive ? Colors.white : Colors.grey,
          size: 24,
        ),
      ),
    );
  }
}
