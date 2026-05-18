import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/data/mock_data.dart';
import 'package:intl/intl.dart';

class BookingsScreen extends StatefulWidget {
  final bool isProvider; // Reuse flag

  const BookingsScreen({super.key, this.isProvider = false});

  @override
  State<BookingsScreen> createState() => _BookingsScreenState();
}

class _BookingsScreenState extends State<BookingsScreen> {
  String _selectedTab = 'All';
  final List<String> _tabs = ['All', 'Upcoming', 'Completed', 'Cancelled'];

  void _cancelBooking(String id) {
    showDialog(
      context: context,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return AlertDialog(
          backgroundColor: isDark ? const Color(0xFF161616) : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Text('Cancel Booking', style: TextStyle(color: isDark ? Colors.white : Colors.black, fontWeight: FontWeight.bold)),
          content: Text('Are you sure you want to cancel this booking?', style: TextStyle(color: isDark ? Colors.white70 : Colors.black87)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('No', style: TextStyle(color: isDark ? Colors.white54 : Colors.grey)),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  final index = MockData.bookings.indexWhere((b) => b.id == id);
                  if (index != -1) {
                    final b = MockData.bookings[index];
                    MockData.bookings[index] = Booking(
                      id: b.id,
                      serviceName: b.serviceName,
                      providerName: b.providerName,
                      clientName: b.clientName,
                      status: 'Cancelled',
                      date: b.date,
                      time: b.time,
                      icon: b.icon,
                    );
                    MockData.saveBookings();
                  }
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Booking cancelled successfully'), backgroundColor: Colors.red),
                );
              },
              child: const Text('Yes, Cancel', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Filter logic
    final filteredBookings = _selectedTab == 'All'
        ? MockData.bookings
        : MockData.bookings.where((b) => b.status == _selectedTab).toList();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildHeader(isDark),
            const SizedBox(height: 20),
            _buildTabBar(isDark),
            const SizedBox(height: 24),
            Expanded(
              child: filteredBookings.isEmpty
                  ? _buildEmptyState(isDark)
                  : _buildBookingsList(filteredBookings, isDark),
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
            widget.isProvider ? 'Service History' : 'My Bookings', 
            style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 24, fontWeight: FontWeight.w800),
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
      decoration: BoxDecoration(color: isDark ? const Color(0xFF161616) : Colors.white, shape: BoxShape.circle, border: Border.all(color: isDark ? Colors.white10 : Colors.black.withOpacity(0.05))),
      child: Icon(icon, color: isDark ? Colors.white : AppColors.textPrimaryLight, size: 20),
    );
  }

  Widget _buildTabBar(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        height: 50,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF161616) : Colors.white,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: isDark ? Colors.white10 : Colors.black.withOpacity(0.03)),
        ),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: _tabs.map((tab) {
              final isSelected = _selectedTab == tab;
              return GestureDetector(
                onTap: () => setState(() => _selectedTab = tab),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  margin: const EdgeInsets.only(right: 4),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary : Colors.transparent,
                    borderRadius: BorderRadius.circular(21),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    tab,
                    style: TextStyle(
                      color: isSelected ? Colors.white : (isDark ? Colors.white70 : Colors.grey),
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildBookingsList(List<Booking> bookings, bool isDark) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 120),
      physics: const BouncingScrollPhysics(),
      itemCount: bookings.length,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (context, index) => _buildBookingCard(bookings[index], isDark),
    );
  }

  Widget _buildBookingCard(Booking booking, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF161616) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isDark ? Colors.white10 : Colors.black.withOpacity(0.03)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 60, height: 60,
                decoration: BoxDecoration(color: isDark ? const Color(0xFF262626) : const Color(0xFFF1F4F8), borderRadius: BorderRadius.circular(16)),
                child: Icon(booking.icon, color: AppColors.primary),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(booking.serviceName, style: TextStyle(fontWeight: FontWeight.w700, color: isDark ? Colors.white : Colors.black, fontSize: 16)),
                    const SizedBox(height: 4),
                    Text(
                      widget.isProvider ? 'Client: ${booking.clientName}' : 'Provider: ${booking.providerName}', 
                      style: TextStyle(color: isDark ? Colors.white70 : Colors.grey, fontSize: 13),
                    ),
                  ],
                ),
              ),
              _buildStatusBadge(booking.status),
            ],
          ),
          const SizedBox(height: 16),
          Divider(color: isDark ? Colors.white10 : Colors.black.withOpacity(0.05)),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildInfoRow(Icons.calendar_today_outlined, DateFormat('MMM dd, yyyy').format(booking.date), isDark),
              const SizedBox(width: 20),
              _buildInfoRow(Icons.access_time, booking.time, isDark),
            ],
          ),
          if (booking.status == 'Upcoming' && !widget.isProvider) ...[
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _cancelBooking(booking.id),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                      side: BorderSide(color: isDark ? Colors.white24 : Colors.black12),
                    ),
                    child: Text('Cancel', style: TextStyle(color: isDark ? Colors.white : Colors.black, fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      MockData.sendJobReminder(booking);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Reminder sent to both parties! ⏰'), backgroundColor: AppColors.primary),
                      );
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary.withOpacity(0.1), elevation: 0, padding: const EdgeInsets.symmetric(vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24))),
                    child: const Text('Remind Me', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, padding: const EdgeInsets.symmetric(vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24))),
                    child: const Text('View Booking', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          ] else if (widget.isProvider && booking.status == 'Upcoming') ...[
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      MockData.sendJobReminder(booking);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Reminder sent! 🛠'), backgroundColor: AppColors.primary),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    ),
                    child: const Text('Send Reminder', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, padding: const EdgeInsets.symmetric(vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24))),
                    child: const Text('Job Details', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color = status == 'Upcoming' ? Colors.orange : (status == 'Completed' ? AppColors.primary : Colors.red);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
      child: Text(status, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w700)),
    );
  }

  Widget _buildInfoRow(IconData icon, String text, bool isDark) {
    return Row(
      children: [
        Icon(icon, size: 16, color: isDark ? Colors.white54 : Colors.grey),
        const SizedBox(width: 6),
        Text(text, style: TextStyle(color: isDark ? Colors.white70 : Colors.grey[700], fontSize: 13, fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.calendar_today_outlined, size: 80, color: AppColors.primary),
          const SizedBox(height: 24),
          Text(
            widget.isProvider ? 'No ${_selectedTab} Jobs' : 'No ${_selectedTab} Bookings', 
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: isDark ? Colors.white : Colors.black),
          ),
          const SizedBox(height: 12),
          Text(
            widget.isProvider 
                ? 'You don\'t have any ${_selectedTab.toLowerCase()} jobs in your record.'
                : 'You don\'t have any ${_selectedTab.toLowerCase()} bookings.', 
            style: TextStyle(color: isDark ? Colors.white70 : Colors.grey),
          ),
        ],
      ),
    );
  }
}
