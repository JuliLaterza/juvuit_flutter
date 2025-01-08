import 'package:flutter/material.dart';

import '../../../../core/widgets/custom_bottom_nav_bar.dart';


class MatchingScreen extends StatelessWidget {
  const MatchingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Matching'),
      ),
      body: const Center(
        child: Text('Contenido de Matching'),
      ),
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 1),
    );
  }
}
