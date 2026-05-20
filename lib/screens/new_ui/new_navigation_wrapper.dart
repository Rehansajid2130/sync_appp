import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../core/services/auth_service.dart';
import '../../core/data/mock_data.dart';
import '../../widgets/new_ui/curved_bottom_bar.dart';
import '../../ai/screens/ai_chat_screen.dart';
import 'new_home_dashboard.dart';
import 'new_calendar_screen.dart';
import 'new_chat_screen.dart';
import 'new_profile_settings_screen.dart';

class NewNavigationWrapper extends StatefulWidget {
  const NewNavigationWrapper({super.key});

  @override
  State<NewNavigationWrapper> createState() => _NewNavigationWrapperState();
}

class _NewNavigationWrapperState extends State<NewNavigationWrapper> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    setState(() {}); // Refresh state
  }

  List<Widget> get _screens => [
    const NewHomeDashboardScreen(),
    const NewCalendarScreen(),
    NewChatScreen(onBackTap: () => setState(() => _currentIndex = 0)),
    NewProfileSettingsScreen(onBackTap: () => setState(() => _currentIndex = 0)),
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
    final isProvider = AuthService.currentUser?.isProvider ?? MockData.isUserRegisteredAsProvider;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF090909) : Colors.white,
      body: Stack(
        children: [
          // Screen views
          Positioned.fill(
            child: IndexedStack(
              index: _currentIndex,
              children: _screens,
            ),
          ),

          // Curved Bottom Navigation Bar
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: CurvedBottomBar(
              currentIndex: _currentIndex,
              onTap: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              onCenterTap: isProvider ? () {} : _triggerCentralAction,
            ),
          ),
        ],
      ),
    );
  }
}

// Reusable static placeholder views for showcase
class DummyMessagesView extends StatelessWidget {
  const DummyMessagesView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.forum_outlined,
            size: 60,
            color: AppColors.deepTeal,
          ),
          const SizedBox(height: 16),
          Text(
            "Negotiations Inbox",
            style: GoogleFonts.nunito(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: isDark ? Colors.white : AppColors.textDark,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "Real-time chats and schedule resolutions",
            style: GoogleFonts.nunito(
              fontSize: 14,
              color: AppColors.textMutedGray,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class DummyProfileView extends StatelessWidget {
  const DummyProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.person_outline_rounded,
            size: 60,
            color: AppColors.deepTeal,
          ),
          const SizedBox(height: 16),
          Text(
            "Professional Accounts",
            style: GoogleFonts.nunito(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: isDark ? Colors.white : AppColors.textDark,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "Configure role settings, pricing and coverage radius",
            style: GoogleFonts.nunito(
              fontSize: 14,
              color: AppColors.textMutedGray,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
