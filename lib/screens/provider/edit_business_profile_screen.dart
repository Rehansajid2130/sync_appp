import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/theme/app_colors.dart';
import '../../core/data/mock_data.dart';
import '../../core/services/auth_service.dart';
import '../../models/service_provider.dart';

class EditBusinessProfileScreen extends StatefulWidget {
  const EditBusinessProfileScreen({super.key});

  @override
  State<EditBusinessProfileScreen> createState() => _EditBusinessProfileScreenState();
}

class _EditBusinessProfileScreenState extends State<EditBusinessProfileScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _bioController;
  late final TextEditingController _expController;
  late String _category;
  String? _profileImagePath;
  final ImagePicker _picker = ImagePicker();

  ServiceProvider? _currentProvider;

  @override
  void initState() {
    super.initState();
    final user = AuthService.currentUser;
    _currentProvider = MockData.providers.firstWhere(
      (p) => p.id == user?.uid || p.name == user?.name,
      orElse: () => ServiceProvider(
        id: user?.uid ?? 'james_anderson',
        name: user?.name ?? 'James Anderson',
        category: 'Cleaning',
        rating: 4.9,
        reviewCount: 128,
        location: 'Situ Udik, Bogor',
        icon: Icons.cleaning_services_outlined,
        avatarColor: const Color(0xFF91CBAE),
        availableTimes: const ['08:00 AM', '10:00 AM', '01:00 PM', '03:00 PM'],
        description: 'Professional cleaning specialist with over 5 years of experience.',
        experience: 5,
      ),
    );

    _nameController = TextEditingController(text: _currentProvider!.name);
    _bioController = TextEditingController(text: _currentProvider!.description);
    _expController = TextEditingController(text: _currentProvider!.experience.toString());
    _category = _currentProvider!.category;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    _expController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) setState(() => _profileImagePath = image.path);
  }

  Future<void> _save() async {
    if (_currentProvider == null) return;

    final updatedProvider = ServiceProvider(
      id: _currentProvider!.id,
      name: _nameController.text.trim().isNotEmpty
          ? _nameController.text.trim()
          : _currentProvider!.name,
      category: _category,
      rating: _currentProvider!.rating,
      reviewCount: _currentProvider!.reviewCount,
      location: _currentProvider!.location,
      icon: _currentProvider!.icon,
      avatarColor: _currentProvider!.avatarColor,
      availableTimes: _currentProvider!.availableTimes,
      description: _bioController.text.trim(),
      experience: int.tryParse(_expController.text.trim()) ?? _currentProvider!.experience,
    );

    await MockData.registerProvider(updatedProvider);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Business profile updated successfully!',
          style: GoogleFonts.nunito(color: Colors.white, fontWeight: FontWeight.w700),
        ),
        backgroundColor: AppColors.deepTeal,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
    Navigator.pop(context);
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
          'Edit Storefront',
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
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Morphic Profile Photo
              Center(
                child: Stack(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.deepTeal.withOpacity(0.2), width: 2),
                      ),
                      child: CircleAvatar(
                        radius: 60,
                        backgroundColor: AppColors.deepTeal.withOpacity(0.08),
                        backgroundImage: _profileImagePath != null
                            ? FileImage(File(_profileImagePath!)) as ImageProvider
                            : null,
                        child: _profileImagePath == null
                            ? const Icon(Icons.storefront_rounded, size: 50, color: AppColors.deepTeal)
                            : null,
                      ),
                    ),
                    Positioned(
                      bottom: 4,
                      right: 4,
                      child: GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.deepTeal,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.deepTeal.withOpacity(0.3),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 18),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),

              _buildMorphicInput(label: 'Business Name', controller: _nameController, isDark: isDark),
              const SizedBox(height: 20),
              
              Text('Service Category', style: GoogleFonts.nunito(fontWeight: FontWeight.w800, color: isDark ? Colors.white70 : AppColors.mutedGray)),
              const SizedBox(height: 12),
              _buildDropdown(isDark),
              const SizedBox(height: 20),

              _buildMorphicInput(label: 'Years of Experience', controller: _expController, isDark: isDark, keyboardType: TextInputType.number),
              const SizedBox(height: 20),

              _buildMorphicInput(label: 'Biography', controller: _bioController, maxLines: 4, isDark: isDark),
              
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 58,
                child: ElevatedButton(
                  onPressed: _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.deepTeal,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                  ),
                  child: Text(
                    'Save Changes',
                    style: GoogleFonts.nunito(fontWeight: FontWeight.w900, fontSize: 18, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMorphicInput({
    required String label,
    required TextEditingController controller,
    required bool isDark,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel(label, isDark),
        _buildTextField(controller, label, isDark, maxLines: maxLines, keyboardType: keyboardType),
      ],
    );
  }

  Widget _buildFieldLabel(String label, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        label,
        style: GoogleFonts.nunito(
          fontWeight: FontWeight.w800,
          fontSize: 12,
          color: AppColors.mutedGray,
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String hint,
    bool isDark, {
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF161616) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.06) : Colors.black.withOpacity(0.06),
        ),
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        style: GoogleFonts.nunito(
          color: isDark ? Colors.white : AppColors.charcoalDark,
          fontWeight: FontWeight.w700,
          fontSize: 14,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.nunito(
            color: AppColors.mutedGray.withOpacity(0.6),
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
        ),
      ),
    );
  }

  Widget _buildDropdown(bool isDark) {
    final categories = ['Cleaning', 'Plumbing', 'Electrician', 'Carpentry', 'Painting', 'Heating'];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF161616) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.06) : Colors.black.withOpacity(0.06),
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _category,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.mutedGray),
          dropdownColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          style: GoogleFonts.nunito(
            color: isDark ? Colors.white : AppColors.charcoalDark,
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
          items: categories
              .map((v) => DropdownMenuItem<String>(
                    value: v,
                    child: Text(v),
                  ))
              .toList(),
          onChanged: (v) => setState(() => _category = v!),
        ),
      ),
    );
  }
}
