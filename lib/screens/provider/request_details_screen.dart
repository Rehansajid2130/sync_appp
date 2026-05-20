import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../core/theme/app_colors.dart';
import '../../core/data/mock_data.dart';
import '../../core/services/map_service.dart';
import 'package:url_launcher/url_launcher.dart';

class RequestDetailsScreen extends StatefulWidget {
  final Booking booking;
  const RequestDetailsScreen({super.key, required this.booking});

  @override
  State<RequestDetailsScreen> createState() => _RequestDetailsScreenState();
}

class _RequestDetailsScreenState extends State<RequestDetailsScreen> {
  final List<Map<String, dynamic>> _checklistItems = [];
  bool _isLoading = false;
  LatLng _mapCenter = const LatLng(31.4826, 74.3973); // Lahore
  bool _isGeocoding = false;

  @override
  void initState() {
    super.initState();
    _generateContextualDetails();
    _geocodeAddress();
  }

  Future<void> _geocodeAddress() async {
    setState(() => _isGeocoding = true);
    final results = await MapService.searchPlaces('DHA Phase 6, Lahore');
    if (results.isNotEmpty) {
      setState(() {
        _mapCenter = LatLng(results.first.latitude, results.first.longitude);
        _isGeocoding = false;
      });
    } else {
      setState(() => _isGeocoding = false);
    }
  }

  void _generateContextualDetails() {
    final service = widget.booking.serviceName.toLowerCase();
    if (service.contains('clean')) {
      _checklistItems.addAll([
        {'name': 'Heavy-duty carpet shampoo & vacuum', 'checked': true},
        {'name': 'Fabric stain spot-remover spray', 'checked': true},
        {'name': 'Microfiber scrubbers & clean towels', 'checked': false},
        {'name': 'Lavender deodorizing spray', 'checked': false},
      ]);
    } else if (service.contains('repair') || service.contains('appliance') || service.contains('ac')) {
      _checklistItems.addAll([
        {'name': 'Multifunctional digital multimeter', 'checked': true},
        {'name': 'Refrigerant pressure gauge manifold', 'checked': true},
        {'name': 'R-410A Freon gas canister (2kg)', 'checked': false},
        {'name': 'Replacement start capacitor (45 uF)', 'checked': false},
      ]);
    } else if (service.contains('plumb')) {
      _checklistItems.addAll([
        {'name': 'Heavy-duty sink plunger & hand snake', 'checked': true},
        {'name': 'Biodegradable drain opening solution', 'checked': true},
        {'name': 'Adjustable wrench & sealing Teflon tape', 'checked': false},
        {'name': 'Replacement PVC trap joint pipe', 'checked': false},
      ]);
    } else if (service.contains('paint')) {
      _checklistItems.addAll([
        {'name': 'Premium matte interior paint (1 gallon)', 'checked': true},
        {'name': '3-inch synthetic paint brushes', 'checked': true},
        {'name': 'Microfiber 9-inch paint roller & tray', 'checked': false},
        {'name': "Drop cloths & painter's masking tape", 'checked': false},
      ]);
    } else {
      _checklistItems.addAll([
        {'name': 'Professional hand toolkit (screwdrivers, leveler)', 'checked': true},
        {'name': 'Assorted dry-wall anchors and screws', 'checked': true},
        {'name': 'Electric wire stripper & insulation tape', 'checked': false},
        {'name': 'Retractable metal measuring tape (5m)', 'checked': false},
      ]);
    }
  }

  String _getProblemDescription() {
    if (widget.booking.description.isNotEmpty) return widget.booking.description;
    final service = widget.booking.serviceName.toLowerCase();
    if (service.contains('clean')) return 'Need an urgent deep clean of the living room and master bedroom. The main focus should be on the fabric sofa and the high-traffic carpet area which has deep mud stains from recent rains.';
    if (service.contains('repair') || service.contains('ac')) return 'AC is running but not blowing cold air. It makes a clicking sound every few minutes. Filters are clean, might be a condenser or start capacitor issue.';
    if (service.contains('plumb')) return 'The bathroom sink drain is completely clogged and overflowing. Sink stopper seems stuck too. Need a quick fix and pipe inspection.';
    if (service.contains('paint')) return "Need to paint an accent wall in the kid's bedroom with non-toxic premium matte paint. Wall size is roughly 12x10 ft. Standard masking is required.";
    return 'General maintenance work requested. Require assistance fixing minor fixtures, shelving units, and checking loose door hinges.';
  }

