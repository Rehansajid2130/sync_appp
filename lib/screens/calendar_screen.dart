import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/data/mock_data.dart';
import 'package:intl/intl.dart';

class CalendarScreen extends StatefulWidget {
  final bool isProvider; // Reuse flag

  const CalendarScreen({super.key, this.isProvider = false});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Filter bookings for the selected date
    // If provider view, show all jobs for this date (simulating provider's schedule)
    // If client view, show their bookings
    final dailyBookings = MockData.bookings.where((b) => 
      b.date.day == _selectedDate.day && 
      b.date.month == _selectedDate.month && 
      b.date.year == _selectedDate.year &&
      b.status != 'Cancelled'
    ).toList();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildHeader(isDark),
            const SizedBox(height: 20),
            _buildDateStrip(isDark),
            const SizedBox(height: 24),
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF090909) : Colors.white,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(32),
                    topRight: Radius.circular(32),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.isProvider ? 'Assigned Jobs' : 'Plan for Today',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Expanded(
                      child: dailyBookings.isEmpty
                           ? _buildEmptyState(isDark)
                           : _buildScheduleList(dailyBookings, isDark),
                    ),
                  ],
                ),
              ),
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
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: isDark ? const Color(0xFF161616) : Colors.black.withOpacity(0.05), shape: BoxShape.circle),
            child: Icon(Icons.calendar_month, color: isDark ? Colors.white : Colors.black, size: 20),
          ),
          const SizedBox(width: 12),
          Text(
            widget.isProvider ? 'My Schedule' : 'Calendar',
            style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 24, fontWeight: FontWeight.w800),
          ),
          const Spacer(),
          if (!widget.isProvider) _buildCircleButton(Icons.add, isDark),
        ],
      ),
    );
  }

  Widget _buildCircleButton(IconData icon, bool isDark) {
    return Container(
      width: 40, height: 40,
      decoration: BoxDecoration(color: isDark ? const Color(0xFF161616) : Colors.white, shape: BoxShape.circle, border: Border.all(color: isDark ? Colors.white10 : Colors.black.withOpacity(0.05))),
      child: Icon(icon, color: isDark ? Colors.white : Colors.black, size: 20),
    );
  }

  Widget _buildDateStrip(bool isDark) {
    return SizedBox(
      height: 90,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24),
        itemCount: 14,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final date = DateTime.now().add(Duration(days: index - 2));
          final isSelected = date.day == _selectedDate.day && date.month == _selectedDate.month;
          return GestureDetector(
            onTap: () => setState(() => _selectedDate = date),
            child: Container(
              width: 60,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : (isDark ? const Color(0xFF161616) : const Color(0xFFF1F4F8)),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(DateFormat('MMM').format(date), style: TextStyle(color: isSelected ? Colors.white70 : Colors.grey, fontSize: 12)),
                  const SizedBox(height: 4),
                  Text(date.day.toString(), style: TextStyle(color: isSelected ? Colors.white : (isDark ? Colors.white : Colors.black), fontSize: 18, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 4),
                  Text(DateFormat('E').format(date), style: TextStyle(color: isSelected ? Colors.white70 : Colors.grey, fontSize: 12)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildScheduleList(List<Booking> bookings, bool isDark) {
    return ListView.separated(
      physics: const BouncingScrollPhysics(),
      itemCount: bookings.length,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (context, index) => _buildScheduleCard(bookings[index], isDark),
    );
  }

  Widget _buildScheduleCard(Booking booking, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF161616) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isDark ? Colors.white10 : Colors.black.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Container(
            width: 50, height: 50,
            decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
            child: Icon(booking.icon, color: AppColors.primary, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(booking.serviceName, style: TextStyle(fontWeight: FontWeight.w700, color: isDark ? Colors.white : Colors.black)),
                const SizedBox(height: 4),
                Text(
                  widget.isProvider ? 'Client: ${booking.clientName}' : 'Provider: ${booking.providerName}',
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(booking.time, style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700, fontSize: 12)),
              const SizedBox(height: 4),
              const Icon(Icons.more_vert, size: 18, color: Colors.grey),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.event_busy, size: 60, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            widget.isProvider ? 'No jobs assigned' : 'No services scheduled',
            style: TextStyle(color: isDark ? Colors.white54 : Colors.grey, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
