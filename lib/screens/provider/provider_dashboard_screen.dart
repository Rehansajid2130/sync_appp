import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../core/data/mock_data.dart';
import '../../core/services/auth_service.dart';
import 'ongoing_job_screen.dart';
import 'request_details_screen.dart';

class ProviderDashboardScreen extends StatefulWidget {
  const ProviderDashboardScreen({super.key});

  @override
  State<ProviderDashboardScreen> createState() => _ProviderDashboardScreenState();
}

class _ProviderDashboardScreenState extends State<ProviderDashboardScreen> {
  bool _isOnline = true;

  void _handleRequest(Booking booking, String action) async {
    final newStatus = action == 'Accept' ? 'Upcoming' : 'Declined';
    await MockData.updateBookingStatus(booking.id, newStatus);
    setState(() {});
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            action == 'Accept' ? 'Job request accepted!' : 'Job request declined.',
            style: GoogleFonts.nunito(fontWeight: FontWeight.w700, color: Colors.white),
          ),
          backgroundColor: action == 'Accept' ? AppColors.deepTeal : Colors.red.shade400,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    final name = AuthService.currentUser?.name ?? MockData.currentUserName;

    // Filter bookings relevant to this provider
    final myBookings = MockData.bookings.where((b) => b.providerName == name).toList();
    
    final pendingRequests = myBookings.where((b) => b.status == 'Pending').toList();
    final upcomingJobs = myBookings.where((b) => b.status == 'Upcoming').toList();
    final completedJobs = myBookings.where((b) => b.status == 'Completed').toList();
    
