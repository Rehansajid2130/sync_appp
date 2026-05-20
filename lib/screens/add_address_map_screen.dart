import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme/app_colors.dart';
import '../core/services/map_service.dart';
import '../core/data/mock_data.dart';

class AddAddressMapScreen extends StatefulWidget {
  const AddAddressMapScreen({super.key});

  @override
  State<AddAddressMapScreen> createState() => _AddAddressMapScreenState();
}

class _AddAddressMapScreenState extends State<AddAddressMapScreen> {
  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();

  LatLng _currentLocation = const LatLng(31.4826, 74.3973); // Default (Lahore)
  String _addressName = 'DHA Phase 6, Lahore, Punjab, Pakistan';
  String _addressTitle = 'My Home';
  
  bool _isLoadingAddress = false;
  List<MapPlace> _searchResults = [];
  bool _isSearching = false;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    if (MockData.addresses.isNotEmpty) {
      final selected = MockData.addresses.firstWhere((a) => a.isSelected, orElse: () => MockData.addresses.first);
      _currentLocation = LatLng(selected.latitude, selected.longitude);
      _addressName = selected.address;
      _addressTitle = selected.title;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
    
    _debounceTimer = Timer(const Duration(milliseconds: 500), () async {
      if (query.trim().isEmpty) {
        setState(() {
          _searchResults = [];
          _isSearching = false;
        });
        return;
      }

      setState(() => _isSearching = true);
      final results = await MapService.searchPlaces(query);
      
      setState(() {
        _searchResults = results;
        _isSearching = false;
      });
    });
  }

  Future<void> _reverseGeocodeLocation(LatLng pos) async {
    setState(() => _isLoadingAddress = true);
    final displayAddress = await MapService.reverseGeocode(pos);
    setState(() {
      _currentLocation = pos;
      _addressName = displayAddress;
      _isLoadingAddress = false;
    });
  }

