import 'package:flutter/material.dart';
import 'package:juvuit_flutter/core/widgets/custom_bottom_nav_bar.dart';


class ChatsScreen extends StatelessWidget {
  const ChatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chats'),
      ),
      body: const Center(
        child: Text('Contenido de Chats'),
      ),
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 2),
    );
  }
}