  Future<void> _launchMaps() async {
    const String address = 'DHA Phase 6, Lahore, Pakistan';
    final Uri url = Uri.parse('https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(address)}');
    try {
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not open map navigation.')));
      }
    } catch (_) {}
  }

  void _handleAction(String action) async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 800));
    final newStatus = action == 'Accept' ? 'Upcoming' : 'Declined';
    await MockData.updateBookingStatus(widget.booking.id, newStatus);
    if (mounted) {
      setState(() => _isLoading = false);
      if (action == 'Accept') {
        _showSuccessDialog();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Job request has been declined.', style: GoogleFonts.nunito(color: Colors.white, fontWeight: FontWeight.w700)),
            backgroundColor: Colors.red.shade400,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
        );
        Navigator.pop(context, true);
      }
    }
  }

  void _showSuccessDialog() {
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
                decoration: BoxDecoration(color: AppColors.deepTeal.withOpacity(0.12), shape: BoxShape.circle),
                child: const Icon(Icons.check_rounded, color: AppColors.deepTeal, size: 48),
              ),
              const SizedBox(height: 24),
              Text('Job Accepted!', style: GoogleFonts.nunito(fontSize: 22, fontWeight: FontWeight.w900, color: isDark ? Colors.white : AppColors.charcoalDark)),
              const SizedBox(height: 10),
              Text(
                'This job has been added to your schedule. The client has been notified.',
                textAlign: TextAlign.center,
                style: GoogleFonts.nunito(color: AppColors.mutedGray, height: 1.5, fontSize: 13, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pop(context, true);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.deepTeal,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  ),
                  child: Text('Back to Dashboard', style: GoogleFonts.nunito(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 15)),
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
            // Header
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
                        border: Border.all(color: isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.06)),
                      ),
                      child: Icon(Icons.arrow_back_rounded, color: isDark ? Colors.white : AppColors.charcoalDark, size: 20),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Text('Request Details', style: GoogleFonts.nunito(fontSize: 18, fontWeight: FontWeight.w900, color: isDark ? Colors.white : AppColors.charcoalDark)),
                ],
              ),
            ),
            // Body
            Expanded(
              child: _isLoading
                  ? Center(child: CircularProgressIndicator(color: AppColors.deepTeal, strokeWidth: 2.5))
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 8),
                          _buildHeaderCard(isDark),
                          const SizedBox(height: 16),
                          _buildDescriptionCard(isDark),
                          const SizedBox(height: 16),
                          _buildPhotosSection(isDark),
                          const SizedBox(height: 16),
                          _buildLocationCard(isDark),
                          const SizedBox(height: 16),
                          _buildAIRequirementsCard(isDark),
                          const SizedBox(height: 120),
                        ],
                      ),
                    ),
            ),
            _buildBottomCTA(isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF161616) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isDark ? Colors.white.withOpacity(0.06) : Colors.black.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(color: AppColors.deepTeal.withOpacity(0.1), borderRadius: BorderRadius.circular(16)),
            child: Icon(widget.booking.icon, color: AppColors.deepTeal, size: 26),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.booking.serviceName, style: GoogleFonts.nunito(fontWeight: FontWeight.w900, fontSize: 16, color: isDark ? Colors.white : AppColors.charcoalDark)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.person_outline_rounded, size: 13, color: AppColors.mutedGray),
                    const SizedBox(width: 4),
                    Text('Client: ${widget.booking.clientName}', style: GoogleFonts.nunito(color: AppColors.mutedGray, fontSize: 12, fontWeight: FontWeight.w600)),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _buildBadge(Icons.calendar_today_rounded, 'Today', isDark),
                    const SizedBox(width: 8),
                    _buildBadge(Icons.access_time_rounded, widget.booking.time, isDark),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(IconData icon, String text, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF262626) : AppColors.surfaceLightGray,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(icon, size: 11, color: AppColors.deepTeal),
          const SizedBox(width: 4),
          Text(text, style: GoogleFonts.nunito(color: isDark ? Colors.white70 : AppColors.charcoalDark, fontSize: 11, fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }

  Widget _buildDescriptionCard(bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF161616) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isDark ? Colors.white.withOpacity(0.06) : Colors.black.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Job Description', style: GoogleFonts.nunito(fontWeight: FontWeight.w900, fontSize: 15, color: isDark ? Colors.white : AppColors.charcoalDark)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(color: AppColors.deepTeal.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                child: Row(
                  children: [
                    const Icon(Icons.psychology_rounded, size: 11, color: AppColors.deepTeal),
                    const SizedBox(width: 4),
                    Text('AI Analyzed', style: GoogleFonts.nunito(color: AppColors.deepTeal, fontWeight: FontWeight.w800, fontSize: 10)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            _getProblemDescription(),
            style: GoogleFonts.nunito(fontSize: 13, color: isDark ? Colors.white70 : AppColors.mutedGray, height: 1.6, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotosSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Attached Photos', style: GoogleFonts.nunito(fontWeight: FontWeight.w900, fontSize: 15, color: isDark ? Colors.white : AppColors.charcoalDark)),
        const SizedBox(height: 12),
        widget.booking.imagePaths.isNotEmpty
            ? Wrap(
                spacing: 12,
                runSpacing: 12,
                children: widget.booking.imagePaths
                    .map((path) => ClipRRect(
                          borderRadius: BorderRadius.circular(18),
                          child: Image.file(File(path), height: 100, width: 100, fit: BoxFit.cover),
                        ))
                    .toList(),
              )
            : Row(
                children: [
                  Expanded(child: _buildPhotoPlaceholder(isDark, Icons.image_outlined, 'Overview', AppColors.pastelPink, const Color(0xFFC44B3A))),
                  const SizedBox(width: 12),
                  Expanded(child: _buildPhotoPlaceholder(isDark, Icons.zoom_in_rounded, 'Detail Zoom', AppColors.pastelBlue, AppColors.deepTeal)),
                ],
              ),
      ],
    );
  }

  Widget _buildPhotoPlaceholder(bool isDark, IconData icon, String label, Color bg, Color iconColor) {
    return Container(
      height: 110,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF161616) : bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? Colors.white.withOpacity(0.06) : Colors.transparent),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: iconColor.withOpacity(0.15), shape: BoxShape.circle),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(height: 8),
          Text(label, style: GoogleFonts.nunito(fontWeight: FontWeight.w700, fontSize: 11, color: AppColors.mutedGray)),
        ],
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
        border: Border.all(color: isDark ? Colors.white.withOpacity(0.06) : Colors.black.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Exact Location', style: GoogleFonts.nunito(fontWeight: FontWeight.w900, fontSize: 15, color: isDark ? Colors.white : AppColors.charcoalDark)),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: SizedBox(
              height: 140,
              child: Stack(
                children: [
                  FlutterMap(
                    options: MapOptions(initialCenter: _mapCenter, initialZoom: 14.0),
                    children: [
                      TileLayer(
                        urlTemplate: isDark
                            ? 'https://a.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}.png'
                            : 'https://a.basemaps.cartocdn.com/light_all/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.helperhive.app',
                      ),
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: _mapCenter,
                            width: 50,
                            height: 50,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(color: AppColors.deepTeal.withOpacity(0.2), shape: BoxShape.circle),
                                ),
                                const Icon(Icons.location_on_rounded, color: AppColors.deepTeal, size: 28),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  if (_isGeocoding)
                    Positioned.fill(
                      child: Container(
                        color: Colors.black26,
                        child: Center(child: CircularProgressIndicator(color: AppColors.deepTeal, strokeWidth: 2)),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              const Icon(Icons.navigation_rounded, color: AppColors.deepTeal, size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(address, style: GoogleFonts.nunito(fontSize: 13, color: isDark ? Colors.white70 : AppColors.mutedGray, fontWeight: FontWeight.w700)),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _launchMaps,
              icon: const Icon(Icons.near_me_rounded, size: 15),
              label: Text('Open Navigation', style: GoogleFonts.nunito(fontWeight: FontWeight.w800, fontSize: 13)),
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

  Widget _buildAIRequirementsCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF161616) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isDark ? Colors.white.withOpacity(0.06) : Colors.black.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(color: AppColors.deepTeal.withOpacity(0.1), shape: BoxShape.circle),
                child: const Icon(Icons.auto_awesome_rounded, color: AppColors.deepTeal, size: 15),
              ),
              const SizedBox(width: 10),
              Text('AI-Predicted Tool Checklist', style: GoogleFonts.nunito(fontWeight: FontWeight.w900, fontSize: 14, color: isDark ? Colors.white : AppColors.charcoalDark)),
            ],
          ),
          const SizedBox(height: 6),
          Text('Bring these suggested items for maximum efficiency.', style: GoogleFonts.nunito(color: AppColors.mutedGray, fontSize: 12, fontWeight: FontWeight.w600)),
          const SizedBox(height: 16),
          ..._checklistItems.map((item) => _buildChecklistItem(item, isDark)),
        ],
      ),
    );
  }

  Widget _buildChecklistItem(Map<String, dynamic> item, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () => setState(() => item['checked'] = !item['checked']),
        borderRadius: BorderRadius.circular(12),
        child: Row(
          children: [
            GestureDetector(
              onTap: () => setState(() => item['checked'] = !item['checked']),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: item['checked'] ? AppColors.deepTeal : Colors.transparent,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: item['checked'] ? AppColors.deepTeal : AppColors.mutedGray.withOpacity(0.4)),
                ),
                child: item['checked'] ? const Icon(Icons.check_rounded, color: Colors.white, size: 14) : null,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                item['name'],
                style: GoogleFonts.nunito(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  color: item['checked']
                      ? AppColors.mutedGray
                      : (isDark ? Colors.white : AppColors.charcoalDark),
                  decoration: item['checked'] ? TextDecoration.lineThrough : null,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomCTA(bool isDark) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 36),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF121211) : Colors.white,
        border: Border(top: BorderSide(color: isDark ? Colors.white.withOpacity(0.06) : Colors.black.withOpacity(0.05))),
      ),
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 52,
              child: OutlinedButton(
                onPressed: () => _handleAction('Decline'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red.shade400,
                  side: BorderSide(color: Colors.red.shade200),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                ),
                child: Text('Decline', style: GoogleFonts.nunito(fontWeight: FontWeight.w800, fontSize: 14)),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: () => _handleAction('Accept'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.deepTeal,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                ),
                child: Text('Accept Request', style: GoogleFonts.nunito(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 14)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
