import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/new_ui/promo_banner_card.dart';
import '../../widgets/new_ui/category_filter_tags.dart';
import '../../widgets/new_ui/service_discovery_card.dart';
import '../../models/service_provider.dart';
import '../../core/data/mock_data.dart';
import '../../core/services/auth_service.dart';
import '../../core/config/supabase_config.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../address_selection_screen.dart';
import '../../core/routes/app_routes.dart';

class NewHomeDashboardScreen extends StatefulWidget {
  const NewHomeDashboardScreen({super.key});

  @override
  State<NewHomeDashboardScreen> createState() => _NewHomeDashboardScreenState();
}

class _NewHomeDashboardScreenState extends State<NewHomeDashboardScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = "All";
  List<ServiceProvider> _providers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchProviders();
  }

  Future<void> _fetchProviders() async {
    setState(() => _isLoading = true);
    try {
      if (SupabaseConfig.isSupabaseActive) {
        final List<dynamic> response = await Supabase.instance.client
            .from('service_providers')
            .select();
        
        if (response.isNotEmpty) {
          setState(() {
            _providers = response.map((item) => ServiceProvider.fromJson(item)).toList();
            _isLoading = false;
          });
          return;
        }
      }
      
      // Fallback to MockData
      await MockData.loadProviders();
      setState(() {
        _providers = MockData.providers;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  final List<Map<String, dynamic>> _categories = [
    {"name": "All", "icon": Icons.widgets_outlined},
    {"name": "Cleaning", "icon": Icons.cleaning_services_outlined},
    {"name": "Plumbing", "icon": Icons.plumbing_outlined},
    {"name": "Painting", "icon": Icons.format_paint_outlined},
    {"name": "Repairing", "icon": Icons.handyman_outlined},
  ];

  String _getCategoryImage(String category) {
    switch (category.toLowerCase()) {
      case 'cleaning':
        return 'https://images.unsplash.com/photo-1581578731548-c64695cc6952?auto=format&fit=crop&q=80&w=400';
      case 'plumbing':
        return 'https://images.unsplash.com/photo-1504307651254-35680f356dfd?auto=format&fit=crop&q=80&w=400';
      case 'painting':
        return 'https://images.unsplash.com/photo-1562259949-e8e7689d7828?auto=format&fit=crop&q=80&w=400';
      default:
        return 'https://images.unsplash.com/photo-1621905251189-08b45d6a269e?auto=format&fit=crop&q=80&w=400';
    }
  }

  List<Map<String, dynamic>> get _allServices {
    return MockData.providers.map((p) => {
      "title": p.name,
      "category": p.category,
      "rating": p.rating.toString(),
      "image": _getCategoryImage(p.category),
      "provider": p,
      "providerData": {
        "name": p.name,
        "specialty": "${p.category} Specialist",
        "rating": p.rating.toString(),
        "reviews": "${p.reviewCount} Reviews",
        "slots": "Immediate Slot Open",
        "image": _getCategoryImage(p.category),
      }
    }).toList();
  }

  List<Map<String, dynamic>> get _filteredServices {
    if (_selectedCategory == "All") return _allServices;
    return _allServices
        .where((s) => s['category'].toString().toLowerCase() == _selectedCategory.toLowerCase())
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.offWhite,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Custom Top App Bar (Hello Mark, avatar)
              _buildCustomAppBar(isDark),
              const SizedBox(height: 24),

              // Welcome text
              Text(
                "What are you looking\nto get done today?",
                style: GoogleFonts.nunito(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white : AppColors.textDark,
                  height: 1.25,
                ),
              ),
              const SizedBox(height: 20),

              // 2. Custom Search Box
              _buildCustomSearchBox(isDark),
              const SizedBox(height: 24),

              // 3. Promo Banner Card
              PromoBannerCard(
                title: "50% Off",
                subtitle: "On your first premium AC checkout",
                buttonText: "Claim Now",
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Discount coupon successfully applied!"),
                      backgroundColor: AppColors.deepTeal,
                    ),
                  );
                },
              ),
              const SizedBox(height: 28),

              // Section Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Popular services",
                    style: GoogleFonts.nunito(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: isDark ? Colors.white : AppColors.textDark,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, AppRoutes.searchResults, arguments: "");
                    },
                    child: Text(
                      "See All",
                      style: GoogleFonts.nunito(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.deepTeal,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // 4. Category Tags Bar
              CategoryFilterTags(
                categories: _categories,
                selectedCategory: _selectedCategory,
                onSelected: (name) {
                  setState(() {
                    _selectedCategory = name;
                  });
                },
              ),
              const SizedBox(height: 24),

              // 5. Featured Services Feed
              _filteredServices.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 40.0),
                        child: Text(
                          "No services matching this filter.",
                          style: GoogleFonts.nunito(
                            fontSize: 14,
                            color: AppColors.textMutedGray,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    )
                  : ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _filteredServices.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        final service = _filteredServices[index];
                        return ServiceDiscoveryCard(
                          providerName: service['title'],
                          imageUrl: service['image'],
                          rating: service['rating'],
                          onTap: () {
                              Navigator.pushNamed(
                                context,
                                AppRoutes.providerDetail,
                                arguments: {
                                  'provider': service['provider'],
                                  'providerData': service['providerData'],
                                },
                              );
                          },
                        );
                      },
                    ),
              const SizedBox(height: 80), // Offset for bottom nav bar padding
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCustomAppBar(bool isDark) {
    final name = AuthService.currentUser?.name ?? MockData.currentUserName;
    String displayAddress = "DHA Phase 6, Lahore";
    try {
      if (MockData.addresses.isNotEmpty) {
        final selected = MockData.addresses.firstWhere((a) => a.isSelected, orElse: () => MockData.addresses.first);
        displayAddress = selected.address;
      }
    } catch (_) {}

    return Row(
      children: [
        // Greeting & Location
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Good Morning! $name.",
                style: GoogleFonts.nunito(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white : AppColors.textDark,
                ),
              ),
              GestureDetector(
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AddressSelectionScreen()),
                  );
                  setState(() {});
                },
                behavior: HitTestBehavior.opaque,
                child: Row(
                  children: [
                    const Icon(
                      Icons.location_on,
                      color: AppColors.deepTeal,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        displayAddress,
                        style: GoogleFonts.nunito(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textMutedGray,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.keyboard_arrow_down,
                      color: AppColors.textMutedGray,
                      size: 16,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        
        // Avatar on right side
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.deepTeal, width: 2),
            image: const DecorationImage(
              image: NetworkImage("https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&q=80&w=200"),
              fit: BoxFit.cover,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCustomSearchBox(bool isDark) {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLightGray,

        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.08) : Colors.transparent,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              final query = _searchController.text.trim();
              Navigator.pushNamed(context, AppRoutes.searchResults, arguments: query);
            },
            child: Icon(
              Icons.search,
              color: isDark ? Colors.white54 : AppColors.textMutedGray,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: _searchController,
              textInputAction: TextInputAction.search,
              onSubmitted: (value) {
                Navigator.pushNamed(context, AppRoutes.searchResults, arguments: value.trim());
              },
              style: GoogleFonts.nunito(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : AppColors.textDark,
              ),
              decoration: InputDecoration(
                hintText: "Search services, shops, materials...",
                hintStyle: GoogleFonts.nunito(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white30 : AppColors.textMutedGray,
                ),
                border: InputBorder.none,
                isDense: true,
              ),
            ),
          ),
          Container(
            height: 36,
            width: 1,
            color: isDark ? Colors.white10 : Colors.black.withOpacity(0.06),
            margin: const EdgeInsets.symmetric(horizontal: 8),
          ),
          GestureDetector(
            onTap: () => _showFilterBottomSheet(context, isDark),
            child: Icon(
              Icons.tune, // Trailing settings filter slider icon
              color: isDark ? AppColors.deepTeal : AppColors.charcoalDark,
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterBottomSheet(BuildContext context, bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Search Filters",
                    style: GoogleFonts.nunito(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: isDark ? Colors.white : AppColors.charcoalDark,
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      "Reset",
                      style: GoogleFonts.nunito(
                        color: AppColors.deepTeal,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                "Distance",
                style: GoogleFonts.nunito(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white70 : AppColors.charcoalDark,
                ),
              ),
              Slider(
                value: 5,
                min: 1,
                max: 20,
                activeColor: AppColors.deepTeal,
                onChanged: (val) {},
              ),
              const SizedBox(height: 16),
              Text(
                "Rating",
                style: GoogleFonts.nunito(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white70 : AppColors.charcoalDark,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(5, (index) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: index == 3 ? AppColors.deepTeal : (isDark ? Colors.white.withOpacity(0.05) : AppColors.offWhite),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Text(
                          "${index + 1}",
                          style: GoogleFonts.nunito(
                            fontWeight: FontWeight.w800,
                            color: index == 3 ? Colors.white : (isDark ? Colors.white70 : AppColors.charcoalDark),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(Icons.star_rounded, size: 14, color: index == 3 ? Colors.white : Colors.amber),
                      ],
                    ),
                  );
                }),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 58,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.deepTeal,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  ),
                  child: Text(
                    "Apply Filters",
                    style: GoogleFonts.nunito(fontWeight: FontWeight.w900, fontSize: 18, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
