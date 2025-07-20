import 'package:flutter/material.dart';
import 'colors.dart';

class AppThemes {
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.light(
      background: ThemeColors.light.background,
      surface: ThemeColors.light.surface,
      primary: ThemeColors.light.primary,
      onBackground: ThemeColors.light.onBackground,
      onSurface: ThemeColors.light.onSurface,
      onPrimary: ThemeColors.light.onPrimary,
      secondary: ThemeColors.light.secondary,
      onSecondary: ThemeColors.light.onSecondary,
      error: ThemeColors.light.error,
      onError: ThemeColors.light.onError,
    ),
    scaffoldBackgroundColor: ThemeColors.light.background,
    appBarTheme: AppBarTheme(
      backgroundColor: ThemeColors.light.surface,
      foregroundColor: ThemeColors.light.onSurface,
      elevation: 0,
      scrolledUnderElevation: 0,
      iconTheme: IconThemeData(color: ThemeColors.light.onSurface),
      titleTextStyle: TextStyle(
        color: ThemeColors.light.onSurface,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
    ),
    cardTheme: CardTheme(
      color: ThemeColors.light.surface,
      elevation: 2,
      shadowColor: AppColors.black.withOpacity(0.1),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: ThemeColors.light.primary,
        foregroundColor: ThemeColors.light.onPrimary,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: ThemeColors.light.primary,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: ThemeColors.light.surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.lightGray),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.lightGray),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: ThemeColors.light.primary),
      ),
      labelStyle: TextStyle(color: ThemeColors.light.onSurface),
      hintStyle: TextStyle(color: AppColors.gray),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: ThemeColors.light.surface,
      selectedItemColor: ThemeColors.light.primary,
      unselectedItemColor: AppColors.gray,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    ),
    iconTheme: IconThemeData(
      color: ThemeColors.light.onSurface,
    ),
    textTheme: TextTheme(
      bodyLarge: TextStyle(color: ThemeColors.light.onBackground),
      bodyMedium: TextStyle(color: ThemeColors.light.onBackground),
      bodySmall: TextStyle(color: ThemeColors.light.onBackground),
      titleLarge: TextStyle(color: ThemeColors.light.onBackground),
      titleMedium: TextStyle(color: ThemeColors.light.onBackground),
      titleSmall: TextStyle(color: ThemeColors.light.onBackground),
    ),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.dark(
      background: ThemeColors.dark.background,
      surface: ThemeColors.dark.surface,
      primary: ThemeColors.dark.primary,
      onBackground: ThemeColors.dark.onBackground,
      onSurface: ThemeColors.dark.onSurface,
      onPrimary: ThemeColors.dark.onPrimary,
      secondary: ThemeColors.dark.secondary,
      onSecondary: ThemeColors.dark.onSecondary,
      error: ThemeColors.dark.error,
      onError: ThemeColors.dark.onError,
    ),
    scaffoldBackgroundColor: ThemeColors.dark.background,
    appBarTheme: AppBarTheme(
      backgroundColor: ThemeColors.dark.surface,
      foregroundColor: ThemeColors.dark.onSurface,
      elevation: 0,
      scrolledUnderElevation: 0,
      iconTheme: IconThemeData(color: ThemeColors.dark.onSurface),
      titleTextStyle: TextStyle(
        color: ThemeColors.dark.onSurface,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
    ),
    cardTheme: CardTheme(
      color: ThemeColors.dark.surface,
      elevation: 2,
      shadowColor: AppColors.black.withOpacity(0.3),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: ThemeColors.dark.primary,
        foregroundColor: ThemeColors.dark.onPrimary,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: ThemeColors.dark.primary,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: ThemeColors.dark.surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.gray),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.gray),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: ThemeColors.dark.primary),
      ),
      labelStyle: TextStyle(color: ThemeColors.dark.onSurface),
      hintStyle: TextStyle(color: AppColors.lightGray),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: ThemeColors.dark.surface,
      selectedItemColor: ThemeColors.dark.primary,
      unselectedItemColor: AppColors.lightGray,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    ),
    iconTheme: IconThemeData(
      color: ThemeColors.dark.onSurface,
    ),
    textTheme: TextTheme(
      bodyLarge: TextStyle(color: ThemeColors.dark.onBackground),
      bodyMedium: TextStyle(color: ThemeColors.dark.onBackground),
      bodySmall: TextStyle(color: ThemeColors.dark.onBackground),
      titleLarge: TextStyle(color: ThemeColors.dark.onBackground),
      titleMedium: TextStyle(color: ThemeColors.dark.onBackground),
      titleSmall: TextStyle(color: ThemeColors.dark.onBackground),
    ),
  );
} 