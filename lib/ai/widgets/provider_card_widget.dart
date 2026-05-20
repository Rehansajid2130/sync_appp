import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../models/chat_models.dart';

/// Simple provider card displayed inline in the chat.
class ProviderCardWidget extends StatelessWidget {
  final ProviderResult provider;
  final bool isSelected;
  final VoidCallback? onTap;

  const ProviderCardWidget({
    super.key,
    required this.provider,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    final Color cardBgColor = isDark ? const Color(0xFF161616) : Colors.white;
    final Color borderSideColor = isSelected
        ? AppColors.deepTeal
        : (isDark ? Colors.white.withOpacity(0.06) : Colors.black.withOpacity(0.04));
    final double borderSideWidth = isSelected ? 2.0 : 1.0;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(20.0),
        border: Border.all(
          color: borderSideColor,
          width: borderSideWidth,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20.0),
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name + Rating
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white.withOpacity(0.08) : AppColors.surfaceLightGray,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.person_rounded,
                        size: 18,
                        color: isDark ? Colors.white70 : AppColors.textDark,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        provider.name,
                        style: GoogleFonts.nunito(
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                          color: isDark ? Colors.white : AppColors.textDark,
                          letterSpacing: -0.4,
                        ),
                      ),
                    ),
                    const Icon(Icons.star_rounded, color: AppColors.pastelYellow, size: 18),
                    const SizedBox(width: 4),
                    Text(
                      '${provider.rating}',
                      style: GoogleFonts.nunito(
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                        color: isDark ? Colors.white.withOpacity(0.9) : AppColors.textDark,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Distance + ETA + Availability
                Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.location_on_outlined, size: 14, color: AppColors.mutedGray),
                        const SizedBox(width: 4),
                        Text(
                          '${provider.distanceKm} km',
                          style: GoogleFonts.nunito(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.mutedGray,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.access_time_outlined, size: 14, color: AppColors.mutedGray),
                        const SizedBox(width: 4),
                        Text(
                          '${provider.etaMinutes} min ETA',
                          style: GoogleFonts.nunito(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.mutedGray,
                          ),
                        ),
                      ],
                    ),
                    if (provider.available)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.pastelGreen.withOpacity(0.12)
                              : AppColors.pastelGreen.withOpacity(0.4),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Available',
                          style: GoogleFonts.nunito(
                            fontSize: 11,
                            color: isDark ? AppColors.pastelGreen : AppColors.deepTeal,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 10),

                // Match reason
                Text(
                  provider.matchReason,
                  style: GoogleFonts.nunito(
                    fontSize: 12.5,
                    color: isDark ? AppColors.pastelBlue : AppColors.deepTeal,
                    fontWeight: FontWeight.w600,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 12),

                // Price
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${provider.distanceKm} km away • ${provider.etaMinutes} min ETA',
                      style: GoogleFonts.nunito(
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                        color: isDark ? Colors.white.withOpacity(0.7) : AppColors.textDark,
                      ),
                    ),
                    if (isSelected)
                      const Icon(
                        Icons.check_circle_rounded,
                        color: AppColors.deepTeal,
                        size: 22,
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// A group of provider cards shown inline in chat.
class ProviderCardList extends StatelessWidget {
  final List<ProviderResult> providers;
  final ProviderResult? selectedProvider;
  final ValueChanged<ProviderResult>? onProviderSelected;

  const ProviderCardList({
    super.key,
    required this.providers,
    this.selectedProvider,
    this.onProviderSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: providers.map((provider) {
        return ProviderCardWidget(
          provider: provider,
          isSelected: selectedProvider?.id == provider.id,
          onTap: () => onProviderSelected?.call(provider),
        );
      }).toList(),
    );
  }
}
