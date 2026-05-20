import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/app_colors.dart';
import '../../core/data/mock_data.dart';
import '../new_ui/new_chat_detail_screen.dart';

class OngoingJobScreen extends StatefulWidget {
  final Booking booking;
  const OngoingJobScreen({super.key, required this.booking});

  @override
  State<OngoingJobScreen> createState() => _OngoingJobScreenState();
}

class _OngoingJobScreenState extends State<OngoingJobScreen> {
  int _currentStep = 1; // 0: Arrived, 1: Started, 2: Completed

  Future<void> _launchUrl(String urlString) async {
    final Uri url = Uri.parse(urlString);
    try {
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Could not launch $urlString')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error opening link')),
        );
      }
    }
  }

  void _nextStep() async {
    if (_currentStep < 2) {
      setState(() => _currentStep++);
    } else {
      await MockData.updateBookingStatus(widget.booking.id, 'Completed');
      _showCompletionDialog();
    }
  }

  void _showCompletionDialog() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: isDark ? const Color(0xFF161616) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.pastelGreen,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_rounded, color: Color(0xFF1A6B3C), size: 48),
              ),
              const SizedBox(height: 24),
              Text(
                'Job Completed!',
                style: GoogleFonts.nunito(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: isDark ? Colors.white : AppColors.charcoalDark,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Great work! The client has been notified and your history has been updated.',
                textAlign: TextAlign.center,
                style: GoogleFonts.nunito(
                  color: AppColors.mutedGray,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.deepTeal,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  ),
                  child: Text(
                    'Back to Dashboard',
                    style: GoogleFonts.nunito(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF090909) : const Color(0xFFF9F9FB),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Custom Header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF161616) : Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.06),
                        ),
                      ),
                      child: Icon(
                        Icons.close_rounded,
                        color: isDark ? Colors.white : AppColors.charcoalDark,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      'Ongoing Job',
                      style: GoogleFonts.nunito(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: isDark ? Colors.white : AppColors.charcoalDark,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    const SizedBox(height: 8),
                    _buildStatusTimeline(isDark),
                    const SizedBox(height: 28),
                    _buildCustomerCard(isDark),
                    const SizedBox(height: 16),
                    _buildLocationCard(isDark),
                    const SizedBox(height: 16),
                    _buildJobDetails(isDark),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
            _buildBottomAction(isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusTimeline(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF161616) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.06) : Colors.black.withOpacity(0.04),
        ),
      ),
      child: Row(
        children: [
          _buildStepIndicator(0, 'Arrived', Icons.location_on_rounded, _currentStep >= 0, isDark),
          _buildConnector(_currentStep >= 1),
          _buildStepIndicator(1, 'Started', Icons.play_arrow_rounded, _currentStep >= 1, isDark),
          _buildConnector(_currentStep >= 2),
          _buildStepIndicator(2, 'Finish', Icons.check_rounded, _currentStep >= 2, isDark),
        ],
      ),
    );
  }

  Widget _buildStepIndicator(int index, String label, IconData icon, bool isActive, bool isDark) {
    return Expanded(
      child: Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isActive ? AppColors.deepTeal : (isDark ? const Color(0xFF2A2A2A) : AppColors.surfaceLightGray),
              shape: BoxShape.circle,
              boxShadow: isActive
                  ? [BoxShadow(color: AppColors.deepTeal.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))]
                  : [],
            ),
            child: Icon(icon, color: isActive ? Colors.white : AppColors.mutedGray, size: 22),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: GoogleFonts.nunito(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: isActive ? AppColors.deepTeal : AppColors.mutedGray,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConnector(bool isActive) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: 36,
        height: 2,
        decoration: BoxDecoration(
          color: isActive ? AppColors.deepTeal : AppColors.mutedGray.withOpacity(0.2),
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  Widget _buildCustomerCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF161616) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.06) : Colors.black.withOpacity(0.04),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.deepTeal.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.person_rounded, color: AppColors.deepTeal, size: 28),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.booking.clientName,
                  style: GoogleFonts.nunito(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: isDark ? Colors.white : AppColors.charcoalDark,
                  ),
                ),
                Text(
                  'Client',
                  style: GoogleFonts.nunito(
                    color: AppColors.mutedGray,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          _buildActionButton(
            Icons.chat_bubble_outline_rounded,
            AppColors.deepTeal,
            isDark,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NewChatDetailScreen(
                    chatArguments: {
                      'providerName': widget.booking.clientName,
                      'providerImage': 'https://i.pravatar.cc/150',
                      'bookingId': widget.booking.id,
                    },
                  ),
                ),
              );
            },          ),
          const SizedBox(width: 10),
          _buildActionButton(
            Icons.call_outlined,
            const Color(0xFF2563EB),
            isDark,
            onTap: () => _launchUrl('tel:+1234567890'),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(IconData icon, Color color, bool isDark, {required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(11),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
    );
  }

  Widget _buildLocationCard(bool isDark) {
    const String address = 'DHA Phase 6, Lahore, Pakistan';
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF161616) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.06) : Colors.black.withOpacity(0.04),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Job Location',
            style: GoogleFonts.nunito(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: AppColors.mutedGray,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.deepTeal.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.location_on_rounded, color: AppColors.deepTeal, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  address,
                  style: GoogleFonts.nunito(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : AppColors.charcoalDark,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _launchUrl(
                'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(address)}',
              ),
              icon: const Icon(Icons.near_me_rounded, size: 16),
              label: Text(
                'Open in Navigation',
                style: GoogleFonts.nunito(fontWeight: FontWeight.w800, fontSize: 13),
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 13),
                foregroundColor: AppColors.deepTeal,
                side: const BorderSide(color: AppColors.deepTeal),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJobDetails(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF161616) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.06) : Colors.black.withOpacity(0.04),
        ),
      ),
      child: Column(
        children: [
          _buildDetailRow('Service Type', widget.booking.serviceName, isDark),
          Divider(height: 28, color: isDark ? Colors.white.withOpacity(0.06) : Colors.black.withOpacity(0.05)),
          _buildDetailRow('Scheduled Time', widget.booking.time, isDark),
          Divider(height: 28, color: isDark ? Colors.white.withOpacity(0.06) : Colors.black.withOpacity(0.05)),
          _buildDetailRow('Status', widget.booking.status, isDark),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.nunito(
            color: AppColors.mutedGray,
            fontWeight: FontWeight.w700,
            fontSize: 13,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.nunito(
            fontWeight: FontWeight.w800,
            fontSize: 13,
            color: isDark ? Colors.white : AppColors.charcoalDark,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomAction(bool isDark) {
    final List<String> labels = ['Arrived at Location', 'Finish Job', 'Completed ✓'];
    final String buttonText = labels[_currentStep];
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 36),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF121211) : Colors.white,
        border: Border(
          top: BorderSide(
            color: isDark ? Colors.white.withOpacity(0.06) : Colors.black.withOpacity(0.05),
          ),
        ),
      ),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed: _nextStep,
          style: ElevatedButton.styleFrom(
            backgroundColor: _currentStep == 2 ? const Color(0xFF1A6B3C) : AppColors.deepTeal,
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
          ),
          child: Text(
            buttonText,
            style: GoogleFonts.nunito(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 15,
            ),
          ),
        ),
      ),
    );
  }
}
