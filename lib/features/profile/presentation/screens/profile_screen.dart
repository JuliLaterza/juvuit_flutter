import 'package:flutter/material.dart';
import 'package:juvuit_flutter/core/utils/colors.dart';
import 'package:juvuit_flutter/core/widgets/custom_bottom_nav_bar.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Perfil'),
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
                backgroundImage: NetworkImage(
                  'https://instagram.fepa4-1.fna.fbcdn.net/v/t51.29350-15/459681884_880058476890597_7386454259925480083_n.jpg?stp=dst-jpg_e35_p1080x1080_tt6&efg=eyJ2ZW5jb2RlX3RhZyI6ImltYWdlX3VybGdlbi4xNDQweDE1Nzguc2RyLmYyOTM1MC5kZWZhdWx0X2ltYWdlIn0&_nc_ht=instagram.fepa4-1.fna.fbcdn.net&_nc_cat=109&_nc_oc=Q6cZ2AEqFKt497Jx-0TWhQtJ6iOG8ZQhnRaxhdS7Jm5mN6vP7010C3sFHNBMSsgdBHEHzrgZ-eQVuVWGhzwijIPOKqMv&_nc_ohc=M46KxhXZNWIQ7kNvgFn5xzq&_nc_gid=e78e1de8dd984f378d232f6aa5a8dca9&edm=AP4sbd4BAAAA&ccb=7-5&ig_cache_key=MzQ1Nzk5MDA0MDE2MjIxNTY0OQ%3D%3D.3-ccb7-5&oh=00_AYBU9xI1tA_WXMclYkiR497lz0GhguJh4wAqJXsFBamFhw&oe=6787CB3F&_nc_sid=7a9f4b', // Cambiar por la URL real de la foto
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Nombre y edad
            const Center(
              child: Text(
                'Agus, 23', // Sustituir por datos reales
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
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  children: [
                    Icon(Icons.music_note, color: AppColors.yellow),
                    SizedBox(height: 4),
                    Text('Top Canciones', style: TextStyle(fontSize: 12)),
                  ],
                ),
                SizedBox(width: 24),
                Column(
                  children: [
                    Icon(Icons.local_bar, color: AppColors.yellow),
                    SizedBox(height: 4),
                    Text('Trago Favorito', style: TextStyle(fontSize: 12)),
                  ],
                ),
                SizedBox(width: 24),
                Column(
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
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 3),
    );
  }
}