  void _selectSearchResult(MapPlace place) {
    final targetLatLng = LatLng(place.latitude, place.longitude);
    _mapController.move(targetLatLng, 16.0);
    setState(() {
      _currentLocation = targetLatLng;
      _addressName = place.displayName;
      _searchResults = [];
      _searchController.clear();
      FocusScope.of(context).unfocus();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.offWhite,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        leading: Padding(
          padding: const EdgeInsets.all(10.0),
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF161616) : Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  if (!isDark)
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
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
          'Pin Location',
          style: GoogleFonts.nunito(
            color: isDark ? Colors.white : AppColors.charcoalDark,
            fontWeight: FontWeight.w900,
            fontSize: 20,
          ),
        ),
      ),
      body: Stack(
        children: [
          // 1. Map Canvas
          Positioned.fill(
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _currentLocation,
                initialZoom: 15.0,
                onTap: (tapPosition, point) {
                  _mapController.move(point, _mapController.camera.zoom);
                  _reverseGeocodeLocation(point);
                },
              ),
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
                      point: _currentLocation,
                      width: 100,
                      height: 100,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.deepTeal,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.deepTeal.withOpacity(0.3),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Text(
                              'Target',
                              style: GoogleFonts.nunito(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                          const Icon(
                            Icons.location_on_rounded,
                            size: 48,
                            color: Color(0xFFE94560), // Vibrant Red
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // 2. Floating Search Bar (Pastel-Morphic)
          Positioned(
            top: 20,
            left: 20,
            right: 20,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF111111) : Colors.white,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                    border: Border.all(
                      color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.04),
                    ),
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: _onSearchChanged,
                    style: GoogleFonts.nunito(
                      color: isDark ? Colors.white : AppColors.charcoalDark,
                      fontWeight: FontWeight.w700,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Search for address...',
                      hintStyle: GoogleFonts.nunito(
                        color: isDark ? Colors.white38 : AppColors.mutedGray,
                      ),
                      prefixIcon: const Icon(Icons.search_rounded, color: AppColors.deepTeal),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.close_rounded, color: AppColors.mutedGray, size: 20),
                              onPressed: () {
                                _searchController.clear();
                                setState(() => _searchResults = []);
                              },
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),

                // Search Results
                if (_searchResults.isNotEmpty || _isSearching)
                  Container(
                    margin: const EdgeInsets.only(top: 12),
                    constraints: const BoxConstraints(maxHeight: 250),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF111111) : Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.12),
                          blurRadius: 25,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: _isSearching
                        ? const Center(
                            child: Padding(
                              padding: EdgeInsets.all(24.0),
                              child: CircularProgressIndicator(color: AppColors.deepTeal, strokeWidth: 3),
                            ),
                          )
                        : ListView.separated(
                            shrinkWrap: true,
                            padding: const EdgeInsets.all(12),
                            itemCount: _searchResults.length,
                            separatorBuilder: (_, __) => Divider(
                              color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.03),
                              height: 1,
                            ),
                            itemBuilder: (context, index) {
                              final place = _searchResults[index];
                              return ListTile(
                                dense: true,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                leading: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: AppColors.deepTeal.withOpacity(0.08),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.location_on_outlined, color: AppColors.deepTeal, size: 16),
                                ),
                                title: Text(
                                  place.displayName,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.nunito(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: isDark ? Colors.white : AppColors.charcoalDark,
                                  ),
                                ),
                                onTap: () => _selectSearchResult(place),
                              );
                            },
                          ),
                  ),
              ],
            ),
          ),

          // 3. Location Details Modal (Bottom)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(28, 32, 28, 40),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF111111) : Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 30,
                    offset: const Offset(0, -10),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Location Preview',
                        style: GoogleFonts.nunito(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: isDark ? Colors.white : AppColors.charcoalDark,
                        ),
                      ),
                      GestureDetector(
                        onTap: _showEditTitleDialog,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppColors.deepTeal.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.edit_location_alt_rounded, size: 16, color: AppColors.deepTeal),
                              const SizedBox(width: 6),
                              Text(
                                _addressTitle,
                                style: GoogleFonts.nunito(
                                  color: AppColors.deepTeal,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1A1A1A) : AppColors.offWhite,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(Icons.map_rounded, color: AppColors.deepTeal, size: 24),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _addressTitle,
                              style: GoogleFonts.nunito(
                                fontWeight: FontWeight.w900,
                                fontSize: 18,
                                color: isDark ? Colors.white : AppColors.charcoalDark,
                              ),
                            ),
                            const SizedBox(height: 6),
                            _isLoadingAddress
                                ? const LinearProgressIndicator(
                                    minHeight: 2,
                                    color: AppColors.deepTeal,
                                    backgroundColor: Colors.transparent,
                                  )
                                : Text(
                                    _addressName,
                                    style: GoogleFonts.nunito(
                                      color: isDark ? Colors.white70 : AppColors.mutedGray,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      height: 1.4,
                                    ),
                                  ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 36),
                  SizedBox(
                    width: double.infinity,
                    height: 58,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context, {
                          'title': _addressTitle,
                          'address': _addressName,
                          'lat': _currentLocation.latitude,
                          'lng': _currentLocation.longitude,
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.deepTeal,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                      ),
                      child: Text(
                        'Confirm Location',
                        style: GoogleFonts.nunito(
                          fontWeight: FontWeight.w900,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showEditTitleDialog() {
    final titleController = TextEditingController(text: _addressTitle);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: isDark ? const Color(0xFF161616) : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Label This Place',
                  style: GoogleFonts.nunito(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: isDark ? Colors.white : AppColors.charcoalDark,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Give this location a recognizable name like "Office" or "Dad\'s House".',
                  style: GoogleFonts.nunito(
                    fontSize: 15,
                    color: isDark ? Colors.white70 : AppColors.mutedGray,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 28),
                Container(
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1A1A1A) : AppColors.offWhite,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: isDark ? Colors.white10 : Colors.black.withOpacity(0.04)),
                  ),
                  child: TextField(
                    controller: titleController,
                    style: GoogleFonts.nunito(fontWeight: FontWeight.w700),
                    decoration: InputDecoration(
                      hintText: 'e.g. My Workspace',
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.all(20),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.deepTeal,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                      elevation: 0,
                    ),
                    onPressed: () {
                      setState(() {
                        _addressTitle = titleController.text.trim();
                      });
                      Navigator.pop(context);
                    },
                    child: Text('Save Label', style: GoogleFonts.nunito(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16)),
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
