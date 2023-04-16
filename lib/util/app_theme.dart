import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

class AppTheme {
  static ThemeData darkTheme = ThemeData(
    fontFamily: GoogleFonts.nunito().fontFamily,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      onSecondary: AppColors.onSecondary,
      background: AppColors.background,
      onBackground: AppColors.onBackground,
      surface: AppColors.background,
      onSurface: AppColors.onBackground,
    ),
    textTheme: const TextTheme(
      titleLarge: TextStyle(
        color: AppColors.onBackground,
        fontSize: 14,
      ),
      titleSmall: TextStyle(
        color: AppColors.fontSecondary,
        fontSize: 13,
      ),
    ),
    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5),
        ),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.background,
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 14,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5),
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5),
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.onBackground,
        backgroundColor: Colors.transparent,
      ),
    ),
    inputDecorationTheme: const InputDecorationTheme(
      border: OutlineInputBorder(
        borderSide: BorderSide(
          color: AppColors.fontSecondary,
        ),
      ),
      contentPadding: EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 14,
      ),
      suffixIconColor: AppColors.primary,
      hintStyle: TextStyle(
        color: AppColors.fontSecondary,
        fontWeight: FontWeight.w500,
        fontSize: 15,
      ),
    ),
    useMaterial3: true,
  );
}
