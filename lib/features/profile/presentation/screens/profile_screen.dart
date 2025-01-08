import 'package:flutter/material.dart';
import 'package:juvuit_flutter/core/widgets/custom_bottom_nav_bar.dart';


class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil'),
      ),
      body: const Center(
        child: Text('Contenido de Perfil'),
      ),
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 3),
    );
  }
}
