// ignore_for_file: prefer_const_declarations

import 'package:flutter/material.dart';
import 'package:juvuit_flutter/core/widgets/custom_bottom_nav_bar.dart';
import 'package:juvuit_flutter/core/utils/routes.dart';

class ChatsScreen extends StatelessWidget {
  const ChatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chats'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Container(
            height: 100,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 10,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: CircleAvatar(
                    radius: 35,
                    backgroundColor: Colors.grey.shade300,
                    child: const Icon(Icons.person, size: 35, color: Colors.white),
                  ),
                );
              },
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: 10,
              itemBuilder: (context, index) {
                final personName = 'Persona ${index + 1}'; // Nombre de ejemplo
                final personPhotoUrl = 'https://via.placeholder.com/150'; // URL ficticia

                return ListTile(
                  leading: CircleAvatar(
                    radius: 25,
                    backgroundColor: Colors.grey.shade300,
                    child: const Icon(Icons.person, color: Colors.white),
                  ),
                  title: Text(personName),
                  subtitle: Text('Último mensaje de esta persona'),
                  trailing: Text(
                    '12:34 PM',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                  ),
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      AppRoutes.chat,
                      arguments: {
                        'personName': personName,
                        'personPhotoUrl': personPhotoUrl,
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 2),
    );
  }
}
