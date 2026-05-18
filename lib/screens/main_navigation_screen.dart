import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import 'home_dashboard_screen.dart';
import 'dashboardScreen2.dart';
import 'bookings_screen.dart';
import 'calendar_screen.dart';
import 'inbox_screen.dart';
import 'profile_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  final int initialIndex;
  const MainNavigationScreen({super.key, this.initialIndex = 0});

  static _MainNavigationScreenState? of(BuildContext context) {
    return context.findAncestorStateOfType<_MainNavigationScreenState>();
  }

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  late int _currentIndex;
  bool _useAiDashboard = true; // Toggle for demo

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  void setIndex(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void toggleDashboard() {
    setState(() {
      _useAiDashboard = !_useAiDashboard;
    });
  }

  List<Widget> get _pages => [
    _useAiDashboard ? const AiServiceSearchScreen() : const HomeDashboardScreen(),
    const BookingsScreen(),
    const CalendarScreen(),
    const InboxScreen(isProvider: false),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          // Main Content
          IndexedStack(
            index: _currentIndex,
            children: _pages,
          ),
          
          // Switch Dashboard Toggle (Floating for Demo)
          if (_currentIndex == 0)
            Positioned(
              top: 100,
              right: 0,
              child: GestureDetector(
                onTap: toggleDashboard,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      bottomLeft: Radius.circular(20),
                    ),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.swap_horiz, color: Colors.white, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        _useAiDashboard ? "Classic" : "AI View",
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // Floating Bottom Navigation Bar
          Positioned(
            bottom: 24,
            left: 24,
            right: 24,
            child: Container(
              height: 70,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF161616).withOpacity(0.9) : Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(35),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDark ? 0.4 : 0.05),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildNavItem(0, Icons.home_filled, Icons.home_outlined),
                  _buildNavItem(1, Icons.description, Icons.description_outlined),
                  _buildNavItem(2, Icons.calendar_month, Icons.calendar_month_outlined),
                  _buildNavItem(3, Icons.chat_bubble, Icons.chat_bubble_outline),
                  _buildNavItem(4, Icons.person, Icons.person_outline),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, IconData activeIcon, IconData inactiveIcon) {
    bool isActive = _currentIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Icon(
          isActive ? activeIcon : inactiveIcon,
          color: isActive ? Colors.white : AppColors.textSecondaryLight,
          size: 26,
        ),
      ),
    );
  }
}
