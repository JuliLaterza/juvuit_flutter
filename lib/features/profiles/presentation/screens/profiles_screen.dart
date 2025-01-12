import 'package:flutter/material.dart';
import 'package:card_swiper/card_swiper.dart';

class ProfilesScreen extends StatefulWidget {
  const ProfilesScreen({super.key});

  @override
  State<ProfilesScreen> createState() => _ProfilesScreenState();
}

class _ProfilesScreenState extends State<ProfilesScreen> {
  final SwiperController swiperController = SwiperController();

  List<Map<String, dynamic>> attendees = [
    {
      'image': 'https://via.placeholder.com/150',
      'name': 'Alex',
      'age': 25,
      'description': 'Amante de la música y los viajes.'
    },
    {
      'image': 'https://via.placeholder.com/150',
      'name': 'Maria',
      'age': 30,
      'description': 'Fan de los festivales de rock.'
    },
    {
      'image': null, // Este no tiene imagen
      'name': 'Juan',
      'age': 28,
      'description': 'Disfruto la buena comida y los eventos culturales.'
    },
  ];

  void _swipe(bool isLike) {
    if (isLike) {
      swiperController.next(animation: true); // Desliza hacia la derecha
      print('Like');
    } else {
      swiperController.previous(animation: true); // Desliza hacia la izquierda
      print('Dislike');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfiles de Asistentes'),
        centerTitle: true,
      ),
      body: attendees.isEmpty
          ? const Center(child: Text('No hay más perfiles'))
          : Swiper(
              controller: swiperController,
              itemCount: attendees.length,
              itemWidth: MediaQuery.of(context).size.width * 0.8,
              itemHeight: MediaQuery.of(context).size.height * 0.65,
              layout: SwiperLayout.STACK,
              onIndexChanged: (index) {
                if (index >= attendees.length) {
                  setState(() {
                    attendees = [];
                  });
                }
              },
              itemBuilder: (BuildContext context, int index) {
                final attendee = attendees[index];
                return Stack(
                  children: [
                    Card(
                      elevation: 8,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: attendee['image'] != null
                                  ? Image.network(
                                      attendee['image'] as String,
                                      height: 200,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                        return const Placeholder(
                                          fallbackHeight: 200,
                                          fallbackWidth: double.infinity,
                                        );
                                      },
                                    )
                                  : const Placeholder(
                                      fallbackHeight: 200,
                                      fallbackWidth: double.infinity,
                                    ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              attendee['name'] as String,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${attendee['age']} años',
                              style: const TextStyle(
                                fontSize: 18,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              attendee['description'] as String,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 16,
                      left: 16,
                      right: 16,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Botón de rechazo (cruz)
                          FloatingActionButton(
                            heroTag: 'dislike_$index',
                            backgroundColor: Colors.red,
                            onPressed: () => _swipe(false),
                            child: const Icon(Icons.close, color: Colors.white),
                          ),
                          // Botón de aceptación (like)
                          FloatingActionButton(
                            heroTag: 'like_$index',
                            backgroundColor: Colors.green,
                            onPressed: () => _swipe(true),
                            child: const Icon(Icons.favorite,
                                color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
    );
  }
}
