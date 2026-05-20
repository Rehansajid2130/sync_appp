import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme/app_colors.dart';
import '../core/data/mock_data.dart';
import 'add_address_map_screen.dart';

class AddressSelectionScreen extends StatefulWidget {
  const AddressSelectionScreen({super.key});

  @override
  State<AddressSelectionScreen> createState() => _AddressSelectionScreenState();
}

class _AddressSelectionScreenState extends State<AddressSelectionScreen> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.offWhite,
      body: SafeArea(
        child: Column(
          children: [
            // 1. Header Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 44,
                      height: 44,
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
                      child: Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: isDark ? Colors.white : AppColors.charcoalDark,
                        size: 18,
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Text(
                    'Saved Addresses',
                    style: GoogleFonts.nunito(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: isDark ? Colors.white : AppColors.charcoalDark,
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF111111) : Colors.white,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(40),
                    topRight: Radius.circular(40),
                  ),
                ),
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(24, 32, 24, 100),
                  physics: const BouncingScrollPhysics(),
                  itemCount: MockData.addresses.length + 1,
                  separatorBuilder: (_, __) => const SizedBox(height: 20),
                  itemBuilder: (context, index) {
                    if (index == MockData.addresses.length) {
                      // Add New Address Button
                      return Padding(
                        padding: const EdgeInsets.only(top: 12.0),
                        child: InkWell(
                          onTap: () async {
                            final result = await Navigator.push<Map<String, dynamic>>(
                              context,
                              MaterialPageRoute(builder: (context) => const AddAddressMapScreen()),
                            );

                            if (result != null) {
                              setState(() {
                                for (var addr in MockData.addresses) {
                                  addr.isSelected = false;
                                }
                                MockData.addresses.add(UserAddress(
                                  title: result['title'] ?? 'New Location',
                                  address: result['address'] ?? 'Unknown Address',
                                  latitude: result['lat'] ?? 0.0,
                                  longitude: result['lng'] ?? 0.0,
                                  isSelected: true,
                                  isMain: MockData.addresses.isEmpty,
                                ));
                                MockData.saveAddresses();
                              });
                            }
                          },
                          borderRadius: BorderRadius.circular(24),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.05),
                                width: 2,
                                style: BorderStyle.solid,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add_location_alt_rounded, color: AppColors.deepTeal, size: 22),
                                const SizedBox(width: 12),
                                Text(
                                  'Add New Address',
                                  style: GoogleFonts.nunito(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.deepTeal,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }

                    final addressItem = MockData.addresses[index];
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          for (var addr in MockData.addresses) {
                            addr.isSelected = (addr == addressItem);
                          }
                          MockData.saveAddresses();
                        });
                      },
                      child: _buildAddressCard(
                        title: addressItem.title,
                        address: addressItem.address,
                        isSelected: addressItem.isSelected,
                        isMain: addressItem.isMain,
                        isDark: isDark,
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
      bottomSheet: Container(
        color: isDark ? const Color(0xFF111111) : Colors.white,
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
        child: SizedBox(
          width: double.infinity,
          height: 58,
          child: ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.deepTeal,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
            ),
            child: Text(
              'Select Address',
              style: GoogleFonts.nunito(
                fontWeight: FontWeight.w900,
                fontSize: 18,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAddressCard({
    required String title,
    required String address,
    bool isSelected = false,
    bool isMain = false,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isSelected
            ? (isDark ? const Color(0xFF0C2A2B) : const Color(0xFFE6F3F3))
            : (isDark ? const Color(0xFF1E1E1E) : AppColors.surfaceLightGray),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isSelected
              ? AppColors.deepTeal
              : (isDark ? Colors.white.withOpacity(0.06) : Colors.transparent),
          width: isSelected ? 2 : 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isSelected
                  ? (isDark ? const Color(0xFF144B4C) : const Color(0xFFCDE2E2))
                  : (isDark ? const Color(0xFF2E2E2E) : const Color(0xFFE2E7EE)),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.location_on_outlined,
              size: 20,
              color: isSelected
                  ? AppColors.deepTeal
                  : (isDark ? Colors.white70 : AppColors.textDark),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.nunito(
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                        color: isDark ? Colors.white : AppColors.textDark,
                      ),
                    ),
                    if (isMain) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.deepTeal,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'Main',
                          style: GoogleFonts.nunito(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  address,
                  style: GoogleFonts.nunito(
                    color: isDark ? Colors.white70 : AppColors.textMutedGray,
                    height: 1.4,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      Icons.check_circle_outline_rounded,
                      size: 14,
                      color: isSelected ? AppColors.deepTeal : AppColors.textMutedGray,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Ready for scheduling dispatch',
                      style: GoogleFonts.nunito(
                        color: isDark ? Colors.white60 : AppColors.textMutedGray,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (isSelected)
            const Padding(
              padding: EdgeInsets.only(left: 8.0),
              child: Icon(
                Icons.check_circle_rounded,
                color: AppColors.deepTeal,
                size: 22,
              ),
            ),
        ],
      ),
    );
  }
}
