import 'package:flutter/material.dart';
import 'package:juvuit_flutter/core/utils/colors.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuraciones'),
        backgroundColor: AppColors.black,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            // Sección de cuenta
            const Text(
              'Cuenta',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.black,
              ),
            ),
            const SizedBox(height: 8),
            ListTile(
              leading: const Icon(Icons.person, color: AppColors.gray),
              title: const Text('Editar Perfil'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                // Navegar a edición de perfil
              },
            ),
            ListTile(
              leading: const Icon(Icons.lock, color: AppColors.gray),
              title: const Text('Privacidad'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                // Navegar a ajustes de privacidad
              },
            ),
            const Divider(),

            // Sección de notificaciones
            const Text(
              'Notificaciones',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.black,
              ),
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              activeColor: AppColors.yellow,
              contentPadding: EdgeInsets.zero,
              title: const Text('Recibir notificaciones'),
              value: true, // Cambiar según el estado actual
              onChanged: (value) {
                // Cambiar configuración de notificaciones
              },
            ),
            const Divider(),

            // Sección de ayuda
            const Text(
              'Ayuda',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.black,
              ),
            ),
            const SizedBox(height: 8),
            ListTile(
              leading: const Icon(Icons.help_outline, color: AppColors.gray),
              title: const Text('Centro de ayuda'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                // Navegar al centro de ayuda
              },
            ),
            ListTile(
              leading: const Icon(Icons.feedback_outlined, color: AppColors.gray),
              title: const Text('Enviar feedback'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                // Navegar a feedback
              },
            ),
            const Divider(),

            // Sección de cuenta avanzada
            const Text(
              'Cuenta avanzada',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.black,
              ),
            ),
            const SizedBox(height: 8),
            ListTile(
              leading: const Icon(Icons.logout, color: AppColors.gray),
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
