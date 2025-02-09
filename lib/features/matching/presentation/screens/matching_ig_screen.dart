import 'package:flutter/material.dart';

class Profile {
  final String id;
  final String name;
  final int age;
  final String description;
  final String imagePath; // Ruta de la imagen

  Profile({
    required this.id,
    required this.name,
    required this.age,
    required this.description,
    required this.imagePath,
  });
}

class MatchingIgScreen extends StatefulWidget {
  const MatchingIgScreen({super.key});

  @override
  State<MatchingIgScreen> createState() => _MatchingIgScreenState();
}

class _MatchingIgScreenState extends State<MatchingIgScreen> {
  final List<Profile> profiles = [
    Profile(
      id: '1',
      name: 'Julian',
      age: 26,
      description: 'Amante de los viajes y el café. 🎒☕',
      imagePath: 'assets/images/juli_barcelona.jpg',
    ),
    Profile(
      id: '2',
      name: 'Pia',
      age: 25,
      description: 'Una gurisa piola 😎, que se está argentinizando de a poco',
      imagePath: 'assets/images/pia.jpg',
    ),
    Profile(
      id: '3',
      name: 'Leo',
      age: 36,
      description: 'Cocinero profesional y fanático de los deportes. 🍳⚽',
      imagePath: 'assets/images/messi_mate.jpg',
    ),
  ];

  final PageController _pageController = PageController();

  void _onLike() {
    if (_pageController.page!.toInt() < profiles.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    } else {
      _showEndMessage();
    }
  }

  void _onDislike() {
    if (_pageController.page!.toInt() < profiles.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    } else {
      _showEndMessage();
    }
  }

  void _showEndMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('No hay más perfiles disponibles.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Explorar Perfiles'),
        centerTitle: true,
      ),
      body: PageView.builder(
        scrollDirection: Axis.vertical,
        controller: _pageController,
        itemCount: profiles.length,
        itemBuilder: (context, index) {
          final profile = profiles[index];

          return SingleChildScrollView( // Permite desplazarse si el contenido es muy largo
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Imagen principal
                SizedBox(
                  height: 300,
                  width: double.infinity,
                  child: Image.asset(
                    profile.imagePath,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(Icons.error, size: 100, color: Colors.red);
                    },
                  ),
                ),
                const SizedBox(height: 16),

                // Botones de interacción
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: _onDislike,
                      icon: const Icon(Icons.close, color: Colors.red, size: 40),
                    ),
                    const SizedBox(width: 16),
                    IconButton(
                      onPressed: _onLike,
                      icon: const Icon(Icons.favorite, color: Colors.green, size: 40),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Información del perfil
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start, // Asegura alineación a la izquierda
                    children: [
                      Text(
                        '${profile.name}, ${profile.age}',
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Align( 
                        alignment: Alignment.centerLeft, // Asegura que la descripción esté alineada a la izquierda
                        child: Text(
                          profile.description,
                          textAlign: TextAlign.left, // También lo refuerza en el texto
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }
}
