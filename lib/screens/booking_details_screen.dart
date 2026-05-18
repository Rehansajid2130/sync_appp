import 'dart:io';
import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../models/service_provider.dart';
import 'booking_summary_screen.dart';

class BookingDetailsScreen extends StatefulWidget {
  final ServiceProvider provider;
  final DateTime date;
  final String time;
  final String description;
  final List<String> imagePaths;

  const BookingDetailsScreen({
    super.key,
    required this.provider,
    required this.date,
    required this.time,
    required this.description,
    required this.imagePaths,
  });

  @override
  State<BookingDetailsScreen> createState() => _BookingDetailsScreenState();
}

class _BookingDetailsScreenState extends State<BookingDetailsScreen> {
  String _selectedAddress = 'My Home';

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
        title: Text('Booking Details', style: TextStyle(color: isDark ? Colors.white : Colors.black, fontWeight: FontWeight.w700)),
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
                  Text('Select Address', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: isDark ? Colors.white : Colors.black)),
                  const SizedBox(height: 16),
                  _buildAddressCard('My Home', 'Komplek Situ Udik, Jl. Raya Dramaga Jawa Barat 16310', isDark),
                  const SizedBox(height: 16),
                  _buildAddressCard('Apartment', 'Jl. Kebon Jeruk No. 12, Jakarta Barat 11530', isDark),
                  const SizedBox(height: 32),
                  if (widget.description.isNotEmpty) ...[
                    Text('Service Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: isDark ? Colors.white : Colors.black)),
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF161616) : const Color(0xFFF1F4F8),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: isDark ? Colors.white10 : Colors.black.withOpacity(0.05)),
                      ),
                      child: Text(
                        widget.description,
                        style: TextStyle(color: isDark ? Colors.white : Colors.black, height: 1.5),
                      ),
                    ),
                    if (widget.imagePaths.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: widget.imagePaths.map((path) => Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF262626) : Colors.grey[300],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          clipBehavior: Clip.hardEdge,
                          child: Image.file(File(path), fit: BoxFit.cover),
                        )).toList(),
                      ),
                    ],
                  ],
                ],
              ),
            ),
          ),
          _buildBottomBar(isDark),
        ],
      ),
    );
  }

  Widget _buildAddressCard(String title, String address, bool isDark) {
    final isSelected = _selectedAddress == title;
    return GestureDetector(
      onTap: () => setState(() => _selectedAddress = title),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected 
              ? (isDark ? const Color(0xFF1E3A1E) : const Color(0xFFE8F5E9))
              : (isDark ? const Color(0xFF161616) : Colors.white),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected ? AppColors.primary : (isDark ? Colors.white10 : Colors.black.withOpacity(0.05)),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: isDark ? const Color(0xFF262626) : const Color(0xFFF1F4F8), shape: BoxShape.circle),
              child: Icon(Icons.location_on_outlined, color: isDark ? Colors.white : Colors.black, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: isDark ? Colors.white : Colors.black)),
                  const SizedBox(height: 4),
                  Text(address, style: TextStyle(color: isDark ? Colors.white70 : Colors.grey, fontSize: 12)),
                ],
              ),
            ),
            if (isSelected) const Icon(Icons.check_circle, color: AppColors.primary),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar(bool isDark) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF161616) : Colors.white,
        border: Border(top: BorderSide(color: isDark ? Colors.white10 : Colors.black.withOpacity(0.05))),
      ),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => BookingSummaryScreen(
                  provider: widget.provider,
                  date: widget.date,
                  time: widget.time,
                  address: _selectedAddress,
                  description: widget.description,
                  imagePaths: widget.imagePaths,
                ),
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
          ),
          child: const Text('Next', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16)),
        ),
      ),
    );
  }
}
