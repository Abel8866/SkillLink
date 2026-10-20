/// SkillLink color palette.
/// Primary: #142B4A (deep navy blue)
/// Secondary: #16B8A6 (teal)
/// Background: #F7F9FC
/// Surface: #FFFFFF
/// Primary text: #202938
/// Secondary text: #6B7280
/// Border: #E5EAF1
/// Success: #16A34A
/// Warning: #F59E0B
/// Error: #DC2626
library;

import 'package:flutter/material.dart';

class AppColors {
  // Primary brand colors
  static const Color primary = Color(0xFF142B4A);
  static const Color primaryLight = Color(0xFF1E3A5F);
  static const Color primaryDark = Color(0xFF0D1B33);
  static const Color secondary = Color(0xFF16B8A6);
  static const Color secondaryLight = Color(0xFF2DD4C0);
  static const Color secondaryDark = Color(0xFF119282);

  // Surface colors
  static const Color background = Color(0xFFF7F9FC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF0F4F8);
  static const Color surfaceContainerHighest = Color(0xFFE8EEF4);

  // Text colors
  static const Color textPrimary = Color(0xFF202938);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textOnPrimary = Color(0xFFFFFFFF);
  static const Color textOnSecondary = Color(0xFFFFFFFF);

  // Border/divider
  static const Color border = Color(0xFFE5EAF1);
  static const Color divider = Color(0xFFE5EAF1);

  // Status colors
  static const Color success = Color(0xFF16A34A);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFDC2626);

  // Status with alpha variants
  static const Color successLight = Color(0x1A16A34A);
  static const Color warningLight = Color(0x1AF59E0B);
  static const Color errorLight = Color(0x1ADC2626);

  // Ethiopia brand colors (for accent usage)
  static const Color ethiopiaGreen = Color(0xFF009A44);
  static const Color ethiopiaYellow = Color(0xFFFEDD00);
  static const Color ethiopiaRed = Color(0xFFDA020E);
  static const Color ethiopiaBlue = Color(0xFF0033A0);
}
