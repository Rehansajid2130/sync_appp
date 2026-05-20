import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';

class WeeklyDateRibbon extends StatelessWidget {
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateSelected;
  final List<int> conflictDays; // List of day numbers (e.g. 8, 10) that have conflicts

  const WeeklyDateRibbon({
    super.key,
    required this.selectedDate,
    required this.onDateSelected,
    required this.conflictDays,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    // Generate the current week (7 days) starting from 2 days ago to show progress
    final DateTime now = DateTime.now();
    final List<DateTime> weekDays = List.generate(7, (index) {
      return now.add(Duration(days: index - 2));
    });

    return SizedBox(
      height: 96,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: weekDays.length,
        itemBuilder: (context, index) {
          final DateTime date = weekDays[index];
          final String dayName = DateFormat('E').format(date).substring(0, 2); // e.g. "Tu", "We"
          final String dayNumber = DateFormat('d').format(date);
          final bool isSelected = date.day == selectedDate.day &&
              date.month == selectedDate.month &&
              date.year == selectedDate.year;
          
          final bool hasConflict = conflictDays.contains(date.day);

          final Color activeBgColor = isDark ? Colors.white : AppColors.textDark;
          final Color inactiveBgColor = isDark ? const Color(0xFF161616) : Colors.white;
          final Color activeDayNumberColor = isDark ? AppColors.textDark : Colors.white;
          final Color inactiveDayNumberColor = isDark ? Colors.white : AppColors.textDark;
          final Color activeDayNameColor = isDark ? Colors.black54 : Colors.white70;
          final Color borderColor = isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.06);

          final List<BoxShadow> activeShadows = isDark
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  )
                ]
              : [
                  BoxShadow(
                    color: AppColors.textDark.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 6),
                  )
                ];

          final List<BoxShadow> inactiveShadows = isDark
              ? []
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.01),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  )
                ];

          return GestureDetector(
            onTap: () => onDateSelected(date),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 58,
              margin: const EdgeInsets.only(right: 12.0),
              decoration: BoxDecoration(
                color: isSelected ? activeBgColor : inactiveBgColor,
                borderRadius: BorderRadius.circular(20.0),
                border: Border.all(
                  color: isSelected ? Colors.transparent : borderColor,
                ),
                boxShadow: isSelected ? activeShadows : inactiveShadows,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    dayName,
                    style: GoogleFonts.nunito(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? activeDayNameColor : AppColors.textMutedGray,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    dayNumber,
                    style: GoogleFonts.nunito(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: isSelected ? activeDayNumberColor : inactiveDayNumberColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Conflict dot or spacing
                  if (hasConflict)
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: AppColors.alertOrange,
                        shape: BoxShape.circle,
                      ),
                    )
                  else
                    const SizedBox(height: 6),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
