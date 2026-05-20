import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../core/data/mock_data.dart';
import '../../models/service_provider.dart';
import '../../core/routes/app_routes.dart';

class NewSearchResultsScreen extends StatefulWidget {
  final String? initialQuery;
  const NewSearchResultsScreen({super.key, this.initialQuery});

  @override
  State<NewSearchResultsScreen> createState() => _NewSearchResultsScreenState();
}

class _NewSearchResultsScreenState extends State<NewSearchResultsScreen> {
  late TextEditingController _searchController;
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    _searchQuery = widget.initialQuery ?? "";
    _searchController = TextEditingController(text: _searchQuery);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _getCategoryImage(String category) {
    switch (category.toLowerCase()) {
      case 'cleaning':
        return 'https://images.unsplash.com/photo-1581578731548-c64695cc6952?auto=format&fit=crop&q=80&w=400';
      case 'plumbing':
        return 'https://images.unsplash.com/photo-1504307651254-35680f356dfd?auto=format&fit=crop&q=80&w=400';
      case 'painting':
        return 'https://images.unsplash.com/photo-1562259949-e8e7689d7828?auto=format&fit=crop&q=80&w=400';
      case 'repairing':
      case 'heating':
      case 'electrical':
      default:
        return 'https://images.unsplash.com/photo-1621905251189-08b45d6a269e?auto=format&fit=crop&q=80&w=400';
    }
  }

