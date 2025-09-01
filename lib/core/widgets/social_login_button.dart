import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:juvuit_flutter/core/utils/colors.dart';

class SocialLoginButton extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback onPressed;

  const SocialLoginButton({
    super.key,
    required this.icon,
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    
    // Determinar si es Google o Apple para aplicar colores específicos
    final isGoogle = icon == FontAwesomeIcons.google;
    final isApple = icon == FontAwesomeIcons.apple;
    
    Color iconColor = theme.colorScheme.onSurface; // Valor por defecto
    Color backgroundColor;
    Color textColor;
    
    if (isGoogle) {
      // Google: color azul típico
      iconColor = const Color(0xFF4285F4); // Azul de Google
      backgroundColor = Colors.white;
      textColor = Colors.black87;
    } else if (isApple) {
      // Apple: negro en light mode, blanco en dark mode
      iconColor = isDarkMode ? Colors.white : Colors.black;
      backgroundColor = isDarkMode ? Colors.black : Colors.white;
      textColor = isDarkMode ? Colors.white : Colors.black;
    } else {
      // Otros iconos: usar colores por defecto
      iconColor = theme.colorScheme.onSurface;
      backgroundColor = theme.colorScheme.surface;
      textColor = theme.colorScheme.onSurface;
    }

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: textColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: isGoogle || isApple 
                ? BorderSide(color: Colors.grey.shade300, width: 1)
                : BorderSide.none,
          ),
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
        icon: FaIcon(
          icon,
          size: isApple ? 24 : 20, // Apple más grande, otros iconos tamaño normal
          color: iconColor,
        ),
        label: Text(
          text,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
      ),
    );
  }
}
