import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:juvuit_flutter/core/services/theme_provider.dart';
import 'package:juvuit_flutter/core/widgets/theme_toggle_button.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuraciones'),
        backgroundColor: theme.colorScheme.surface,
        foregroundColor: theme.colorScheme.onSurface,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            // Sección de cuenta
            Text(
              'Cuenta',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onBackground,
              ),
            ),
            const SizedBox(height: 8),
            ListTile(
              leading: Icon(Icons.person, color: theme.colorScheme.onSurface.withOpacity(0.6)),
              title: const Text('Editar Perfil'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                // Navegar a edición de perfil
              },
            ),
            ListTile(
              leading: Icon(Icons.lock, color: theme.colorScheme.onSurface.withOpacity(0.6)),
              title: const Text('Privacidad'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                // Navegar a ajustes de privacidad
              },
            ),
            const Divider(),

            // Sección de apariencia
            Text(
              'Apariencia',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onBackground,
              ),
            ),
            const SizedBox(height: 8),
            const ThemeToggleButton(
              label: 'Modo nocturno',
              subtitle: 'Cambiar entre tema claro y oscuro',
            ),
            const Divider(),

            // Sección de notificaciones
            Text(
              'Notificaciones',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onBackground,
              ),
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              activeColor: theme.colorScheme.primary,
              contentPadding: EdgeInsets.zero,
              title: const Text('Recibir notificaciones'),
              value: true, // Cambiar según el estado actual
              onChanged: (value) {
                // Cambiar configuración de notificaciones
              },
            ),
            const Divider(),

            // Sección de ayuda
            Text(
              'Ayuda',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onBackground,
              ),
            ),
            const SizedBox(height: 8),
            ListTile(
              leading: Icon(Icons.help_outline, color: theme.colorScheme.onSurface.withOpacity(0.6)),
              title: const Text('Centro de ayuda'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                // Navegar al centro de ayuda
              },
            ),
            ListTile(
              leading: Icon(Icons.feedback_outlined, color: theme.colorScheme.onSurface.withOpacity(0.6)),
              title: const Text('Enviar feedback'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                // Navegar a feedback
              },
            ),
            const Divider(),

            // Sección de cuenta avanzada
            Text(
              'Cuenta avanzada',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onBackground,
              ),
            ),
            const SizedBox(height: 8),
            ListTile(
              leading: Icon(Icons.logout, color: theme.colorScheme.onSurface.withOpacity(0.6)),
              title: const Text('Cerrar sesión'),
              onTap: () {
                // Lógica para cerrar sesión
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.red),
              title: const Text('Eliminar cuenta'),
              titleTextStyle: const TextStyle(color: Colors.red),
              onTap: () {
                // Lógica para eliminar cuenta
              },
            ),
          ],
        ),
      ),
    );
  }
}
