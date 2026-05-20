import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme/app_colors.dart';
import '../core/data/mock_data.dart';
import 'package:intl/intl.dart';
import '../core/routes/app_routes.dart';

class BookingsScreen extends StatefulWidget {
  final bool isProvider; 

  const BookingsScreen({super.key, this.isProvider = false});

  @override
  State<BookingsScreen> createState() => _BookingsScreenState();
}

class _BookingsScreenState extends State<BookingsScreen> {
  String _selectedTab = 'All';
  final List<String> _tabs = ['All', 'Pending', 'Upcoming', 'Completed', 'Cancelled'];

  void _cancelBooking(String id) {
    showDialog(
      context: context,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return AlertDialog(
          backgroundColor: isDark ? const Color(0xFF161616) : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Text('Cancel Booking', style: GoogleFonts.nunito(color: isDark ? Colors.white : Colors.black, fontWeight: FontWeight.bold)),
          content: Text('Are you sure you want to cancel this booking?', style: GoogleFonts.nunito(color: isDark ? Colors.white70 : Colors.black87)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('No', style: GoogleFonts.nunito(color: isDark ? Colors.white54 : Colors.grey)),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  final index = MockData.bookings.indexWhere((b) => b.id == id);
                  if (index != -1) {
                    MockData.bookings[index].status = 'Cancelled';
                    MockData.saveBookings();
                  }
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Booking cancelled successfully'), backgroundColor: Colors.red),
                );
              },
              child: Text('Yes, Cancel', style: GoogleFonts.nunito(color: Colors.red, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    final filteredBookings = _selectedTab == 'All'
        ? MockData.bookings
        : MockData.bookings.where((b) => b.status == _selectedTab).toList();

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.offWhite,
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
            decoration: const BoxDecoration(color: AppColors.deepTeal, shape: BoxShape.circle),
            child: const Icon(Icons.sync_alt_rounded, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 12),
          Text(
            widget.isProvider ? 'Service History' : 'My Bookings', 
            style: GoogleFonts.nunito(color: isDark ? Colors.white : AppColors.charcoalDark, fontSize: 24, fontWeight: FontWeight.w900),
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
      child: Icon(icon, color: isDark ? Colors.white : AppColors.charcoalDark, size: 20),
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
                    color: isSelected ? AppColors.deepTeal : Colors.transparent,
                    borderRadius: BorderRadius.circular(21),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    tab,
                    style: GoogleFonts.nunito(
                      color: isSelected ? Colors.white : (isDark ? Colors.white70 : AppColors.mutedGray),
                      fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
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
                child: Icon(booking.icon, color: AppColors.deepTeal),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(booking.serviceName, style: GoogleFonts.nunito(fontWeight: FontWeight.w800, color: isDark ? Colors.white : AppColors.charcoalDark, fontSize: 16)),
                    const SizedBox(height: 4),
                    Text(
                      widget.isProvider ? 'Client: ${booking.clientName}' : 'Provider: ${booking.providerName}', 
                      style: GoogleFonts.nunito(color: isDark ? Colors.white70 : AppColors.mutedGray, fontSize: 13, fontWeight: FontWeight.w600),
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
          const SizedBox(height: 20),
          _buildActionButtons(booking, isDark),
        ],
      ),
    );
  }

  Widget _buildActionButtons(Booking booking, bool isDark) {
    if (!widget.isProvider) {
      // Customer Actions
      if (booking.status == 'Pending' || booking.status == 'Upcoming') {
        return Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => _cancelBooking(booking.id),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  side: BorderSide(color: isDark ? Colors.white24 : Colors.black12),
                ),
                child: Text('Cancel', style: GoogleFonts.nunito(color: isDark ? Colors.white : AppColors.charcoalDark, fontWeight: FontWeight.w700)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: () => _showBookingDetails(booking, isDark),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.deepTeal,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                ),
                child: Text('View Details', style: GoogleFonts.nunito(color: Colors.white, fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        );
      } else if (booking.status == 'Completed') {
        return SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              final provider = MockData.providers.firstWhere((p) => p.name == booking.providerName, orElse: () => MockData.providers.first);
              Navigator.pushNamed(context, AppRoutes.rateProvider, arguments: {
                'providerId': provider.id,
                'providerName': provider.name,
                'bookingId': booking.id,
              });
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.deepTeal, padding: const EdgeInsets.symmetric(vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24))),
            child: Text('Rate Provider', style: GoogleFonts.nunito(color: Colors.white, fontWeight: FontWeight.w700)),
          ),
        );
      }
    } else {
      // Provider Actions
      if (booking.status == 'Pending') {
        return Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                   setState(() {
                    final index = MockData.bookings.indexWhere((b) => b.id == booking.id);
                    if (index != -1) MockData.bookings[index].status = 'Cancelled';
                    MockData.saveBookings();
                  });
                },
                style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)), side: const BorderSide(color: Colors.red)),
                child: Text('Decline', style: GoogleFonts.nunito(color: Colors.red, fontWeight: FontWeight.w700)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    final index = MockData.bookings.indexWhere((b) => b.id == booking.id);
                    if (index != -1) MockData.bookings[index].status = 'Upcoming';
                    MockData.saveBookings();
                  });
                },
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.deepTeal, padding: const EdgeInsets.symmetric(vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24))),
                child: Text('Accept Offer', style: GoogleFonts.nunito(color: Colors.white, fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        );
      } else if (booking.status == 'Upcoming') {
        return SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => _showBookingDetails(booking, isDark),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.deepTeal, padding: const EdgeInsets.symmetric(vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24))),
            child: Text('Job Details', style: GoogleFonts.nunito(color: Colors.white, fontWeight: FontWeight.w700)),
          ),
        );
      }
    }
    return const SizedBox.shrink();
  }

  void _showBookingDetails(Booking booking, bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF161616) : Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(width: 40, height: 4, decoration: BoxDecoration(color: isDark ? Colors.white10 : Colors.black12, borderRadius: BorderRadius.circular(10))),
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Container(
                    width: 60, height: 60,
                    decoration: BoxDecoration(color: AppColors.deepTeal.withOpacity(0.08), borderRadius: BorderRadius.circular(16)),
                    child: Icon(booking.icon, color: AppColors.deepTeal, size: 30),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(booking.serviceName, style: GoogleFonts.nunito(fontSize: 20, fontWeight: FontWeight.w900, color: isDark ? Colors.white : AppColors.charcoalDark)),
                        Text("Booking ID: #${booking.id.substring(booking.id.length - 6)}", style: GoogleFonts.nunito(fontSize: 13, color: AppColors.mutedGray, fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              _buildDetailRow(Icons.person_outline_rounded, widget.isProvider ? "Client Name" : "Provider Name", widget.isProvider ? booking.clientName : booking.providerName, isDark),
              const SizedBox(height: 20),
              _buildDetailRow(Icons.calendar_today_rounded, "Scheduled Date", DateFormat('EEEE, MMM dd, yyyy').format(booking.date), isDark),
              const SizedBox(height: 20),
              _buildDetailRow(Icons.access_time_rounded, "Scheduled Time", booking.time, isDark),
              const SizedBox(height: 32),
              Text("Job Description", style: GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.w800, color: isDark ? Colors.white : AppColors.charcoalDark)),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: isDark ? const Color(0xFF1A1A1A) : AppColors.offWhite, borderRadius: BorderRadius.circular(16)),
                child: Text(
                  booking.description.isNotEmpty ? booking.description : "No specific instructions provided for this job.",
                  style: GoogleFonts.nunito(fontSize: 14, color: isDark ? Colors.white70 : AppColors.charcoalDark, height: 1.5, fontWeight: FontWeight.w500),
                ),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.deepTeal, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)), elevation: 0),
                  child: Text("Close Details", style: GoogleFonts.nunito(fontWeight: FontWeight.w900, fontSize: 16, color: Colors.white)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value, bool isDark) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: isDark ? const Color(0xFF1A1A1A) : AppColors.offWhite, shape: BoxShape.circle),
          child: Icon(icon, size: 18, color: AppColors.deepTeal),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: GoogleFonts.nunito(fontSize: 12, color: AppColors.mutedGray, fontWeight: FontWeight.w700)),
            Text(value, style: GoogleFonts.nunito(fontSize: 15, fontWeight: FontWeight.w800, color: isDark ? Colors.white : AppColors.charcoalDark)),
          ],
        ),
      ],
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    if (status == 'Upcoming') {
      color = Colors.orange;
    } else if (status == 'Pending') {
      color = Colors.amber.shade700;
    } else if (status == 'Completed') {
      color = AppColors.deepTeal;
    } else {
      color = Colors.red;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
      child: Text(status, style: GoogleFonts.nunito(color: color, fontSize: 11, fontWeight: FontWeight.w800)),
    );
  }

  Widget _buildInfoRow(IconData icon, String text, bool isDark) {
    return Row(
      children: [
        Icon(icon, size: 16, color: isDark ? Colors.white54 : AppColors.mutedGray),
        const SizedBox(width: 6),
        Text(text, style: GoogleFonts.nunito(color: isDark ? Colors.white70 : AppColors.charcoalDark, fontSize: 13, fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.calendar_today_outlined, size: 80, color: AppColors.deepTeal),
          const SizedBox(height: 24),
          Text(
            widget.isProvider ? 'No ${_selectedTab} Jobs' : 'No ${_selectedTab} Bookings', 
            style: GoogleFonts.nunito(fontSize: 20, fontWeight: FontWeight.w900, color: isDark ? Colors.white : AppColors.charcoalDark),
          ),
          const SizedBox(height: 12),
          Text(
            widget.isProvider 
                ? 'You don\'t have any ${_selectedTab.toLowerCase()} jobs in your record.'
                : 'You don\'t have any ${_selectedTab.toLowerCase()} bookings.', 
            style: GoogleFonts.nunito(color: isDark ? Colors.white70 : AppColors.mutedGray, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
