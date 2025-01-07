import 'package:flutter/material.dart';

class AppColors {
  // Neutrales
  static const Color black = Color(0xFF000000);
  static const Color darkGray = Color(0xFF333333);
  static const Color gray = Color(0xFF757575);
  static const Color lightGray = Color(0xFFBDBDBD);
  static const Color white = Color(0xFFFFFFFF);
  static const Color darkWhite = Color.fromARGB(255, 228, 228, 228);


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
