import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme/app_colors.dart';
import '../models/service_provider.dart';
import '../core/data/mock_data.dart';
import 'booking_success_screen.dart';

class BookingDateScreen extends StatefulWidget {
  final ServiceProvider provider;
  const BookingDateScreen({super.key, required this.provider});

  @override
  State<BookingDateScreen> createState() => _BookingDateScreenState();
}

class _BookingDateScreenState extends State<BookingDateScreen> {
  DateTime _selectedDate = DateTime.now();
  String? _selectedTime;
  bool _isLoading = false;

  final List<String> _morningSlots = ['08:00 AM', '09:00 AM', '10:00 AM', '11:00 AM'];
  final List<String> _afternoonSlots = ['01:00 PM', '02:00 PM', '03:00 PM', '04:00 PM'];
  final List<String> _eveningSlots = ['06:00 PM', '07:00 PM', '08:00 PM'];

  final TextEditingController _detailsController = TextEditingController();
  final List<String> _selectedImages = [];
  final ImagePicker _picker = ImagePicker();

  late List<String> _availableSlots;

  @override
  void initState() {
    super.initState();
    _availableSlots = widget.provider.availableTimes.isNotEmpty
        ? widget.provider.availableTimes
        : [..._morningSlots, ..._afternoonSlots, ..._eveningSlots];
    
    if (_availableSlots.isNotEmpty) {
      _selectedTime = _availableSlots[0];
    }
  }

