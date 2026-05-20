import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/data/mock_data.dart';

import '../../core/services/chat_service.dart';
import '../../core/services/auth_service.dart';
import '../../models/chat_message.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';

class NewChatDetailScreen extends StatefulWidget {
  final Map<String, dynamic>? chatArguments;
  final VoidCallback? onBackTap;

  const NewChatDetailScreen({super.key, this.chatArguments, this.onBackTap});

  @override
  State<NewChatDetailScreen> createState() => _NewChatDetailScreenState();
}

class _NewChatDetailScreenState extends State<NewChatDetailScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  late String _providerName;
  late String _providerImage;
  late String _bookingId;
  String get _currentUserId => AuthService.currentUser?.uid ?? 'guest';

  @override
  void initState() {
    super.initState();
    _providerName = "Provider";
    _providerImage = "https://i.pravatar.cc/150";
    _bookingId = "";
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = widget.chatArguments ?? ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null) {
      setState(() {
        if (args['providerName'] != null) _providerName = args['providerName'];
        if (args['providerImage'] != null) _providerImage = args['providerImage'];
        if (args['bookingId'] != null) _bookingId = args['bookingId'];
      });

      // Security Check: Verify booking status
      final booking = MockData.bookings.firstWhere((b) => b.id == _bookingId, orElse: () => MockData.bookings.first);
      if (booking.status != 'Upcoming' && _bookingId.isNotEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Chat restricted: Booking not yet confirmed.")),
          );
          Navigator.pop(context);
        });
      }
    }
  }

  void _sendMessage() {
    final String text = _messageController.text.trim();
    if (text.isEmpty || _bookingId.isEmpty) return;

    ChatService.sendMessage(
      bookingId: _bookingId,
      text: text,
      senderId: _currentUserId,
      senderName: AuthService.currentUser?.name ?? 'User',
    );

    _messageController.clear();
    
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.surfaceLightGray,
      body: SafeArea(
        child: Column(
          children: [
            // 1. Contextual Navigation App Bar
            Container(
              height: 64,
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceContentDark : Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
                border: Border(
                  bottom: BorderSide(
                    color: isDark ? Colors.white.withOpacity(0.06) : Colors.black.withOpacity(0.04),
                  ),
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Row(
                children: [
                  // Back button
                  GestureDetector(
                    onTap: widget.onBackTap ?? () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      child: Icon(
                        Icons.arrow_back_rounded,
                        color: isDark ? Colors.white : AppColors.textDark,
                        size: 22,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),

                  // Profile Thumbnail circle
                  CircleAvatar(
                    radius: 20,
                    backgroundImage: NetworkImage(_providerImage),
                  ),
                  const SizedBox(width: 12),

                  // Name & Online Status
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _providerName,
                          style: GoogleFonts.nunito(
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                            color: isDark ? Colors.white : AppColors.textDark,
                            letterSpacing: -0.4,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                color: Colors.green,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              "Online Now",
                              style: GoogleFonts.nunito(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Audio Phone & Video Call Actions
                  GestureDetector(
                    onTap: () {
                      _showCallSimulation(context, "Video Call", Icons.videocam_rounded);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      child: Icon(
                        Icons.videocam_outlined,
                        color: isDark ? Colors.white70 : AppColors.textDark,
                        size: 22,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      _showCallSimulation(context, "Audio Call", Icons.phone_rounded);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      child: Icon(
                        Icons.phone_outlined,
                        color: isDark ? Colors.white70 : AppColors.textDark,
                        size: 22,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // 2. Asymmetric Message Feed Grid (StreamBuilder)
            Expanded(
              child: StreamBuilder<List<ChatMessage>>(
                stream: ChatService.watchMessages(_bookingId),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final messages = snapshot.data ?? [];
                  
                  return ListView.builder(
                    controller: _scrollController,
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                    itemCount: messages.length + 1, // Add +1 for Day Divider
                    itemBuilder: (context, index) {
                      // Render centered Day Divider as the first element
                      if (index == 0) {
                        return Center(
                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 12.0),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: isDark ? Colors.white.withOpacity(0.04) : Colors.black.withOpacity(0.04),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              "Today",
                              style: GoogleFonts.nunito(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textMutedGray,
                              ),
                            ),
                          ),
                        );
                      }

                      final message = messages[index - 1];
                      final bool isOutgoing = message.senderId == _currentUserId;

                      // Bubble Alignments & Color Fills
                      final Alignment alignment = isOutgoing ? Alignment.centerRight : Alignment.centerLeft;
                      final Color bubbleBg = isOutgoing 
                          ? (isDark ? AppColors.deepTeal.withOpacity(0.4) : AppColors.pastelBlue)
                          : (isDark ? const Color(0xFF121211) : Colors.white);
                      final Color textColor = isOutgoing 
                          ? (isDark ? Colors.white : AppColors.charcoalDark)
                          : (isDark ? Colors.white : AppColors.charcoalDark);
                      
                      final BorderRadius bubbleRadius = isOutgoing
                          ? const BorderRadius.only(
                              topLeft: Radius.circular(20),
                              topRight: Radius.circular(20),
                              bottomLeft: Radius.circular(20),
                              bottomRight: Radius.circular(4),
                            )
                          : const BorderRadius.only(
                              topLeft: Radius.circular(20),
                              topRight: Radius.circular(20),
                              bottomLeft: Radius.circular(4),
                              bottomRight: Radius.circular(20),
                            );

                      return Align(
                        alignment: alignment,
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: Column(
                            crossAxisAlignment: isOutgoing ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                            children: [
                              Container(
                                constraints: BoxConstraints(
                                  maxWidth: MediaQuery.of(context).size.width * 0.72,
                                ),
                                decoration: BoxDecoration(
                                  color: bubbleBg,
                                  borderRadius: bubbleRadius,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.02),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                  border: Border.all(
                                    color: isDark ? Colors.white.withOpacity(0.04) : Colors.transparent,
                                  ),
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                child: Text(
                                  message.text,
                                  style: GoogleFonts.nunito(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w600,
                                    color: textColor,
                                    height: 1.4,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 4),
                              // Message timestamp indicator
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                                child: Text(
                                  DateFormat('hh:mm a').format(message.timestamp),
                                  style: GoogleFonts.nunito(
                                    fontSize: 10,
                                    color: AppColors.textMutedGray,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                }
              ),
            ),

            // 3. Interactive Bottom Message Bar Container
            Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceContentDark : Colors.white,
                border: Border(
                  top: BorderSide(
                    color: isDark ? Colors.white.withOpacity(0.06) : Colors.black.withOpacity(0.04),
                  ),
                ),
              ),
              child: Row(
                children: [
                  // Message Input Capsule Component
                  Expanded(
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.surfaceElevatedDark : AppColors.surfaceLightGray,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Row(
                        children: [
                          Icon(
                            Icons.sentiment_satisfied_alt_outlined,
                            color: AppColors.textMutedGray,
                            size: 22,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: _messageController,
                              onSubmitted: (_) => _sendMessage(),
                              style: GoogleFonts.nunito(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w600,
                                color: isDark ? Colors.white : AppColors.textDark,
                              ),
                              decoration: InputDecoration(
                                hintText: "Write a message...",
                                hintStyle: GoogleFonts.nunito(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textMutedGray,
                                ),
                                border: InputBorder.none,
                                isDense: true,
                              ),
                            ),
                          ),
                          Icon(
                            Icons.attach_file_outlined,
                            color: AppColors.textMutedGray,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            Icons.camera_alt_outlined,
                            color: AppColors.textMutedGray,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Send Action Button
                  GestureDetector(
                    onTap: _sendMessage,
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.deepTeal,
                      ),
                      child: const Icon(
                        Icons.send_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCallSimulation(BuildContext context, String title, IconData icon) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.deepTeal.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 48, color: AppColors.deepTeal),
              ),
              const SizedBox(height: 24),
              Text(
                "Connecting $title...",
                style: GoogleFonts.nunito(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: isDark ? Colors.white : AppColors.charcoalDark,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                "Establishing a secure end-to-end encrypted line for your privacy.",
                textAlign: TextAlign.center,
                style: GoogleFonts.nunito(
                  fontSize: 14,
                  color: isDark ? Colors.white70 : AppColors.mutedGray,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 32),
              CircularProgressIndicator(color: AppColors.deepTeal),
              const SizedBox(height: 32),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  "Cancel Call",
                  style: GoogleFonts.nunito(
                    color: Colors.red,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
