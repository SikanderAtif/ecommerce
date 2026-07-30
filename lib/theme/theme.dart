import 'package:ecommerce/theme/colors.dart';
import 'package:flutter/material.dart';

abstract class AppTheme {
  static final ColorScheme _schemeLight = ColorScheme.light(
    primary: AppColors.primaryLight,
    secondary: AppColors.secondaryLight,
    surface: AppColors.surfaceLight,
    onSurface: AppColors.onSurfaceLight,
  );

  static final ColorScheme _schemeDark = ColorScheme.dark(
    primary: AppColors.primaryDark,
    secondary: AppColors.secondaryDark,
    surface: AppColors.surfaceDark,
    onSurface: AppColors.onSurfaceDark,
  );

  static ThemeData get themeLight {
    return ThemeData(
      useMaterial3: true,
      colorScheme: _schemeLight,
      scaffoldBackgroundColor: _schemeLight.surface,
      textTheme: TextTheme(
        displayMedium: TextStyle(color: _schemeLight.primary, fontWeight: FontWeight.bold),
        headlineMedium: TextStyle(color: _schemeLight.primary, fontWeight: FontWeight.bold),
        bodyMedium: TextStyle(color: _schemeLight.secondary)
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: _schemeLight.surface,
        foregroundColor: _schemeLight.primary,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith((_) {
            return _schemeLight.onSurface;
          }),
          foregroundColor: WidgetStateProperty.resolveWith((_) {
            return _schemeLight.surface;
          }),
          padding: WidgetStateProperty.resolveWith((_) {
            return EdgeInsets.all(12);
          }),
          shape: WidgetStateProperty.resolveWith((_) {
            return RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            );
          }),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: ButtonStyle(
          foregroundColor: WidgetStateProperty.resolveWith((_) {
            return _schemeLight.onSurface;
          }),
        ),
      ),
      inputDecorationTheme: InputDecorationThemeData(
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
        iconColor: _schemeLight.secondary,
        prefixIconColor: _schemeLight.secondary,
        suffixIconColor: _schemeLight.secondary,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        selectedItemColor: _schemeLight.onSurface,
        unselectedItemColor: _schemeLight.primary,
      ),
    );
  }
}
