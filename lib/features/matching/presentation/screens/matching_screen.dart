import 'package:flutter/material.dart';
import 'package:juvuit_flutter/core/widgets/custom_bottom_nav_bar.dart';
import '../../widgets/matching_loader.dart';

class MatchingScreen extends StatelessWidget {
  const MatchingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Eventos Asistidos'),
        centerTitle: true,
      ),
      body: MatchingLoader(),
      bottomNavigationBar: CustomBottomNavBar(currentIndex: 1),
    );
  }
}
