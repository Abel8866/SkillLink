import 'package:flutter/material.dart';

import 'app_colors.dart';

ThemeData buildAppTheme() {
  final scheme =
      ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.light,
      ).copyWith(
        primary: AppColors.primary,
        onPrimary: Colors.white,
        secondary: AppColors.secondary,
        onSecondary: Colors.white,
        surface: AppColors.surface,
        onSurface: AppColors.textPrimary,
        error: AppColors.error,
      );
  final baseTextTheme = ThemeData.light().textTheme;
  final textTheme = baseTextTheme.copyWith(
    displaySmall: baseTextTheme.displaySmall?.copyWith(
      color: AppColors.textPrimary,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.5,
    ),
    headlineSmall: baseTextTheme.headlineSmall?.copyWith(
      color: AppColors.textPrimary,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.25,
    ),
    titleLarge: baseTextTheme.titleLarge?.copyWith(
      color: AppColors.textPrimary,
      fontWeight: FontWeight.w700,
    ),
    titleMedium: baseTextTheme.titleMedium?.copyWith(
      color: AppColors.textPrimary,
      fontWeight: FontWeight.w600,
    ),
    bodyLarge: baseTextTheme.bodyLarge?.copyWith(
      color: AppColors.textPrimary,
      height: 1.45,
    ),
    bodyMedium: baseTextTheme.bodyMedium?.copyWith(
      color: AppColors.textPrimary,
      height: 1.4,
    ),
    bodySmall: baseTextTheme.bodySmall?.copyWith(
      color: AppColors.textSecondary,
      height: 1.35,
    ),
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    textTheme: textTheme,
    scaffoldBackgroundColor: AppColors.background,
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.surface,
      foregroundColor: AppColors.textPrimary,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      titleTextStyle: textTheme.titleLarge,
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      color: AppColors.surface,
      surfaceTintColor: Colors.transparent,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.border),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: AppColors.surface,
      indicatorColor: AppColors.secondary.withValues(alpha: 0.18),
      elevation: 0,
      height: 72,
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return textTheme.labelSmall?.copyWith(
          color: selected ? AppColors.primary : AppColors.textSecondary,
          fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
        );
      }),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: AppColors.surface,
      selectedColor: AppColors.secondary.withValues(alpha: 0.18),
      side: const BorderSide(color: AppColors.border),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
    ),
  );
}
