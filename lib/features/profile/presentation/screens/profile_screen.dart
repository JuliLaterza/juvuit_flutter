import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:juvuit_flutter/core/utils/colors.dart';
import 'package:juvuit_flutter/core/widgets/custom_bottom_nav_bar.dart';
import 'package:juvuit_flutter/core/utils/routes.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  void _showLogoutConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar'),
          content: const Text('¿Estás seguro que deseas cerrar la sesión?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cerrar el modal sin acción
              },
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop(); // Cerrar el modal antes de cerrar sesión
                try {
                  await FirebaseAuth.instance.signOut();
                  if (context.mounted) {
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      AppRoutes.login,
                      (route) => false,
                    );
                  }
                } catch (e) {
                  // ignore: use_build_context_synchronously
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error al cerrar sesión: $e')),
                  );
                }
              },
              child: const Text('Sí'),
            ),
          ],
        );
      },
    );
  }

  void _showSongsModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Top Canciones'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('1. Tití Me Preguntó'),
              Text('2. Me Porto Bonito'),
              Text('3. Ojitos Lindos'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cerrar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        //title: const Text('Mi Perfil'),
        centerTitle: true,
        backgroundColor: AppColors.white,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            // Foto de perfil principal
            const Center(
              child: CircleAvatar(
                radius: 80,
                /*backgroundImage: NetworkImage(
                  'https://media.licdn.com/dms/image/v2/D4D22AQEkdTUhyF1X_w/feedshare-shrink_1280/feedshare-shrink_1280/0/1685664343346?e=1739404800&v=beta&t=J3gEDOh-24-DPMSv-L1UZYssjrMGruQjn5kdHPXG8Co',
                )*/
                backgroundImage: AssetImage(
                  'assets/images/juli_barcelona.jpg'
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Nombre y edad
            const Center(
              child: Text(
                'Juli, 26',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.black,
                ),
              ),
            ),
            const SizedBox(height: 8),
            // Descripción
            const Center(
              child: Text(
                'Aquí va una descripción breve sobre el usuario. Máximo 3 líneas.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.gray,
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Iconos de preferencias
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () => _showSongsModal(context),
                  child: Column(
                    children: const [
                      Icon(Icons.music_note, color: AppColors.yellow),
                      SizedBox(height: 4),
                      Text('Top Canciones', style: TextStyle(fontSize: 12)),
                    ],
                  ),
                ),
                const SizedBox(width: 24),
                const Column(
                  children: [
                    Icon(Icons.local_bar, color: AppColors.yellow),
                    SizedBox(height: 4),
                    Text('Trago Favorito', style: TextStyle(fontSize: 12)),
                  ],
                ),
                const SizedBox(width: 24),
                const Column(
                  children: [
                    Icon(Icons.star, color: AppColors.yellow),
                    SizedBox(height: 4),
                    Text('Signo Zodiacal', style: TextStyle(fontSize: 12)),
                  ],
                ),
              ],
            ),
            const Divider(),
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
                _showLogoutConfirmationDialog(context); // Llamar al modal
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
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 3),
    );
  }
}
