import 'package:flutter/material.dart';

class AppColors {
  // Light Mode Colors (Updated to Deep Teal Design System)
  static const Color primary = deepTeal; // Brand Green -> Deep Teal
  static const Color primaryLight = pastelGreen; // Mint -> Pastel Green
  static const Color primaryDark = Color(0xFF0A4D4F);

  static const Color backgroundLight = Color(0xFFFFFFFF);
  static const Color surfaceLight = offWhite;

  static const Color textPrimaryLight = charcoalDark;
  static const Color textSecondaryLight = mutedGray;
  static const Color textMutedLight = Color(0xFF9CA3AF);

  // Dark Mode Colors (Midnight Theme)
  static const Color backgroundDark = Color(0xFF090909);
  static const Color surfaceDark = Color(0xFF161616);
  static const Color surfaceElevatedDark = Color(0xFF1E1E1E);
  static const Color surfaceContentDark = Color(0xFF121211);
  static const Color borderDark = Color(0xFF262626);

  static const Color textPrimaryDark = Color(0xFFFFFFFF);
  static const Color textSecondaryDark = Color(0xFFBDBDBD);
  static const Color textMutedDark = Color(0xFF757575);

  // Status Colors
  static const Color error = Color(0xFFEF4444); // Negative
  static const Color warning = Color(0xFFF59E0B); // Warning

  // New Design System Palette - Pastel-Morphic Specification (v2)
  static const Color deepTeal = Color(0xFF0F686B); // Primary brand color
  static const Color charcoalDark = Color(0xFF111111); // Primary text/focus
  static const Color mutedGray = Color(0xFF7A7A7A); // Subtitles/borders
  static const Color offWhite = Color(0xFFF9F9FB); // Backgrounds/input canvas

  // Pastel Category Card Tokens
  static const Color pastelPink = Color(0xFFF7E6DF); // Vacation / Time Off
  static const Color pastelGreen = Color(0xFFD4E6DF); // All Days / Open Shifts
  static const Color pastelBlue = Color(0xFFD4DAF7); // No Shift / Availability
  static const Color pastelYellow = Color(0xFFF3E197); // Shift Transfers

  // Legacy Coexistence Mappings (Safeguard Aliases)
  static const Color primaryPink = deepTeal; // Map legacy to primary accent
  static const Color secondaryGreen = pastelGreen;
  static const Color accentYellow = pastelYellow;
  static const Color alertOrange = Color(0xFFFF8E53); // Retain warning pop
  static const Color skyBlue = pastelBlue;
  static const Color textDark = charcoalDark;
  static const Color textMutedGray = mutedGray;
  static const Color surfaceLightGray = offWhite;
}
