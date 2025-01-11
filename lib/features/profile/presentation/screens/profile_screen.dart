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
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // Navegar a la pantalla de configuraciones
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SettingsScreen(), // Crear esta pantalla
                ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Foto de perfil principal
              CircleAvatar(
                radius: 80,
                backgroundImage: NetworkImage(
                  'https://via.placeholder.com/150', // Cambiar por la URL real de la foto
                ),
              ),
              const SizedBox(height: 16),
              // Nombre y edad
              Text(
                'Nombre Usuario, 25', // Sustituir por datos reales
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.black,
                ),
              ),
              const SizedBox(height: 8),
              // Descripción
              Text(
                'Aquí va una descripción breve sobre el usuario. Máximo 3 líneas.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.gray,
                ),
              ),
              const SizedBox(height: 16),
              // Iconos de preferencias
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Column(
                    children: const [
                      Icon(Icons.music_note, color: AppColors.yellow),
                      SizedBox(height: 4),
                      Text('Top Canciones', style: TextStyle(fontSize: 12)),
                    ],
                  ),
                  const SizedBox(width: 24),
                  Column(
                    children: const [
                      Icon(Icons.local_bar, color: AppColors.yellow),
                      SizedBox(height: 4),
                      Text('Trago Favorito', style: TextStyle(fontSize: 12)),
                    ],
                  ),
                  const SizedBox(width: 24),
                  Column(
                    children: const [
                      Icon(Icons.star, color: AppColors.yellow),
                      SizedBox(height: 4),
                      Text('Signo Zodiacal', style: TextStyle(fontSize: 12)),
                    ],
                  ),
                ],
              ),
              const Spacer(),
              // Botón Editar Perfil
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // Lógica para editar perfil
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.yellow,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text(
                    'Editar Perfil',
                    style: TextStyle(
                      color: AppColors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Botón Cerrar Sesión
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    // Lógica para cerrar sesión
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.black),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text(
                    'Cerrar Sesión',
                    style: TextStyle(
                      color: AppColors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 3),
    );
  }
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuraciones'),
        backgroundColor: AppColors.black,
      ),
      body: const Center(
        child: Text('Pantalla de configuraciones'),
      ),
    );
  }
}
