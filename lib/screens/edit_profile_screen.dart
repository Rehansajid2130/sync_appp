import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../core/theme/app_colors.dart';
import '../core/services/auth_service.dart';
import '../core/data/mock_data.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  String? _profileImagePath;
  final ImagePicker _picker = ImagePicker();

  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _dobController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: AuthService.currentUser?.name ?? MockData.currentUserName);
    _emailController = TextEditingController(text: AuthService.currentUser?.email ?? MockData.currentUserEmail);
    _dobController = TextEditingController(text: '01 April 2004');
    _phoneController = TextEditingController(text: '3001234567');
    _addressController = TextEditingController(
      text: MockData.addresses.isNotEmpty 
          ? MockData.addresses.firstWhere((a) => a.isSelected, orElse: () => MockData.addresses.first).address 
          : 'DHA Phase 6, Lahore',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _dobController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _profileImagePath = image.path;
      });
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
          'Edit Profile',
          style: GoogleFonts.nunito(
            color: isDark ? Colors.white : AppColors.charcoalDark,
            fontWeight: FontWeight.w900,
            fontSize: 20,
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          children: [
            // 1. Morphic Profile Header
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
                          : const NetworkImage(
                              "https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&q=80&w=200",
                            ),
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
                        child: const Icon(
                          Icons.camera_alt_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),

            // 2. Input Section
            _buildMorphicInput(
              label: 'Full Name',
              controller: _nameController,
              icon: Icons.person_outline_rounded,
              isDark: isDark,
            ),
            const SizedBox(height: 20),

            _buildMorphicInput(
              label: 'Email Address',
              controller: _emailController,
              icon: Icons.alternate_email_rounded,
              isDark: isDark,
            ),
            const SizedBox(height: 20),

            _buildMorphicInput(
              label: 'Date of Birth',
              controller: _dobController,
              icon: Icons.calendar_today_rounded,
              isDark: isDark,
            ),
            const SizedBox(height: 20),

            _buildPhoneInput(isDark),
            const SizedBox(height: 20),

            _buildAddressInput(isDark),
            const SizedBox(height: 40),

            // 3. Action Buttons
            SizedBox(
              width: double.infinity,
              height: 58,
              child: ElevatedButton(
                onPressed: () async {
                  if (AuthService.currentUser != null) {
                    await AuthService.updateProfile(
                      name: _nameController.text.trim(),
                      email: _emailController.text.trim(),
                    );
                  }
                  MockData.currentUserName = _nameController.text.trim();
                  MockData.currentUserEmail = _emailController.text.trim();

                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Profile updated successfully!', style: GoogleFonts.nunito(fontWeight: FontWeight.w700)),
                        backgroundColor: AppColors.deepTeal,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                    );
                    Navigator.pop(context);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.deepTeal,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                ),
                child: Text(
                  'Update Profile',
                  style: GoogleFonts.nunito(fontWeight: FontWeight.w900, fontSize: 18),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildMorphicInput({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    required bool isDark,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 8),
          child: Text(
            label,
            style: GoogleFonts.nunito(
              fontWeight: FontWeight.w800,
              fontSize: 14,
              color: isDark ? Colors.white70 : AppColors.charcoalDark,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF111111) : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.04)),
            boxShadow: [
              if (!isDark)
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
            ],
          ),
          child: TextField(
            controller: controller,
            style: GoogleFonts.nunito(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : AppColors.charcoalDark,
            ),
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: AppColors.deepTeal, size: 20),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPhoneInput(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 8),
          child: Text(
            'Phone Number',
            style: GoogleFonts.nunito(
              fontWeight: FontWeight.w800,
              fontSize: 14,
              color: isDark ? Colors.white70 : AppColors.charcoalDark,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF111111) : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.04)),
          ),
          child: Row(
            children: [
              const SizedBox(width: 16),
              Text('🇵🇰', style: const TextStyle(fontSize: 18)),
              const SizedBox(width: 8),
              Text(
                '+92',
                style: GoogleFonts.nunito(
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                  color: isDark ? Colors.white : AppColors.charcoalDark,
                ),
              ),
              const Icon(Icons.arrow_drop_down_rounded, color: AppColors.deepTeal),
              Container(width: 1, height: 24, color: isDark ? Colors.white10 : Colors.black12, margin: const EdgeInsets.symmetric(horizontal: 12)),
              Expanded(
                child: TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  style: GoogleFonts.nunito(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : AppColors.charcoalDark,
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAddressInput(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 8),
          child: Text(
            'Home Address',
            style: GoogleFonts.nunito(
              fontWeight: FontWeight.w800,
              fontSize: 14,
              color: isDark ? Colors.white70 : AppColors.charcoalDark,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF111111) : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.04)),
          ),
          child: TextField(
            controller: _addressController,
            maxLines: 3,
            style: GoogleFonts.nunito(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : AppColors.charcoalDark,
            ),
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.location_on_outlined, color: AppColors.deepTeal, size: 20),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(20),
              hintText: 'Enter your primary address...',
              hintStyle: GoogleFonts.nunito(color: AppColors.mutedGray, fontSize: 14),
            ),
          ),
        ),
      ],
    );
  }
}
