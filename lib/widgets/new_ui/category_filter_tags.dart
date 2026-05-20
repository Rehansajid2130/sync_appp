import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';

class CategoryFilterTags extends StatelessWidget {
  final List<Map<String, dynamic>> categories;
  final String selectedCategory;
  final ValueChanged<String> onSelected;

  const CategoryFilterTags({
    super.key,
    required this.categories,
    required this.selectedCategory,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 96,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final cat = categories[index];
          final String name = cat['name'] ?? '';
          final IconData icon = cat['icon'] ?? Icons.category;
          final bool isSelected = name.toLowerCase() == selectedCategory.toLowerCase();

          return GestureDetector(
            onTap: () => onSelected(name),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 80,
              margin: const EdgeInsets.only(right: 12.0),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.charcoalDark : Colors.transparent,
                borderRadius: BorderRadius.circular(20.0),
                border: Border.all(
                  color: isSelected ? Colors.transparent : Colors.black.withOpacity(0.06),
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AppColors.charcoalDark.withOpacity(0.12),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        )
                      ]
                    : [],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Colors.white.withOpacity(0.15)
                          : AppColors.offWhite,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      icon,
                      color: isSelected ? Colors.white : AppColors.mutedGray,
                      size: 20,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    name,
                    style: GoogleFonts.nunito(
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                      color: isSelected ? Colors.white : AppColors.mutedGray,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
