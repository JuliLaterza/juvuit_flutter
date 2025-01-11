import 'package:flutter/material.dart';
import 'package:juvuit_flutter/core/utils/colors.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuraciones'),
        backgroundColor: AppColors.white,
      ),
      body: const Center(
        child: Text('Pantalla de configuraciones'),
      ),
    );
  }
}
