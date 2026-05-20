import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../core/theme/app_colors.dart';
import '../widgets/new_ui/weekly_date_ribbon.dart';
import '../widgets/new_ui/event_agenda_card.dart';
import '../widgets/new_ui/radial_time_picker.dart';
import '../core/data/mock_data.dart';
import '../models/service_provider.dart';

class CalendarScreen extends StatefulWidget {
  final bool isProvider;
  const CalendarScreen({super.key, this.isProvider = false});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _selectedDate = DateTime.now();
  
  // Custom mock conflict days list: e.g. Day 8 and 12 have conflicts
  // Let's dynamically add a conflict on today's day number to demonstrate it!
  late List<int> _conflictDays;

  @override
  void initState() {
    super.initState();
    final today = DateTime.now().day;
    _conflictDays = [today, today + 2, today - 1];
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final todayDayNumber = DateTime.now().day;
    
    final bool isConflictDay = _selectedDate.day == todayDayNumber || 
                               _selectedDate.day == (todayDayNumber - 1);

    final String dayFormatted = DateFormat('MMM d • EEEE').format(_selectedDate);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF090909) : Colors.white,
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // App Bar Title
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF161616) : AppColors.surfaceLightGray,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.calendar_today,
                          color: isDark ? Colors.white : AppColors.textDark,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        "Schedule",
                        style: GoogleFonts.nunito(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: isDark ? Colors.white : AppColors.textDark,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // 2. Horizontal Weekly Date Ribbon
                  WeeklyDateRibbon(
                    selectedDate: _selectedDate,
                    conflictDays: _conflictDays,
                    onDateSelected: (date) {
                      setState(() {
                        _selectedDate = date;
                      });
                    },
                  ),
                  const SizedBox(height: 28),

                  // 3. Chronological Agenda Timeline (Vertical List)
                  // Header details
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        dayFormatted,
                        style: GoogleFonts.nunito(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: isDark ? Colors.white : AppColors.textDark,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: isConflictDay
                              ? AppColors.alertOrange.withOpacity(0.1)
                              : AppColors.secondaryGreen.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          isConflictDay ? "Conflict Day" : "Clear Schedule",
                          style: GoogleFonts.nunito(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: isConflictDay ? AppColors.alertOrange : AppColors.deepTeal,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    isConflictDay 
                        ? "Scheduling conflicts identified. Tap cards to re-negotiate."
                        : "Easy to negotiate and plan. All events look healthy.",
                    style: GoogleFonts.nunito(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textMutedGray,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildBookingsList(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingsList() {
    final bookingsForDay = MockData.bookings.where((b) {
      return b.date.year == _selectedDate.year &&
             b.date.month == _selectedDate.month &&
             b.date.day == _selectedDate.day &&
             b.status != 'Cancelled';
    }).toList();

    if (bookingsForDay.isEmpty) {
      return Padding(
        padding: const EdgeInsets.only(top: 40),
        child: Center(
          child: Text(
            "No bookings scheduled for this day.",
            style: GoogleFonts.nunito(
              color: AppColors.textMutedGray,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: bookingsForDay.length,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final booking = bookingsForDay[index];
        return EventAgendaCard(
          time: booking.time,
          title: '${booking.serviceName} with ${widget.isProvider ? booking.clientName : booking.providerName}',
          status: booking.status,
          hasConflict: false, // We'll ignore real conflicts for now
          onCancel: () {
            setState(() {
              MockData.cancelBooking(booking.id);
            });
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Booking cancelled.")),
            );
          },
          onReschedule: () {
            _openRadialTimePicker(booking);
          },
        );
      },
    );
  }

  void _openRadialTimePicker(Booking booking) {
    int hour = 12;
    String period = "PM";
    try {
      final parts = booking.time.split(RegExp(r'[: ]'));
      hour = int.parse(parts[0]);
      period = parts.length > 2 ? parts[2] : "PM";
    } catch (_) {}

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => RadialTimePicker(
        initialHour: hour,
        initialPeriod: period,
        onTimeSelected: (timeOfDay) {
          final newTime = timeOfDay.format(context);
          setState(() {
            MockData.rescheduleBooking(booking.id, newTime);
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Rescheduled to $newTime"),
              backgroundColor: AppColors.deepTeal,
            ),
          );
        },
      ),
    );
  }
}
