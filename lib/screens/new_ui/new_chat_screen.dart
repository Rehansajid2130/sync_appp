import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../core/services/auth_service.dart';
import '../../core/data/mock_data.dart';
import '../../core/data/mock_data.dart';
import '../../models/service_provider.dart';
import '../../core/routes/app_routes.dart';

class NewChatScreen extends StatefulWidget {
  final VoidCallback? onBackTap;

  const NewChatScreen({super.key, this.onBackTap});

  @override
  State<NewChatScreen> createState() => _NewChatScreenState();
}

class _NewChatScreenState extends State<NewChatScreen> {
  bool get hasConfirmedBookings {
    final name = AuthService.currentUser?.name ?? MockData.currentUserName;
    final isProvider = AuthService.currentUser?.isProvider ?? MockData.isUserRegisteredAsProvider;

    return MockData.bookings.any((b) {
      final isRelevant = isProvider ? b.providerName == name : b.clientName == name;
      return isRelevant && b.status == 'Upcoming';
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF090909) : AppColors.surfaceLightGray,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              height: 64,
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF121211) : Colors.white,
                border: Border(
                  bottom: BorderSide(
                    color: isDark ? Colors.white.withOpacity(0.06) : Colors.black.withOpacity(0.04),
                  ),
                ),
              ),
              child: Row(
                children: [
                  if (widget.onBackTap != null)
                    GestureDetector(
                      onTap: widget.onBackTap,
                      child: Container(
                        padding: const EdgeInsets.only(right: 12),
                        child: Icon(
                          Icons.arrow_back_rounded,
                          color: isDark ? Colors.white : AppColors.textDark,
                          size: 22,
                        ),
                      ),
                    ),
                  Text(
                    "Messages",
                    style: GoogleFonts.nunito(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: isDark ? Colors.white : AppColors.textDark,
                    ),
                  ),
                ],
              ),
            ),
            
            // Content
            Expanded(
              child: hasConfirmedBookings 
                  ? _buildInbox(isDark)
                  : _buildLockedState(isDark),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLockedState(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.deepTeal.withOpacity(0.05),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.lock_person_rounded,
                size: 64,
                color: AppColors.deepTeal,
              ),
            ),
            const SizedBox(height: 32),
            Text(
              "Conversations Locked",
              style: GoogleFonts.nunito(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: isDark ? Colors.white : AppColors.charcoalDark,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              "For your security, chat is only enabled once a booking has been confirmed and accepted. Browse services and book now to start chatting!",
              textAlign: TextAlign.center,
              style: GoogleFonts.nunito(
                fontSize: 15,
                color: isDark ? Colors.white70 : AppColors.mutedGray,
                height: 1.6,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInbox(bool isDark) {
    final name = AuthService.currentUser?.name ?? MockData.currentUserName;
    final isProviderUser = AuthService.currentUser?.isProvider ?? MockData.isUserRegisteredAsProvider;

    final activeBookings = MockData.bookings.where((b) {
      final isRelevant = isProviderUser ? b.providerName == name : b.clientName == name;
      return isRelevant && b.status == 'Upcoming';
    }).toList();
    
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: activeBookings.length,
      itemBuilder: (context, index) {
        final booking = activeBookings[index];
        final partnerName = isProviderUser ? booking.clientName : booking.providerName;
        
        return InkWell(
          onTap: () {
            Navigator.pushNamed(
              context,
              AppRoutes.chatDetail,
              arguments: {
                'providerName': partnerName,
                'providerImage': 'https://i.pravatar.cc/150?u=${booking.id}',
                'bookingId': booking.id,
              },
            );
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: isDark ? Colors.white.withOpacity(0.04) : Colors.black.withOpacity(0.02),
                ),
              ),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundImage: NetworkImage('https://i.pravatar.cc/150?u=${booking.id}'),
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
                            partnerName,
                            style: GoogleFonts.nunito(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: isDark ? Colors.white : AppColors.textDark,
                            ),
                          ),
                          Text(
                            "Active",
                            style: GoogleFonts.nunito(
                              fontSize: 12,
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        booking.serviceName,
                        style: GoogleFonts.nunito(
                          fontSize: 13,
                          color: isDark ? Colors.white60 : AppColors.mutedGray,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