  List<ServiceProvider> get _filteredProviders {
    if (_searchQuery.trim().isEmpty) {
      return MockData.providers;
    }
    final q = _searchQuery.toLowerCase();
    return MockData.providers.where((p) {
      return p.name.toLowerCase().contains(q) ||
             p.category.toLowerCase().contains(q) ||
             p.location.toLowerCase().contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final filtered = _filteredProviders;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF090909) : Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // 1. Top Section & Dynamic Search Bar
            Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 8.0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF161616) : AppColors.surfaceLightGray,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.arrow_back_rounded,
                        color: isDark ? Colors.white : AppColors.textDark,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF161616) : AppColors.surfaceLightGray,
                        borderRadius: BorderRadius.circular(24.0),
                        border: Border.all(
                          color: isDark ? Colors.white.withOpacity(0.08) : Colors.transparent,
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          Icon(
                            Icons.search,
                            color: isDark ? Colors.white54 : AppColors.textMutedGray,
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              style: GoogleFonts.nunito(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: isDark ? Colors.white : AppColors.textDark,
                              ),
                              onChanged: (value) {
                                setState(() {
                                  _searchQuery = value;
                                });
                              },
                              decoration: InputDecoration(
                                hintText: "Search service providers...",
                                hintStyle: GoogleFonts.nunito(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: isDark ? Colors.white30 : AppColors.textMutedGray,
                                ),
                                border: InputBorder.none,
                                isDense: true,
                              ),
                            ),
                          ),
                          if (_searchQuery.isNotEmpty)
                            GestureDetector(
                              onTap: () {
                                _searchController.clear();
                                setState(() {
                                  _searchQuery = "";
                                });
                              },
                              child: Icon(
                                Icons.close_rounded,
                                color: isDark ? Colors.white30 : AppColors.textMutedGray,
                                size: 18,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // 2. Counters & Utilities Ribbon
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "${filtered.length} Specialists found",
                    style: GoogleFonts.nunito(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: isDark ? Colors.white : AppColors.textDark,
                    ),
                  ),
                  Row(
                    children: [
                      // Map View Utility
                      GestureDetector(
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Transitioning to high-fidelity map overlays...")),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isDark ? Colors.white.withOpacity(0.04) : AppColors.surfaceLightGray,
                          ),
                          child: Icon(
                            Icons.map_outlined,
                            size: 18,
                            color: isDark ? Colors.white70 : AppColors.textDark,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      // Advanced Sliders Filter Toggle
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isDark ? Colors.white.withOpacity(0.04) : AppColors.surfaceLightGray,
                        ),
                        child: Icon(
                          Icons.tune,
                          size: 18,
                          color: isDark ? AppColors.deepTeal : AppColors.charcoalDark,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // 3. Search Result List View
            Expanded(
              child: filtered.isEmpty
                  ? Center(
                      child: Text(
                        "No service providers found.",
                        style: GoogleFonts.nunito(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textMutedGray,
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4),
                      physics: const BouncingScrollPhysics(),
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final provider = filtered[index];
                        final bool isHighlight = index % 2 == 1;

                        // Theme mode configuration for Light vs Dark highlight card
                        final Color cardBg = isHighlight 
                            ? AppColors.charcoalDark 
                            : (isDark ? const Color(0xFF161616) : AppColors.surfaceLightGray);
                        final Color titleColor = isHighlight ? Colors.white : (isDark ? Colors.white : AppColors.charcoalDark);
                        final Color descColor = isHighlight ? Colors.white60 : AppColors.mutedGray;

                        final double rating = provider.rating;
                        final String imageUrl = _getCategoryImage(provider.category);
                        final String specialty = "${provider.category} Specialist";
                        final String slotsText = provider.availableTimes.isNotEmpty 
                            ? "${provider.availableTimes.length} Slots Available" 
                            : "Immediate Slot Open";

                        final List<Map<String, dynamic>> dummyDates = [
                          {"day": "Mon", "num": "18", "active": index % 3 == 0},
                          {"day": "Tue", "num": "19", "active": index % 3 == 1},
                          {"day": "Wed", "num": "20", "active": index % 3 == 2},
                          {"day": "Thu", "num": "21", "active": false},
                          {"day": "Fri", "num": "22", "active": false},
                        ];

                        return GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(
                              context, 
                              AppRoutes.providerDetail, 
                              arguments: {
                                "provider": provider, // Pass the real object
                                "providerData": {
                                  "name": provider.name,
                                  "specialty": specialty,
                                  "rating": rating.toString(),
                                  "reviews": provider.reviewCount.toString(),
                                  "slots": slotsText,
                                  "image": imageUrl,
                                },
                              },
                            );
                          },
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 20),
                            decoration: BoxDecoration(
                              color: cardBg,
                              borderRadius: BorderRadius.circular(28),
                              border: Border.all(
                                color: isHighlight
                                    ? Colors.white.withOpacity(0.1)
                                    : (isDark ? Colors.white.withOpacity(0.06) : Colors.transparent),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(isHighlight ? 0.16 : 0.02),
                                  blurRadius: 12,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Stack/Row Layout Blueprint (Header)
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    // Top Row Left Metadata Pill Chips
                                    Row(
                                      children: [
                                        // Rating Pill
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                          decoration: BoxDecoration(
                                            color: isHighlight 
                                                ? Colors.white.withOpacity(0.1) 
                                                : AppColors.pastelYellow,
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.star_rounded,
                                                color: isHighlight ? AppColors.pastelYellow : AppColors.charcoalDark,
                                                size: 14,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                rating.toString(),
                                                style: GoogleFonts.nunito(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w800,
                                                  color: isHighlight ? Colors.white : AppColors.charcoalDark,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        // Review Count Pill
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                          decoration: BoxDecoration(
                                            color: isHighlight ? Colors.white.withOpacity(0.1) : AppColors.pastelBlue,
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Text(
                                            "${provider.reviewCount} Reviews",
                                            style: GoogleFonts.nunito(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w800,
                                              color: isHighlight ? Colors.white : AppColors.charcoalDark,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    
                                    // Top Row Right - Clipped Profile Image
                                    Container(
                                      width: 56,
                                      height: 56,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(16),
                                        image: DecorationImage(
                                          image: NetworkImage(imageUrl),
                                          fit: BoxFit.cover,
                                        ),
                                        border: Border.all(
                                          color: isHighlight ? Colors.white24 : Colors.transparent,
                                          width: 1.5,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),

                                // Mid-Section Text Info
                                Text(
                                  provider.name,
                                  style: GoogleFonts.nunito(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w900,
                                    color: titleColor,
                                    letterSpacing: -0.4,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  specialty,
                                  style: GoogleFonts.nunito(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: descColor,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Container(
                                      width: 8,
                                      height: 8,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: isHighlight ? AppColors.pastelGreen : AppColors.deepTeal,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      slotsText,
                                      style: GoogleFonts.nunito(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: isHighlight ? AppColors.pastelGreen : AppColors.deepTeal,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),

                                // Bottom Horizontal Calendar Date Ribbon
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: dummyDates.map<Widget>((date) {
                                    final bool isActive = date['active'];
                                    final Color capsuleBg = isActive 
                                        ? (isHighlight ? Colors.white : AppColors.charcoalDark)
                                        : Colors.transparent;
                                    final Color dayColor = isActive 
                                        ? (isHighlight ? AppColors.charcoalDark : Colors.white)
                                        : (isHighlight ? Colors.white54 : AppColors.mutedGray);
                                    final Color numColor = isActive 
                                        ? (isHighlight ? AppColors.charcoalDark : Colors.white)
                                        : titleColor;

                                    return Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                      decoration: BoxDecoration(
                                        color: capsuleBg,
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(
                                          color: isActive
                                              ? Colors.transparent
                                              : (isHighlight ? Colors.white10 : Colors.black.withOpacity(0.04)),
                                        ),
                                      ),
                                      child: Column(
                                        children: [
                                          Text(
                                            date['day'],
                                            style: GoogleFonts.nunito(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w700,
                                              color: dayColor,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            date['num'],
                                            style: GoogleFonts.nunito(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w800,
                                              color: numColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
