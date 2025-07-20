import 'package:flutter/material.dart';

class AppColors {
  // Colores base del modo nocturno
  static const Color darkBackground = Color(0xFF333333);
  static const Color lightBackground = Color(0xFFF9F9F9);
  
  // Neutrales
  static const Color black = Color(0xFF000000);
  static const Color darkGray = Color(0xFF333333);
  static const Color gray = Color(0xFF757575);
  static const Color lightGray = Color(0xFFBDBDBD);
  static const Color white = Color(0xFFFFFFFF);
  //static const Color white = Color(0xFFFFFCF2);
  static const Color darkWhite = Color.fromARGB(255, 228, 228, 228);
  static const Color darkmedium = Color.fromARGB(255, 32, 31, 34);

  // Amarillos
  static const Color yellow = Color(0xFFFFD600); // Primario
  static const Color lightYellow = Color.fromARGB(255, 255, 243, 139); // Tonalidad más clara
  static const Color darkYellow = Color(0xFFFFA000); // Tonalidad más oscura

  // Transparencia (para overlays o efectos)
  static const Color transparent = Colors.transparent;

  // Método para definir opacidad a cualquier color
  static Color withOpacity(Color color, double opacity) {
    return color.withOpacity(opacity);
  }
}

// Clase para manejar colores por tema
class ThemeColors {
  final Color background;
  final Color surface;
  final Color primary;
  final Color onBackground;
  final Color onSurface;
  final Color onPrimary;
  final Color secondary;
  final Color onSecondary;
  final Color error;
  final Color onError;

  const ThemeColors({
    required this.background,
    required this.surface,
    required this.primary,
    required this.onBackground,
    required this.onSurface,
    required this.onPrimary,
    required this.secondary,
    required this.onSecondary,
    required this.error,
    required this.onError,
  });

  // Tema claro
  static const ThemeColors light = ThemeColors(
    background: AppColors.lightBackground,
    surface: AppColors.white,
    primary: AppColors.yellow,
    onBackground: AppColors.black,
    onSurface: AppColors.black,
    onPrimary: AppColors.black,
    secondary: AppColors.lightYellow,
    onSecondary: AppColors.black,
    error: Colors.red,
    onError: AppColors.white,
  );

  // Tema oscuro
  static const ThemeColors dark = ThemeColors(
    background: AppColors.darkBackground,
    surface: AppColors.darkGray,
    primary: AppColors.yellow,
    onBackground: AppColors.white,
    onSurface: AppColors.white,
    onPrimary: AppColors.black,
    secondary: AppColors.lightYellow,
    onSecondary: AppColors.black,
    error: Colors.red,
    onError: AppColors.white,
  );
}
