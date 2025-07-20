import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/theme_provider.dart';

class ThemeToggleButton extends StatelessWidget {
  final bool showLabel;
  final String? label;
  final String? subtitle;
  final IconData? icon;
  final bool showIcon;

  const ThemeToggleButton({
    super.key,
    this.showLabel = true,
    this.label,
    this.subtitle,
    this.icon,
    this.showIcon = true,
  });

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final theme = Theme.of(context);

    if (showLabel) {
      return SwitchListTile(
        activeColor: theme.colorScheme.primary,
        contentPadding: EdgeInsets.zero,
        title: Text(label ?? 'Modo nocturno'),
        subtitle: subtitle != null ? Text(subtitle!) : null,
        value: themeProvider.isDarkMode,
        onChanged: (value) {
          themeProvider.toggleTheme();
        },
      );
    } else {
      return IconButton(
        onPressed: () {
          themeProvider.toggleTheme();
        },
        icon: Icon(
          icon ?? (themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode),
          color: theme.colorScheme.onSurface,
        ),
        tooltip: themeProvider.isDarkMode ? 'Cambiar a modo claro' : 'Cambiar a modo oscuro',
      );
    }
  }
}

// Widget para mostrar el estado actual del tema
class ThemeStatusWidget extends StatelessWidget {
  const ThemeStatusWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.colorScheme.outline.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
            size: 16,
            color: theme.colorScheme.onSurface,
          ),
          const SizedBox(width: 4),
          Text(
            themeProvider.isDarkMode ? 'Oscuro' : 'Claro',
            style: TextStyle(
              fontSize: 12,
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
} 