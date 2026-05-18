import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/data/mock_data.dart';
import '../../models/service_provider.dart';
import 'provider_navigation_screen.dart';

class ProviderSetupScreen extends StatefulWidget {
  const ProviderSetupScreen({super.key});

  @override
  State<ProviderSetupScreen> createState() => _ProviderSetupScreenState();
}

class _ProviderSetupScreenState extends State<ProviderSetupScreen> {
  final _businessNameController = TextEditingController();
  final _bioController = TextEditingController();
  String _selectedCategory = 'Cleaning';
  final List<String> _categories = ['Cleaning', 'Plumbing', 'Electrician', 'Carpentry', 'Gardening'];
  final List<String> _availableSlots = ['08:00 AM', '09:00 AM', '10:00 AM', '11:00 AM', '01:00 PM', '02:00 PM', '03:00 PM', '04:00 PM', '06:00 PM', '07:00 PM', '08:00 PM'];
  final List<String> _selectedTimes = [];

  void _finishSetup() async {
    if (_businessNameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your business name')),
      );
      return;
    }
    if (_selectedTimes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select your available timings')),
      );
      return;
    }

    final newProvider = ServiceProvider(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: _businessNameController.text,
      category: _selectedCategory,
      rating: 5.0,
      reviewCount: 0,
      location: 'New York, US',
      icon: _getCategoryIcon(_selectedCategory),
      avatarColor: AppColors.primary,
      availableTimes: _selectedTimes,
    );

    await MockData.addProvider(newProvider);

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const ProviderNavigationScreen()),
      );
    }
  }

  IconData _getCategoryIcon(String cat) {
    switch (cat) {
      case 'Cleaning': return Icons.cleaning_services;
      case 'Plumbing': return Icons.plumbing;
      case 'Electrician': return Icons.electrical_services;
      case 'Carpentry': return Icons.handyman;
      case 'Gardening': return Icons.grass;
      default: return Icons.work;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), shape: BoxShape.circle),
                child: const Icon(Icons.business_center, color: AppColors.primary, size: 40),
              ),
              const SizedBox(height: 32),
              Text(
                'Become a Helper',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: isDark ? Colors.white : Colors.black),
              ),
              const SizedBox(height: 12),
              Text(
                'Tell us about your business to start receiving job requests.',
                style: TextStyle(color: isDark ? Colors.white70 : Colors.black54, fontSize: 16),
              ),
              const SizedBox(height: 40),
              _buildFieldLabel('Business Name', isDark),
              TextField(
                controller: _businessNameController,
                style: TextStyle(color: isDark ? Colors.white : Colors.black),
                decoration: _inputDecoration('e.g. Pro Cleaners NY', isDark),
              ),
              const SizedBox(height: 24),
              _buildFieldLabel('Primary Service Category', isDark),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF161616) : Colors.grey[100],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedCategory,
                    isExpanded: true,
                    dropdownColor: isDark ? const Color(0xFF161616) : Colors.white,
                    style: TextStyle(color: isDark ? Colors.white : Colors.black, fontWeight: FontWeight.w600),
                    items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                    onChanged: (v) => setState(() => _selectedCategory = v!),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              _buildFieldLabel('Brief Biography', isDark),
              TextField(
                controller: _bioController,
                maxLines: 4,
                style: TextStyle(color: isDark ? Colors.white : Colors.black),
                decoration: _inputDecoration('Tell clients why they should hire you...', isDark),
              ),
              const SizedBox(height: 24),
              _buildFieldLabel('Available Timings', isDark),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _availableSlots.map((time) {
                  final isSelected = _selectedTimes.contains(time);
                  return ChoiceChip(
                    label: Text(time),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedTimes.add(time);
                        } else {
                          _selectedTimes.remove(time);
                        }
                      });
                    },
                    selectedColor: AppColors.primary,
                    labelStyle: TextStyle(color: isSelected ? Colors.white : (isDark ? Colors.white : Colors.black)),
                    backgroundColor: isDark ? const Color(0xFF161616) : Colors.grey[100],
                  );
                }).toList(),
              ),
              const SizedBox(height: 48),
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: _finishSetup,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    elevation: 0,
                  ),
                  child: const Text('Start Providing Services', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String label, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 10),
      child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.grey)),
    );
  }

  InputDecoration _inputDecoration(String hint, bool isDark) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
      filled: true,
      fillColor: isDark ? const Color(0xFF161616) : Colors.grey[100],
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
      contentPadding: const EdgeInsets.all(20),
    );
  }
}
