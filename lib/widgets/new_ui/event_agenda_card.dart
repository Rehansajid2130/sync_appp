import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';

class EventAgendaCard extends StatelessWidget {
  final String time;
  final String title;
  final String? hyperlinkText;
  final VoidCallback? onHyperlinkTap;
  final bool hasConflict;
  final String? status;
  final VoidCallback? onCancel;
  final VoidCallback? onReschedule;

  const EventAgendaCard({
    super.key,
    required this.time,
    required this.title,
    this.hyperlinkText,
    this.onHyperlinkTap,
    this.hasConflict = false,
    this.status,
    this.onCancel,
    this.onReschedule,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF161616) : Colors.white,
        borderRadius: BorderRadius.circular(20.0),
        border: Border.all(
          color: hasConflict
              ? AppColors.alertOrange.withOpacity(0.2)
              : Colors.black.withOpacity(0.04),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.01),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Time and Status badge
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: hasConflict
                  ? AppColors.alertOrange.withOpacity(0.12)
                  : (isDark
                      ? AppColors.deepTeal.withOpacity(0.3)
                      : AppColors.secondaryGreen.withOpacity(0.4)),
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Text(
              time,
              style: GoogleFonts.nunito(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: hasConflict
                    ? AppColors.alertOrange
                    : (isDark ? AppColors.pastelGreen : AppColors.deepTeal),
              ),
              ),
            ),
            if (status != null) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: status == 'Pending' ? Colors.amber.withOpacity(0.15) : AppColors.deepTeal.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Text(
                  status!,
                  style: GoogleFonts.nunito(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: status == 'Pending' ? Colors.amber.shade700 : AppColors.deepTeal,
                  ),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 12),
          
          // Title
          Text(
            title,
            style: GoogleFonts.nunito(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: hasConflict ? AppColors.alertOrange : (isDark ? Colors.white : AppColors.textDark),
            ),
          ),
          
          // Extra Details
          if (hasConflict) ...[
            const SizedBox(height: 6),
            Text(
              "Another booking is scheduled at this time. Tap to resolve.",
              style: GoogleFonts.nunito(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textMutedGray,
              ),
            ),
          ] else if (hyperlinkText != null) ...[
            const SizedBox(height: 8),
            GestureDetector(
              onTap: onHyperlinkTap,
              child: Row(
                children: [
                  const Icon(
                    Icons.link,
                    size: 14,
                    color: AppColors.deepTeal,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    hyperlinkText!,
                    style: GoogleFonts.nunito(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.deepTeal,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ],
              ),
            ),
          ],
          
          // Cancel/Reschedule Actions
          if (onCancel != null || onReschedule != null) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                if (onReschedule != null)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: onReschedule,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.deepTeal,
                        side: const BorderSide(color: AppColors.deepTeal),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                      child: Text(
                        "Reschedule",
                        style: GoogleFonts.nunito(fontWeight: FontWeight.w700, fontSize: 13),
                      ),
                    ),
                  ),
                if (onReschedule != null && onCancel != null)
                  const SizedBox(width: 12),
                if (onCancel != null)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: onCancel,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red.shade400,
                        side: BorderSide(color: Colors.red.shade200),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                      child: Text(
                        "Cancel",
                        style: GoogleFonts.nunito(fontWeight: FontWeight.w700, fontSize: 13),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
