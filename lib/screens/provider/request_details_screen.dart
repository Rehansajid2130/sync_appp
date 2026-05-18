import 'dart:io';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/data/mock_data.dart';
import 'package:url_launcher/url_launcher.dart';

class RequestDetailsScreen extends StatefulWidget {
  final Booking booking;

  const RequestDetailsScreen({super.key, required this.booking});

  @override
  State<RequestDetailsScreen> createState() => _RequestDetailsScreenState();
}

class _RequestDetailsScreenState extends State<RequestDetailsScreen> {
  // Checklist states
  final List<Map<String, dynamic>> _checklistItems = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _generateContextualDetails();
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
        {'name': 'Drop cloths & painter\'s masking tape', 'checked': false},
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
    if (widget.booking.description.isNotEmpty) {
      return widget.booking.description;
    }
    final service = widget.booking.serviceName.toLowerCase();
    if (service.contains('clean')) {
      return "Need an urgent deep clean of the living room and master bedroom. The main focus should be on the fabric sofa and the high-traffic carpet area which has deep mud stains from recent rains.";
    } else if (service.contains('repair') || service.contains('appliance') || service.contains('ac')) {
      return "AC is running but not blowing cold air. It makes a clicking sound every few minutes. Filters are clean, might be a condenser or start capacitor issue.";
    } else if (service.contains('plumb')) {
      return "The bathroom sink drain is completely clogged and overflowing. Sink stopper seems stuck too. Need a quick fix and pipe inspection.";
    } else if (service.contains('paint')) {
      return "Need to paint an accent wall in the kid's bedroom with non-toxic premium matte paint. Wall size is roughly 12x10 ft. Standard masking is required.";
    } else {
      return "General maintenance work requested. Require assistance fixing minor fixtures, shelving units, and checking loose door hinges.";
    }
  }

  Future<void> _launchMaps() async {
    const String address = '24 Baker Street, New York';
    final Uri url = Uri.parse('https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(address)}');
    try {
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not open map navigation.')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error opening Google Maps.')),
        );
      }
    }
  }

  void _handleAction(String action) async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 800)); // Smooth loading simulation
    
    final newStatus = action == 'Accept' ? 'Upcoming' : 'Declined';
    await MockData.updateBookingStatus(widget.booking.id, newStatus);
    
    if (mounted) {
      setState(() => _isLoading = false);
      if (action == 'Accept') {
        _showSuccessDialog();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Job request has been declined.'),
            backgroundColor: Colors.red,
          ),
        );
        Navigator.pop(context, true); // Return to dashboard
      }
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle, color: AppColors.primary, size: 64),
            ),
            const SizedBox(height: 24),
            const Text(
              'Job Accepted!',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 12),
            const Text(
              'This job has been added to your schedule. The client has been notified.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, height: 1.4),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // Close dialog
                  Navigator.pop(context, true); // Return to dashboard with refresh flag
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
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
          icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Request Details',
          style: TextStyle(color: isDark ? Colors.white : Colors.black, fontWeight: FontWeight.w800, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeaderCard(isDark),
                  const SizedBox(height: 24),
                  _buildDescriptionCard(isDark),
                  const SizedBox(height: 24),
                  _buildPhotosSection(isDark),
                  const SizedBox(height: 24),
                  _buildLocationCard(isDark),
                  const SizedBox(height: 24),
                  _buildAIRequirementsCard(isDark),
                  const SizedBox(height: 120), // Padding for sticky bottom CTA
                ],
              ),
            ),
      bottomSheet: _buildBottomCTA(isDark),
    );
  }

  Widget _buildHeaderCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF161616) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isDark ? Colors.white10 : Colors.black.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(widget.booking.icon, color: AppColors.primary, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.booking.serviceName,
                  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.person_outline, size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      'Client: ${widget.booking.clientName}',
                      style: const TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF262626) : const Color(0xFFF1F4F8),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today, size: 12, color: AppColors.primary),
                          const SizedBox(width: 4),
                          Text(
                            'Today',
                            style: TextStyle(
                              color: isDark ? Colors.white : AppColors.textPrimaryLight,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF262626) : const Color(0xFFF1F4F8),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.access_time, size: 12, color: AppColors.primary),
                          const SizedBox(width: 4),
                          Text(
                            widget.booking.time,
                            style: TextStyle(
                              color: isDark ? Colors.white : AppColors.textPrimaryLight,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionCard(bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF161616) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isDark ? Colors.white10 : Colors.black.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Job Description',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.psychology, size: 12, color: AppColors.primary),
                    SizedBox(width: 4),
                    Text(
                      'AI Analyzed',
                      style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 10),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            _getProblemDescription(),
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.white70 : AppColors.textSecondaryLight,
              height: 1.5,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotosSection(bool isDark) {
    if (widget.booking.imagePaths.isNotEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Customer Attached Photos',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: widget.booking.imagePaths.map((path) => Container(
              height: 100,
              width: 100,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF161616) : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: isDark ? Colors.white10 : Colors.black.withOpacity(0.05)),
              ),
              clipBehavior: Clip.hardEdge,
              child: Image.file(File(path), fit: BoxFit.cover),
            )).toList(),
          ),
        ],
      );
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Customer Attached Photos',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildPhotoThumbnail(
                isDark, 
                Icons.broken_image_outlined, 
                'Overview', 
                const Color(0xFFFFECEC),
                const Color(0xFFE57373),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildPhotoThumbnail(
                isDark, 
                Icons.zoom_in_outlined, 
                'Detail Zoom', 
                const Color(0xFFE8F5E9),
                AppColors.primary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPhotoThumbnail(bool isDark, IconData icon, String label, Color bgColor, Color iconColor) {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF161616) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? Colors.white10 : Colors.black.withOpacity(0.05)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: bgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey),
          ),
        ],
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
        border: Border.all(color: isDark ? Colors.white10 : Colors.black.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Exact Location',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 16),
          // Stylized Vector Map Mockup
          Container(
            height: 130,
            width: double.infinity,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF262626) : const Color(0xFFE8F5E9).withOpacity(0.5),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Diagonal mock map paths
                Positioned.fill(
                  child: CustomPaint(
                    painter: _MapGridPainter(isDark: isDark),
                  ),
                ),
                // Ripple effect and pin
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                ),
                const Icon(Icons.location_on, color: AppColors.primary, size: 30),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.navigation_outlined, color: AppColors.primary, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  address,
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.white70 : AppColors.textSecondaryLight,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 46,
            child: OutlinedButton.icon(
              onPressed: _launchMaps,
              icon: const Icon(Icons.near_me_outlined, size: 16),
              label: const Text('Open in Navigation', style: TextStyle(fontWeight: FontWeight.bold)),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary, width: 1.5),
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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF161616) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isDark ? Colors.white10 : Colors.black.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  color: Color(0xFFE8F5E9),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.auto_awesome, color: AppColors.primary, size: 16),
              ),
              const SizedBox(width: 10),
              const Text(
                'AI-Predicted Tool Checklist',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'Bring these suggested items for maximum repair efficiency.',
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
          const SizedBox(height: 16),
          Column(
            children: _checklistItems.map((item) => _buildChecklistItem(item)).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildChecklistItem(Map<String, dynamic> item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: InkWell(
        onTap: () {
          setState(() {
            item['checked'] = !item['checked'];
          });
        },
        borderRadius: BorderRadius.circular(12),
        child: Row(
          children: [
            Checkbox(
              value: item['checked'],
              onChanged: (bool? val) {
                setState(() {
                  item['checked'] = val ?? false;
                });
              },
              activeColor: AppColors.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            ),
            Expanded(
              child: Text(
                item['name'],
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  decoration: item['checked'] ? TextDecoration.lineThrough : null,
                  color: item['checked'] ? Colors.grey : null,
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
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF161616) : Colors.white,
        border: Border(top: BorderSide(color: isDark ? Colors.white10 : Colors.black.withOpacity(0.05))),
      ),
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 52,
              child: TextButton(
                onPressed: () => _handleAction('Decline'),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.red,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                ),
                child: const Text('Decline Request', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: () => _handleAction('Accept'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                ),
                child: const Text(
                  'Accept Request',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 15),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Custom Painter to draw beautiful mock map streets
class _MapGridPainter extends CustomPainter {
  final bool isDark;

  _MapGridPainter({required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = isDark ? Colors.white12 : Colors.black.withOpacity(0.06)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    // Horizontal streets
    canvas.drawLine(Offset(0, size.height * 0.3), Offset(size.width, size.height * 0.4), paint);
    canvas.drawLine(Offset(0, size.height * 0.7), Offset(size.width, size.height * 0.65), paint);

    // Vertical streets
    canvas.drawLine(Offset(size.width * 0.25, 0), Offset(size.width * 0.3, size.height), paint);
    canvas.drawLine(Offset(size.width * 0.7, 0), Offset(size.width * 0.65, size.height), paint);

    // Accent highway path
    final paintAccent = Paint()
      ..color = isDark ? Colors.white24 : Colors.black.withOpacity(0.12)
      ..strokeWidth = 6
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(0, size.height * 0.1), Offset(size.width, size.height * 0.9), paintAccent);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
