import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';

class SegmentedController extends StatelessWidget {
  final List<String> segments;
  final String selectedSegment;
  final ValueChanged<String> onSelected;

  const SegmentedController({
    super.key,
    required this.segments,
    required this.selectedSegment,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: AppColors.surfaceLightGray,
        borderRadius: BorderRadius.circular(26.0),
      ),
      padding: const EdgeInsets.all(4.0),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final double segmentWidth = (constraints.maxWidth - 8.0) / segments.length;
          final int selectedIndex = segments.indexOf(selectedSegment);
          
          return Stack(
            children: [
              // Slide background animation
              AnimatedPositioned(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
                left: selectedIndex * segmentWidth,
                top: 0,
                bottom: 0,
                width: segmentWidth,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.textDark,
                    borderRadius: BorderRadius.circular(22.0),
                  ),
                ),
              ),

              // Segment text buttons
              Row(
                children: segments.map((segment) {
                  final bool isSelected = segment == selectedSegment;
                  return SizedBox(
                    width: segmentWidth,
                    height: double.infinity,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => onSelected(segment),
                      child: Center(
                        child: Text(
                          segment,
                          style: GoogleFonts.nunito(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: isSelected ? Colors.white : AppColors.textMutedGray,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          );
        },
      ),
    );
  }
}
