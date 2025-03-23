import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:juvuit_flutter/features/matching/presentation/screens/match_animation_screen.dart';

class Profile {
  final String id;
  final String name;
  final int age;
  final String description;
  final List<String> imagePath; // Ruta de la imagen

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
      imagePath: ['assets/images/juli_barcelona.jpg', 'assets/images/juli_casita.jpg'],
    ),
    Profile(
      id: '2',
      name: 'Vicky',
      age: 25,
      description: 'la mejor del mundo <333',
      imagePath: ['assets/images/vicky.jpeg','assets/images/vicky2.jpeg'],
    ),
    Profile(
      id: '3',
      name: 'Male',
      age: 26,
      description: 'la mejor del mundo <333',
      imagePath: ['assets/images/male.jpg','assets/images/male2.jpg'],
    ),
    Profile(
      id: '4',
      name: 'Pia',
      age: 25,
      description: 'Una gurisa piola 😎, que se está argentinizando de a poco',
      imagePath: ['assets/images/pia.jpg'],
    ),
    Profile(
      id: '5',
      name: 'Leo',
      age: 37,
      description: 'Le pego bien de zurda y si no te copa...anda palla bobo ⚽⭐️⭐️⭐️',
      imagePath: ['assets/images/messi_mate.jpg','assets/images/messi_arg.jpg','assets/images/messi.jpg', 'assets/images/messicopa.jpg', 'assets/images/messi_barcelona.jpg'],
    ),
    Profile(
      id: '6',
      name: 'Mati',
      age: 29,
      description: 'Astronomo que te lleva a ver las estrellas... grrr 🌌',
      imagePath: ['assets/images/mati_lopez.jpg', 'assets/images/mati_ny.jpg'],
    )
  ];

  final PageController _pageController = PageController();

  /*
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
  */

  void _onLike() {
  final currentPage = _pageController.page!.toInt();
  final profile = profiles[currentPage];

  if (profile.id == '2') {
    // Simulamos que hay match con Pia
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MatchAnimationScreen(
          userImage: 'assets/images/juli_barcelona.jpg',
          matchImage: profile.imagePath.first,
        ),
      ),
    );
  } else {
    // Avanzar normalmente
    if (currentPage < profiles.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    } else {
      _showEndMessage();
      }
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

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 80),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Carrusel de imágenes
                CarouselSlider(
                  options: CarouselOptions(
                    height: 350,
                    autoPlay: true,
                    enlargeCenterPage: true,
                    aspectRatio: 16 / 9,
                    enableInfiniteScroll: true,
                  ),
                  items: profile.imagePath.map((image) {
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.asset(
                        image,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(Icons.error, size: 100, color: Colors.red);
                        },
                      ),
                    );
                  }).toList(),
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
                    const SizedBox(width: 50),
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${profile.name}, ${profile.age}',
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          profile.description,
                          textAlign: TextAlign.left,
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
