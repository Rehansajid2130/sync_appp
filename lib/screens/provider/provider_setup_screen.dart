import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../core/data/mock_data.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/storage_service.dart';
import '../../models/service_provider.dart';
import 'provider_navigation_screen.dart';

class ProviderSetupScreen extends StatefulWidget {
  const ProviderSetupScreen({super.key});

  @override
  State<ProviderSetupScreen> createState() => _ProviderSetupScreenState();
}

class _ProviderSetupScreenState extends State<ProviderSetupScreen> {
  final TextEditingController _businessNameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  String _selectedCategory = "Cleaning";
  final List<String> _categories = ["Cleaning", "Repair", "Plumbing", "Electrical"];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.offWhite,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: isDark ? Colors.white : AppColors.charcoalDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Setup Business',
          style: GoogleFonts.nunito(
            color: isDark ? Colors.white : AppColors.charcoalDark,
            fontWeight: FontWeight.w900,
            fontSize: 20,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Create Your Storefront",
                style: GoogleFonts.nunito(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: isDark ? Colors.white : AppColors.charcoalDark,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                "Provide details about your business to get started.",
                style: GoogleFonts.nunito(
                  fontSize: 15,
                  color: isDark ? Colors.white70 : AppColors.mutedGray,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 40),

              _buildMorphicInput(label: "Business Name", controller: _businessNameController, isDark: isDark),
              const SizedBox(height: 24),
              
              Text("Service Category", style: GoogleFonts.nunito(fontWeight: FontWeight.w800, color: isDark ? Colors.white70 : AppColors.charcoalDark)),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                children: _categories.map((cat) => FilterChip(
                  label: Text(cat, style: GoogleFonts.nunito(fontWeight: FontWeight.w700)),
                  selected: _selectedCategory == cat,
                  selectedColor: AppColors.deepTeal.withOpacity(0.2),
                  checkmarkColor: AppColors.deepTeal,
                  onSelected: (val) => setState(() => _selectedCategory = cat),
                )).toList(),
              ),
              const SizedBox(height: 24),

              _buildMorphicInput(label: "Description", controller: _descriptionController, maxLines: 4, isDark: isDark),
              
              const SizedBox(height: 60),
              SizedBox(
                width: double.infinity,
                height: 58,
                child: ElevatedButton(
                  onPressed: () async {
                    final user = AuthService.currentUser;
                    final providerId = user?.uid ?? 'p_${DateTime.now().millisecondsSinceEpoch}';
                    final providerName = _businessNameController.text.trim().isNotEmpty
                        ? _businessNameController.text.trim()
                        : (user?.name ?? 'My Business');

                    final newProvider = ServiceProvider(
                      id: providerId,
                      name: providerName,
                      category: _selectedCategory,
                      rating: 5.0,
                      reviewCount: 0,
                      location: 'Lahore, Pakistan',
                      icon: _getCategoryIcon(_selectedCategory),
                      avatarColor: const Color(0xFF91CBAE),
                      availableTimes: const ['08:00 AM', '10:00 AM', '01:00 PM', '03:00 PM'],
                      description: _descriptionController.text.trim().isNotEmpty
                          ? _descriptionController.text.trim()
                          : 'No biography details provided.',
                      experience: 1,
                    );

                    // Register provider in MockData (persists storefront)
                    await MockData.registerProvider(newProvider);

                    // Update user as provider in MockData
                    await AuthService.updateProfile(isProvider: true);
                    
                    // Persist active role
                    await StorageService.saveData('activeRole', 'Provider');

                    if (context.mounted) {
                      Navigator.pushAndRemoveUntil(
                        context, 
                        MaterialPageRoute(builder: (_) => const ProviderNavigationScreen()), 
                        (route) => false,
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.deepTeal,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                  ),
                  child: Text("Launch Business", style: GoogleFonts.nunito(fontWeight: FontWeight.w900, fontSize: 18, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Cleaning':
        return Icons.cleaning_services_outlined;
      case 'Repair':
        return Icons.handyman_outlined;
      case 'Plumbing':
        return Icons.plumbing;
      case 'Electrical':
        return Icons.electrical_services;
      default:
        return Icons.storefront_rounded;
    }
  }

  Widget _buildMorphicInput({required String label, required TextEditingController controller, int maxLines = 1, required bool isDark}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 8),
          child: Text(label, style: GoogleFonts.nunito(fontWeight: FontWeight.w800, color: isDark ? Colors.white70 : AppColors.charcoalDark)),
        ),
        Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1A1A1A) : AppColors.offWhite,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: isDark ? Colors.white10 : Colors.black.withOpacity(0.04)),
          ),
          child: TextField(
            controller: controller,
            maxLines: maxLines,
            style: GoogleFonts.nunito(fontWeight: FontWeight.w700, color: isDark ? Colors.white : AppColors.charcoalDark),
            decoration: const InputDecoration(border: InputBorder.none, contentPadding: EdgeInsets.all(20)),
          ),
        ),
      ],
    );
  }
}
