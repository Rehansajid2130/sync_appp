import 'package:flutter/material.dart';
import '../models/service_provider.dart';
import '../core/data/mock_data.dart';
import '../widgets/section_card.dart';
import '../widgets/primary_button.dart';
import 'booking_success_screen.dart';

class BookingSummaryScreen extends StatelessWidget {
  final ServiceProvider provider;
  final DateTime date;
  final String time;
  final String address;
  final String description;
  final List<String> imagePaths;

  const BookingSummaryScreen({
    super.key,
    required this.provider,
    required this.date,
    required this.time,
    required this.address,
    required this.description,
    required this.imagePaths,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Review Summary', style: TextStyle(color: isDark ? Colors.white : Colors.black, fontWeight: FontWeight.w700)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSection('Service Details', [
                    _buildDetailRow('Service', provider.category, isDark),
                    _buildDetailRow('Provider', provider.name, isDark),
                  ], isDark),
                  const SizedBox(height: 24),
                  _buildSection('Schedule', [
                    _buildDetailRow('Date', '${date.day} ${_getMonthName(date.month)} ${date.year}', isDark),
                    _buildDetailRow('Time', time, isDark),
                  ], isDark),
                  const SizedBox(height: 24),
                  _buildSection('Address', [
                    _buildDetailRow('Location', address, isDark),
                  ], isDark),
                  if (description.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    _buildSection('Service Details', [
                      _buildDetailRow('Description', description, isDark),
                      if (imagePaths.isNotEmpty)
                        _buildDetailRow('Attached', '${imagePaths.length} Photos', isDark),
                    ], isDark),
                  ],
                ],
              ),
            ),
          ),
          _buildBottomBar(context, isDark),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children, bool isDark) {
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: isDark ? Colors.white : Colors.black)),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: isDark ? Colors.white54 : Colors.grey[600], fontSize: 14)),
          Text(value, style: TextStyle(fontWeight: FontWeight.w700, color: isDark ? Colors.white : Colors.black, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF161616) : Colors.white,
        border: Border(top: BorderSide(color: isDark ? Colors.white10 : Colors.black.withOpacity(0.05))),
      ),
      child: PrimaryButton(
        text: 'Confirm Booking',
        onPressed: () {
          // Actually "save" the booking to our mock data
          MockData.bookings.insert(0, Booking(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            serviceName: provider.category,
            providerName: provider.name,
            clientName: 'Alex Carter',
            status: 'Upcoming',
            date: date,
            time: time,
            icon: provider.icon,
            description: description,
            imagePaths: imagePaths,
          ));
          MockData.saveBookings();

          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const BookingSuccessScreen()),
            (route) => false,
          );
        },
      ),
    );
  }

  String _getMonthName(int month) {
    const names = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return names[month - 1];
  }
}