    final nextJob = upcomingJobs.isNotEmpty ? upcomingJobs.first : null;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF090909) : const Color(0xFFF9F9FB),
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: () async => setState(() {}),
          color: AppColors.deepTeal,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(isDark, name),
                const SizedBox(height: 24),
                _buildStatsRow(isDark, pendingRequests.length, upcomingJobs.length, completedJobs.length),
                if (pendingRequests.isNotEmpty) ...[
                  const SizedBox(height: 32),
                  _buildSectionHeader('New Job Requests', '${pendingRequests.length} New', isDark),
                  const SizedBox(height: 14),
                  ...pendingRequests.map((req) => _buildRequestCard(req, isDark)),
                ],
                const SizedBox(height: 32),
                if (nextJob != null)
                  _buildNextJobCard(nextJob, isDark)
                else
                  _buildEmptyUpcoming(isDark),
                const SizedBox(height: 32),
                _buildSectionHeader('Today\'s Schedule', '${upcomingJobs.length} Left', isDark),
                const SizedBox(height: 14),
                _buildScheduleList(upcomingJobs, isDark),
                const SizedBox(height: 32),
                _buildSectionHeader('Recent History', 'View All', isDark),
                const SizedBox(height: 14),
                _buildHistoryList(completedJobs, isDark),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDark, String name) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: AppColors.deepTeal,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: AppColors.deepTeal.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 4)),
                ],
              ),
              child: const Icon(Icons.person_rounded, color: Colors.white, size: 26),
            ),
            const SizedBox(width: 14),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Provider Mode',
                  style: GoogleFonts.nunito(
                    color: AppColors.deepTeal,
                    fontWeight: FontWeight.w800,
                    fontSize: 11,
                    letterSpacing: 0.5,
                  ),
                ),
                Text(
                  name,
                  style: GoogleFonts.nunito(
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                    color: isDark ? Colors.white : AppColors.charcoalDark,
                  ),
                ),
              ],
            ),
          ],
        ),
        _buildStatusToggle(isDark),
      ],
    );
  }

  Widget _buildStatusToggle(bool isDark) {
    return GestureDetector(
      onTap: () => setState(() => _isOnline = !_isOnline),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: _isOnline
              ? AppColors.deepTeal.withOpacity(isDark ? 0.2 : 0.1)
              : (isDark ? const Color(0xFF1E1E1E) : AppColors.surfaceLightGray),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: _isOnline ? AppColors.deepTeal : (isDark ? Colors.white12 : Colors.black.withOpacity(0.08)),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _isOnline ? AppColors.deepTeal : AppColors.mutedGray,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              _isOnline ? 'Online' : 'Offline',
              style: GoogleFonts.nunito(
                color: _isOnline ? AppColors.deepTeal : AppColors.mutedGray,
                fontWeight: FontWeight.w800,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsRow(bool isDark, int pending, int upcoming, int completed) {
    return Row(
      children: [
        _buildStatCard('Pending', pending.toString(), Icons.pending_actions_rounded, AppColors.pastelYellow, const Color(0xFF9E7C00), isDark),
        const SizedBox(width: 12),
        _buildStatCard('Upcoming', upcoming.toString(), Icons.schedule_rounded, AppColors.pastelBlue, AppColors.deepTeal, isDark),
        const SizedBox(width: 12),
        _buildStatCard('Completed', completed.toString(), Icons.task_alt_rounded, AppColors.pastelGreen, const Color(0xFF1A6B3C), isDark),
      ],
    );
  }

  Widget _buildStatCard(String label, String count, IconData icon, Color bgColor, Color iconColor, bool isDark) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF161616) : bgColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark ? Colors.white.withOpacity(0.06) : Colors.transparent,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: iconColor, size: 22),
            const SizedBox(height: 10),
            Text(
              count,
              style: GoogleFonts.nunito(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: isDark ? Colors.white : iconColor,
              ),
            ),
            Text(
              label,
              style: GoogleFonts.nunito(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white54 : iconColor.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRequestCard(Booking job, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF161616) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.06) : AppColors.deepTeal.withOpacity(0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.12 : 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => RequestDetailsScreen(booking: job)),
              ).then((shouldRefresh) {
                if (shouldRefresh == true) setState(() {});
              });
            },
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: AppColors.deepTeal.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(job.icon, color: AppColors.deepTeal, size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        job.serviceName,
                        style: GoogleFonts.nunito(
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                          color: isDark ? Colors.white : AppColors.charcoalDark,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'Client: ${job.clientName}',
                        style: GoogleFonts.nunito(
                          color: AppColors.mutedGray,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.deepTeal.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    job.time,
                    style: GoogleFonts.nunito(
                      color: AppColors.deepTeal,
                      fontWeight: FontWeight.w800,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _handleRequest(job, 'Decline'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red.shade400,
                    side: BorderSide(color: Colors.red.shade200),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Text(
                    'Decline',
                    style: GoogleFonts.nunito(fontWeight: FontWeight.w800, fontSize: 13),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _handleRequest(job, 'Accept'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.deepTeal,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Text(
                    'Accept',
                    style: GoogleFonts.nunito(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNextJobCard(Booking job, bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.charcoalDark,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: AppColors.charcoalDark.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'NEXT UPCOMING JOB',
                style: GoogleFonts.nunito(
                  color: Colors.white38,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'Today',
                  style: GoogleFonts.nunito(
                    color: Colors.white70,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            job.serviceName,
            style: GoogleFonts.nunito(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.location_on_rounded, color: Colors.white38, size: 14),
              const SizedBox(width: 4),
              Text(
                'DHA Phase 6, Lahore, Pakistan',
                style: GoogleFonts.nunito(color: Colors.white54, fontSize: 13, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.person_rounded, size: 20, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      job.clientName,
                      style: GoogleFonts.nunito(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      'Client',
                      style: GoogleFonts.nunito(color: Colors.white38, fontSize: 11, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => OngoingJobScreen(booking: job)),
                  ).then((_) => setState(() {}));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppColors.charcoalDark,
                  elevation: 0,
                  minimumSize: const Size(96, 40),
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
                child: Text(
                  'Start Job',
                  style: GoogleFonts.nunito(fontWeight: FontWeight.w900, fontSize: 13),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyUpcoming(bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF161616) : Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.06) : Colors.black.withOpacity(0.04),
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.deepTeal.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check_circle_outline_rounded, color: AppColors.deepTeal, size: 40),
          ),
          const SizedBox(height: 16),
          Text(
            'No Active Jobs',
            style: GoogleFonts.nunito(
              fontSize: 17,
              fontWeight: FontWeight.w900,
              color: isDark ? Colors.white : AppColors.charcoalDark,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Accept a new request to get started!',
            style: GoogleFonts.nunito(
              color: AppColors.mutedGray,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, String action, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: GoogleFonts.nunito(
            fontSize: 17,
            fontWeight: FontWeight.w900,
            color: isDark ? Colors.white : AppColors.charcoalDark,
          ),
        ),
        Text(
          action,
          style: GoogleFonts.nunito(
            color: AppColors.deepTeal,
            fontWeight: FontWeight.w800,
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  Widget _buildScheduleList(List<Booking> jobs, bool isDark) {
    if (jobs.isEmpty) {
      return Text(
        'No upcoming jobs today.',
        style: GoogleFonts.nunito(color: AppColors.mutedGray, fontSize: 13, fontWeight: FontWeight.w600),
      );
    }
    return SizedBox(
      height: 130,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: jobs.length,
        separatorBuilder: (_, __) => const SizedBox(width: 14),
        itemBuilder: (context, index) => _buildScheduleCard(jobs[index], isDark),
      ),
    );
  }

  Widget _buildScheduleCard(Booking job, bool isDark) {
    return Container(
      width: 220,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF161616) : Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.06) : Colors.black.withOpacity(0.05),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.deepTeal.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.access_time_rounded, color: AppColors.deepTeal, size: 14),
              ),
              const SizedBox(width: 8),
              Text(
                job.time,
                style: GoogleFonts.nunito(
                  color: AppColors.deepTeal,
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            job.serviceName,
            style: GoogleFonts.nunito(
              fontSize: 14,
              fontWeight: FontWeight.w900,
              color: isDark ? Colors.white : AppColors.charcoalDark,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.location_on_outlined, size: 11, color: AppColors.mutedGray),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  'Lahore, Pakistan',
                  style: GoogleFonts.nunito(
                    color: AppColors.mutedGray,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryList(List<Booking> jobs, bool isDark) {
    if (jobs.isEmpty) {
      return Text(
        'No completed jobs yet.',
        style: GoogleFonts.nunito(color: AppColors.mutedGray, fontSize: 13, fontWeight: FontWeight.w600),
      );
    }
    return Column(
      children: jobs
          .map((job) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildHistoryCard(job, isDark),
              ))
          .toList(),
    );
  }

  Widget _buildHistoryCard(Booking job, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF161616) : Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.06) : Colors.black.withOpacity(0.04),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.pastelGreen,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check_rounded, color: Color(0xFF1A6B3C), size: 18),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  job.serviceName,
                  style: GoogleFonts.nunito(
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                    color: isDark ? Colors.white : AppColors.charcoalDark,
                  ),
                ),
                Text(
                  DateFormat('MMM dd, yyyy').format(job.date),
                  style: GoogleFonts.nunito(color: AppColors.mutedGray, fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: isDark ? AppColors.deepTeal.withOpacity(0.2) : AppColors.deepTeal.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              'Done',
              style: GoogleFonts.nunito(
                color: AppColors.deepTeal,
                fontWeight: FontWeight.w900,
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
