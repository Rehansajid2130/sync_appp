import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/app_colors.dart';
import '../../core/data/mock_data.dart';
import '../chat_detail_screen.dart';

class OngoingJobScreen extends StatefulWidget {
  final Booking booking; // Added real booking data

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
      // Consistency: Update "Database" when job is finished
      await MockData.updateBookingStatus(widget.booking.id, 'Completed');
      _showCompletionDialog();
    }
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), shape: BoxShape.circle),
              child: const Icon(Icons.check_circle, color: Colors.green, size: 60),
            ),
            const SizedBox(height: 24),
            const Text('Job Completed!', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            const Text('Great work! The client has been notified and your history has been updated.', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // Close dialog
                  Navigator.pop(context); // Return to dashboard
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: const Text('Back to Dashboard', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: isDark ? Colors.white : Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Ongoing Job', style: TextStyle(color: isDark ? Colors.white : Colors.black, fontWeight: FontWeight.w800)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  _buildStatusTimeline(isDark),
                  const SizedBox(height: 40),
                  _buildCustomerCard(isDark),
                  const SizedBox(height: 24),
                  _buildLocationCard(isDark),
                  const SizedBox(height: 24),
                  _buildJobDetails(isDark),
                ],
              ),
            ),
          ),
          _buildBottomAction(isDark),
        ],
      ),
    );
  }

  Widget _buildStatusTimeline(bool isDark) {
    return Row(
      children: [
        _buildStepIndicator(0, 'Arrived', Icons.location_on, _currentStep >= 0),
        _buildLine(_currentStep >= 1),
        _buildStepIndicator(1, 'Started', Icons.play_arrow, _currentStep >= 1),
        _buildLine(_currentStep >= 2),
        _buildStepIndicator(2, 'Finish', Icons.check, _currentStep >= 2),
      ],
    );
  }

  Widget _buildStepIndicator(int index, String label, IconData icon, bool isActive) {
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              color: isActive ? AppColors.primary : (Theme.of(context).brightness == Brightness.dark ? const Color(0xFF161616) : const Color(0xFFF1F4F8)),
              shape: BoxShape.circle,
              border: Border.all(color: isActive ? AppColors.primary : Colors.grey.withOpacity(0.3)),
            ),
            child: Icon(icon, color: isActive ? Colors.white : Colors.grey, size: 20),
          ),
          const SizedBox(height: 8),
          Text(label, style: TextStyle(fontSize: 12, fontWeight: isActive ? FontWeight.bold : FontWeight.normal, color: isActive ? AppColors.primary : Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildLine(bool isActive) {
    return Container(
      width: 40, height: 2,
      margin: const EdgeInsets.only(bottom: 24),
      color: isActive ? AppColors.primary : Colors.grey.withOpacity(0.2),
    );
  }

  Widget _buildCustomerCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF161616) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isDark ? Colors.white10 : Colors.black.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          const CircleAvatar(radius: 28, backgroundColor: AppColors.primary, child: Icon(Icons.person, color: Colors.white, size: 32)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.booking.clientName, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: isDark ? Colors.white : Colors.black)),
                const Text('Client', style: TextStyle(color: Colors.grey)),
              ],
            ),
          ),
          _buildActionButton(Icons.chat_bubble_outline, AppColors.primary, isDark, onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const ChatDetailScreen()));
          }),
          const SizedBox(width: 12),
          _buildActionButton(Icons.call_outlined, Colors.blue, isDark, onTap: () {
            _launchUrl('tel:+1234567890');
          }),
        ],
      ),
    );
  }

  Widget _buildActionButton(IconData icon, Color color, bool isDark, {required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(16)),
        child: Icon(icon, color: color, size: 22),
      ),
    );
  }

  Widget _buildLocationCard(bool isDark) {
    const String address = '24 Baker Street, New York, NY 10001';
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF161616) : Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Location', style: TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.location_on, color: AppColors.primary, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  address,
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: isDark ? Colors.white : Colors.black),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                _launchUrl('https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(address)}');
              },
              icon: const Icon(Icons.near_me_outlined),
              label: const Text('Open in Maps'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary),
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
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF161616) : Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          _buildDetailRow('Service Type', widget.booking.serviceName, isDark),
          const Divider(height: 32),
          _buildDetailRow('Time', widget.booking.time, isDark),
          const Divider(height: 32),
          _buildDetailRow('Status', widget.booking.status, isDark),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.w500)),
        Text(value, style: TextStyle(fontWeight: FontWeight.w800, color: isDark ? Colors.white : Colors.black)),
      ],
    );
  }

  Widget _buildBottomAction(bool isDark) {
    String buttonText = 'Arrived at Location';
    if (_currentStep == 1) buttonText = 'Finish Job';
    if (_currentStep == 2) buttonText = 'Completed';

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF161616) : Colors.white,
        border: Border(top: BorderSide(color: isDark ? Colors.white10 : Colors.black.withOpacity(0.05))),
      ),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed: _nextStep,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
            elevation: 0,
          ),
          child: Text(buttonText, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
        ),
      ),
    );
  }
}
