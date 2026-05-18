import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_typography.dart';
import '../core/data/mock_data.dart';
import 'chat_detail_screen.dart';

class InboxScreen extends StatefulWidget {
  final bool isProvider;
  const InboxScreen({super.key, this.isProvider = false});

  @override
  State<InboxScreen> createState() => _InboxScreenState();
}

class _InboxScreenState extends State<InboxScreen> {
  String _activeTab = 'Chats';

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildHeader(isDark),
            const SizedBox(height: 20),
            _buildTabBar(isDark),
            const SizedBox(height: 20),
            Expanded(
              child: _activeTab == 'Chats' ? _buildChatsList(isDark) : _buildCallsList(isDark),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
      child: Row(
        children: [
          Container(
            width: 40, height: 40,
            decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
            child: const Icon(Icons.hive_outlined, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 12),
          Text(
            'Inbox',
            style: AppTypography.textTheme.displayLarge?.copyWith(
              color: isDark ? Colors.white : AppColors.textPrimaryLight,
              fontSize: 24,
              fontWeight: FontWeight.w800,
            ),
          ),
          const Spacer(),
          _buildCircleButton(Icons.search, isDark),
        ],
      ),
    );
  }

  Widget _buildCircleButton(IconData icon, bool isDark) {
    return Container(
      width: 40, height: 40,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF161616) : Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: isDark ? Colors.white10 : Colors.black.withOpacity(0.05)),
      ),
      child: Icon(icon, color: isDark ? Colors.white : AppColors.textPrimaryLight, size: 20),
    );
  }

  Widget _buildTabBar(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          _buildTab('Chats', isDark),
          const SizedBox(width: 32),
          _buildTab('Calls', isDark),
        ],
      ),
    );
  }

  Widget _buildTab(String title, bool isDark) {
    final isActive = _activeTab == title;
    return GestureDetector(
      onTap: () => setState(() => _activeTab = title),
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(
              color: isActive ? AppColors.primary : (isDark ? Colors.white54 : AppColors.textSecondaryLight),
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          if (isActive)
            Container(
              width: 30, height: 3,
              decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(2)),
            ),
        ],
      ),
    );
  }

  Widget _buildChatsList(bool isDark) {
    // Only show chats for active/upcoming/pending bookings
    final chats = MockData.bookings.where((b) => b.status != 'Cancelled' && b.status != 'Declined').toList();
    
    if (chats.isEmpty) {
      return Center(child: Text('No active chats', style: TextStyle(color: isDark ? Colors.white38 : Colors.grey)));
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 120),
      itemCount: chats.length,
      separatorBuilder: (_, __) => Divider(color: isDark ? Colors.white10 : Colors.black.withOpacity(0.05)),
      itemBuilder: (context, index) => _buildChatTile(chats[index], isDark),
    );
  }

  Widget _buildChatTile(Booking booking, bool isDark) {
    final String name = widget.isProvider ? booking.clientName : booking.providerName;
    return ListTile(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ChatDetailScreen())),
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        radius: 28, 
        backgroundColor: AppColors.primary.withOpacity(0.1),
        child: Icon(booking.icon, color: AppColors.primary, size: 24),
      ),
      title: Text(name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
      subtitle: Text('Re: ${booking.serviceName} - ${booking.status}', maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: isDark ? Colors.white54 : Colors.grey)),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(booking.time, style: TextStyle(color: isDark ? Colors.white38 : Colors.grey, fontSize: 12)),
          const SizedBox(height: 4),
          if (booking.status == 'Pending')
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(color: Colors.orange.withOpacity(0.2), borderRadius: BorderRadius.circular(4)),
              child: const Text('NEW', style: TextStyle(color: Colors.orange, fontSize: 8, fontWeight: FontWeight.bold)),
            ),
        ],
      ),
    );
  }

  Widget _buildCallsList(bool isDark) {
    return Center(child: Text('Call history is empty', style: TextStyle(color: isDark ? Colors.white38 : Colors.grey)));
  }
}
