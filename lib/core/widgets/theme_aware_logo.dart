import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/theme_provider.dart';

class ThemeAwareLogo extends StatelessWidget {
  final double? width;
  final double? height;
  final BoxFit? fit;

  const ThemeAwareLogo({
    super.key,
    this.width,
    this.height,
    this.fit,
  });

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    // Determinar qué logo usar según el tema
    String logoPath;
    if (themeProvider.isDarkMode) {
      logoPath = 'assets/images/homescreen/witu_logo_dark.png';
    } else {
      logoPath = 'assets/images/homescreen/logo_witu.png';
    }

    return Image.asset(
      logoPath,
      width: width,
      height: height,
      fit: fit ?? BoxFit.contain,
      alignment: Alignment.center,
    );
  }
}

// Widget específico para el header (tamaño fijo común)
class HeaderLogo extends StatelessWidget {
  const HeaderLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return const ThemeAwareLogo(
      height: 60,
      width: 100,
    );
  }
}

// Widget para logos más grandes (como en pantallas de login)
class LargeLogo extends StatelessWidget {
  const LargeLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return const ThemeAwareLogo(
      width: 160,
      height: 60,
    );
  }
} 