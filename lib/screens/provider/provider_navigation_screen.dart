import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../ai/screens/ai_chat_screen.dart';
import 'provider_dashboard_screen.dart';
import '../new_ui/new_calendar_screen.dart';
import '../new_ui/new_chat_screen.dart';
import 'provider_storefront_screen.dart';
import '../../widgets/new_ui/curved_bottom_bar.dart';

class ProviderNavigationScreen extends StatefulWidget {
  const ProviderNavigationScreen({super.key});

  @override
  State<ProviderNavigationScreen> createState() => _ProviderNavigationScreenState();
}

class _ProviderNavigationScreenState extends State<ProviderNavigationScreen> {
  int _currentIndex = 0;

  // Provider tabs: Dashboard | Schedule | [AI center] | Chat | Profile
  List<Widget> get _pages => [
    const ProviderDashboardScreen(),
    const NewCalendarScreen(isProvider: true),
    NewChatScreen(onBackTap: () => setState(() => _currentIndex = 0)),
    const ProviderStorefrontScreen(),
  ];

  void _triggerCentralAction() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AiChatScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF090909) : Colors.white,
      body: Stack(
        children: [
          // Page views
          Positioned.fill(
            child: IndexedStack(
              index: _currentIndex,
              children: _pages,
            ),
          ),

          // Identical CurvedBottomBar as customer side
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: CurvedBottomBar(
              currentIndex: _currentIndex,
              onTap: (i) => setState(() => _currentIndex = i),
              onCenterTap: _triggerCentralAction,
            ),
          ),
        ],
      ),
    );
  }
}
