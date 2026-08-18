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
        displayMedium: TextStyle(
          color: _schemeLight.primary,
          fontWeight: FontWeight.bold,
        ),
        headlineMedium: TextStyle(
          color: _schemeLight.primary,
          fontWeight: FontWeight.bold,
        ),
        titleMedium: TextStyle(color: _schemeLight.primary),
        bodyMedium: TextStyle(color: _schemeLight.secondary),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: _schemeLight.onSurface,
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
        backgroundColor: _schemeLight.surface,
        selectedItemColor: _schemeLight.onSurface,
        unselectedItemColor: _schemeLight.primary,
        selectedIconTheme: IconThemeData(color: _schemeLight.onSurface),
        unselectedIconTheme: IconThemeData(color: _schemeLight.primary),
        selectedLabelStyle: TextStyle(color: _schemeLight.onSurface),
        unselectedLabelStyle: TextStyle(color: _schemeLight.primary),
        type: BottomNavigationBarType.fixed,
      ),
    );
  }

    static ThemeData get themeDark {
    return ThemeData(
      useMaterial3: true,
      colorScheme: _schemeDark,
      scaffoldBackgroundColor: _schemeDark.surface,
      textTheme: TextTheme(
        displayMedium: TextStyle(
          color: _schemeDark.primary,
          fontWeight: FontWeight.bold,
        ),
        headlineMedium: TextStyle(
          color: _schemeDark.primary,
          fontWeight: FontWeight.bold,
        ),
        titleMedium: TextStyle(color: _schemeDark.primary),
        bodyMedium: TextStyle(color: _schemeDark.secondary),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: _schemeDark.onSurface,
        foregroundColor: _schemeDark.primary,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith((_) {
            return _schemeDark.onSurface;
          }),
          foregroundColor: WidgetStateProperty.resolveWith((_) {
            return _schemeDark.surface;
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
            return _schemeDark.onSurface;
          }),
        ),
      ),
      inputDecorationTheme: InputDecorationThemeData(
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
        iconColor: _schemeDark.secondary,
        prefixIconColor: _schemeDark.secondary,
        suffixIconColor: _schemeDark.secondary,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: _schemeDark.surface,
        selectedItemColor: _schemeDark.onSurface,
        unselectedItemColor: _schemeDark.primary,
        selectedIconTheme: IconThemeData(color: _schemeDark.onSurface),
        unselectedIconTheme: IconThemeData(color: _schemeDark.primary),
        selectedLabelStyle: TextStyle(color: _schemeDark.onSurface),
        unselectedLabelStyle: TextStyle(color: _schemeDark.primary),
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