  Future<void> _pickImage() async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF161616) : Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Add Job Photo",
              style: GoogleFonts.nunito(fontSize: 22, fontWeight: FontWeight.w900, color: isDark ? Colors.white : AppColors.charcoalDark),
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildImageSourceOption(
                  icon: Icons.camera_alt_rounded,
                  label: "Camera",
                  onTap: () async {
                    Navigator.pop(context);
                    final XFile? image = await _picker.pickImage(source: ImageSource.camera);
                    if (image != null) setState(() => _selectedImages.add(image.path));
                  },
                  isDark: isDark,
                ),
                _buildImageSourceOption(
                  icon: Icons.photo_library_rounded,
                  label: "Gallery",
                  onTap: () async {
                    Navigator.pop(context);
                    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
                    if (image != null) setState(() => _selectedImages.add(image.path));
                  },
                  isDark: isDark,
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSourceOption({required IconData icon, required String label, required VoidCallback onTap, required bool isDark}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.deepTeal.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.deepTeal, size: 32),
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: GoogleFonts.nunito(fontWeight: FontWeight.w800, color: isDark ? Colors.white70 : AppColors.mutedGray),
          ),
        ],
      ),
    );
  }

  void _sendBookingRequest() async {
    if (_selectedTime == null) return;
    
    setState(() => _isLoading = true);
    
    await Future.delayed(const Duration(milliseconds: 800));
    
    final booking = Booking(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      serviceName: widget.provider.category,
      providerName: widget.provider.name,
      clientName: MockData.currentUserName,
      status: 'Pending',
      date: _selectedDate,
      time: _selectedTime!,
      icon: widget.provider.icon,
      description: _detailsController.text,
      imagePaths: _selectedImages,
    );
    
    try {
      await MockData.addBooking(booking);
      
      if (!mounted) return;
      setState(() => _isLoading = false);
      
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => const BookingSuccessScreen(isPending: true),
        ),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      
      showDialog(
        context: context,
        builder: (context) {
          final isDark = Theme.of(context).brightness == Brightness.dark;
          return Dialog(
            backgroundColor: isDark ? const Color(0xFF161616) : Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.08),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.error_outline_rounded, color: Colors.red, size: 40),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Scheduling Conflict',
                    style: GoogleFonts.nunito(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: isDark ? Colors.white : AppColors.charcoalDark,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    e.toString().replaceAll("Exception: ", ""),
                    style: GoogleFonts.nunito(
                      color: isDark ? Colors.white70 : AppColors.mutedGray,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.deepTeal,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                      ),
                      child: Text(
                        'Change Time',
                        style: GoogleFonts.nunito(fontWeight: FontWeight.w800, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.offWhite,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF161616) : Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  if (!isDark)
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                ],
              ),
              child: Icon(Icons.arrow_back_ios_new_rounded, color: isDark ? Colors.white : AppColors.charcoalDark, size: 16),
            ),
          ),
        ),
        title: Text(
          'Book Service',
          style: GoogleFonts.nunito(
            color: isDark ? Colors.white : AppColors.charcoalDark,
            fontWeight: FontWeight.w900,
            fontSize: 20,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Preferred Date', 
                    style: GoogleFonts.nunito(fontSize: 18, fontWeight: FontWeight.w900, color: isDark ? Colors.white : AppColors.charcoalDark)
                  ),
                  const SizedBox(height: 20),
                  _buildDateStrip(isDark),
                  const SizedBox(height: 36),
                  Text(
                    'Select Time Slot', 
                    style: GoogleFonts.nunito(fontSize: 18, fontWeight: FontWeight.w900, color: isDark ? Colors.white : AppColors.charcoalDark)
                  ),
                  const SizedBox(height: 20),
                  _buildTimeWheel(isDark),
                  const SizedBox(height: 36),
                  Text(
                    'Work Description', 
                    style: GoogleFonts.nunito(fontSize: 18, fontWeight: FontWeight.w900, color: isDark ? Colors.white : AppColors.charcoalDark)
                  ),
                  const SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF111111) : Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.04)),
                      boxShadow: [
                        if (!isDark)
                          BoxShadow(
                            color: Colors.black.withOpacity(0.02),
                            blurRadius: 15,
                            offset: const Offset(0, 8),
                          ),
                      ],
                    ),
                    child: TextField(
                      controller: _detailsController,
                      maxLines: 4,
                      style: GoogleFonts.nunito(color: isDark ? Colors.white : AppColors.charcoalDark, fontWeight: FontWeight.w600),
                      decoration: InputDecoration(
                        hintText: 'Describe the job details or special requests...',
                        hintStyle: GoogleFonts.nunito(color: isDark ? Colors.white24 : AppColors.mutedGray, fontSize: 15),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.all(20),
                      ),
                    ),
                  ),
                  const SizedBox(height: 36),
                  Text(
                    'Job Site Photos', 
                    style: GoogleFonts.nunito(fontSize: 18, fontWeight: FontWeight.w900, color: isDark ? Colors.white : AppColors.charcoalDark)
                  ),
                  const SizedBox(height: 16),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: _pickImage,
                          child: Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF111111) : Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: AppColors.deepTeal.withOpacity(0.3), width: 2, style: BorderStyle.solid),
                            ),
                            child: const Icon(Icons.add_a_photo_rounded, color: AppColors.deepTeal),
                          ),
                        ),
                        const SizedBox(width: 12),
                        ..._selectedImages.map((path) => Container(
                          width: 80,
                          height: 80,
                          margin: const EdgeInsets.only(right: 12),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            image: DecorationImage(image: FileImage(File(path)), fit: BoxFit.cover),
                          ),
                          child: Stack(
                            children: [
                              Positioned(
                                top: 4,
                                right: 4,
                                child: GestureDetector(
                                  onTap: () => setState(() => _selectedImages.remove(path)),
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                                    child: const Icon(Icons.close_rounded, color: Colors.white, size: 14),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
          _buildBottomBar(isDark),
        ],
      ),
    );
  }

  Widget _buildDateStrip(bool isDark) {
    return SizedBox(
      height: 90,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: 14,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final date = DateTime.now().add(Duration(days: index));
          final isSelected = date.day == _selectedDate.day && date.month == _selectedDate.month;
          return GestureDetector(
            onTap: () => setState(() => _selectedDate = date),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 65,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.deepTeal : (isDark ? const Color(0xFF111111) : Colors.white),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  if (isSelected)
                    BoxShadow(color: AppColors.deepTeal.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5)),
                  if (!isSelected && !isDark)
                    BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 5, offset: const Offset(0, 2)),
                ],
                border: Border.all(
                  color: isSelected ? AppColors.deepTeal : (isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.03)),
                  width: 1.5,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(_getDayName(date.weekday).substring(0, 3), style: GoogleFonts.nunito(color: isSelected ? Colors.white70 : AppColors.mutedGray, fontSize: 12, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Text(date.day.toString(), style: GoogleFonts.nunito(color: isSelected ? Colors.white : (isDark ? Colors.white : AppColors.charcoalDark), fontSize: 20, fontWeight: FontWeight.w900)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTimeWheel(bool isDark) {
    return Container(
      height: 160,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF111111) : Colors.white,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.03)),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            height: 48,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: AppColors.deepTeal.withOpacity(0.08),
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          ListWheelScrollView.useDelegate(
            itemExtent: 44,
            perspective: 0.003,
            diameterRatio: 1.2,
            useMagnifier: true,
            magnification: 1.25,
            physics: const FixedExtentScrollPhysics(),
            onSelectedItemChanged: (index) {
              setState(() => _selectedTime = _availableSlots[index]);
            },
            childDelegate: ListWheelChildBuilderDelegate(
              childCount: _availableSlots.length,
              builder: (context, index) {
                final slot = _availableSlots[index];
                final isSelected = _selectedTime == slot;
                return Center(
                  child: Text(
                    slot,
                    style: GoogleFonts.nunito(
                      fontSize: 16,
                      fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
                      color: isSelected 
                          ? AppColors.deepTeal 
                          : (isDark ? Colors.white38 : AppColors.mutedGray),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(bool isDark) {
    return Container(
      padding: const EdgeInsets.fromLTRB(28, 16, 28, 40),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF111111) : Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, -10)),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        height: 58,
        child: ElevatedButton(
          onPressed: (_selectedTime == null || _isLoading) ? null : _sendBookingRequest,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.deepTeal,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
          ),
          child: _isLoading
              ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
              : Text(
                  'Confirm Booking',
                  style: GoogleFonts.nunito(fontWeight: FontWeight.w900, fontSize: 18),
                ),
        ),
      ),
    );
  }

  String _getDayName(int weekday) {
    const names = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    return names[weekday - 1];
  }
}
