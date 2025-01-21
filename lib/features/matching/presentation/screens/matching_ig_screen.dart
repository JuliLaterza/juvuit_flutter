import 'package:flutter/material.dart';

class Profile {
  final String id;
  final String name;
  final int age;
  final String description;
  final String imageUrl;

  Profile({
    required this.id,
    required this.name,
    required this.age,
    required this.description,
    required this.imageUrl,
  });
}

class MatchingIgScreen extends StatefulWidget {
  const MatchingIgScreen({Key? key}) : super(key: key);

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
      imageUrl: 'https://instagram.fmvd4-1.fna.fbcdn.net/v/t51.29350-15/470932340_571889198946724_8988554830569468324_n.heic?stp=dst-jpg_e35_p480x480_tt6&efg=eyJ2ZW5jb2RlX3RhZyI6ImltYWdlX3VybGdlbi4xNDQweDE4MDAuc2RyLmYyOTM1MC5kZWZhdWx0X2ltYWdlIn0&_nc_ht=instagram.fmvd4-1.fna.fbcdn.net&_nc_cat=104&_nc_ohc=GRgA9zpJc-gQ7kNvgH_e0ek&_nc_gid=945af54615fc4f07bac7ddd6ae9704c9&edm=AP4sbd4BAAAA&ccb=7-5&ig_cache_key=MzUzNDEwNDY5MTA3NzI3MzI5Nw%3D%3D.3-ccb7-5&oh=00_AYCVHOuIXa5b-E5-e6QE2aI28mKy7tIVWzye_u8xqc5cxA&oe=67949833&_nc_sid=7a9f4b',
    ),
    Profile(
      id: '2',
      name: 'Sofia',
      age: 28,
      description: 'Diseñadora gráfica con pasión por la fotografía. 📸',
      imageUrl: 'https://instagram.fmvd4-1.fna.fbcdn.net/v/t51.29350-15/432918301_886119216605350_6059139758044931314_n.jpg?stp=dst-jpg_e35_p480x480_tt6&efg=eyJ2ZW5jb2RlX3RhZyI6ImltYWdlX3VybGdlbi4xNDQweDE4MDAuc2RyLmYyOTM1MC5kZWZhdWx0X2ltYWdlIn0&_nc_ht=instagram.fmvd4-1.fna.fbcdn.net&_nc_cat=110&_nc_ohc=nJGrEzijknoQ7kNvgFg7gOe&_nc_gid=fd68554e1f554cc4af12c07e2ed8b193&edm=AP4sbd4BAAAA&ccb=7-5&ig_cache_key=MzMyNTAzMjcxNjY3MTEyMjkxMg%3D%3D.3-ccb7-5&oh=00_AYBEOgZX0_CCJ6G_3t440V5vvNQ05tUnkF-IGVhcuhA_6A&oe=6794B1C2&_nc_sid=7a9f4b',
    ),
    Profile(
      id: '3',
      name: 'Leo',
      age: 36,
      description: 'Cocinero profesional y fanático de los deportes. 🍳⚽',
      imageUrl: 'https://instagram.fmvd4-1.fna.fbcdn.net/v/t51.29350-15/470941724_436859726147097_3017111880619106958_n.jpg?stp=dst-jpg_e35_tt6&efg=eyJ2ZW5jb2RlX3RhZyI6ImltYWdlX3VybGdlbi45MDB4ODk5LnNkci5mMjkzNTAuZGVmYXVsdF9pbWFnZSJ9&_nc_ht=instagram.fmvd4-1.fna.fbcdn.net&_nc_cat=1&_nc_ohc=8whcDaqk5yAQ7kNvgGPZnZ1&_nc_gid=e1f8876920034a34bc60d7554e5ba82a&edm=APoiHPcBAAAA&ccb=7-5&ig_cache_key=MzUyNTgwOTcxNjQzNDc0MDE0Ng%3D%3D.3-ccb7-5&oh=00_AYDUZCFK7uezfdJamz_BNLNq6UIfF7s4dVjxEOpiOFOshg&oe=679497A6&_nc_sid=22de04',
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
          return Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Imagen principal
              Image.network(
                profile.imageUrl,
                height: 300,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(Icons.error, size: 100, color: Colors.red);
                },
              ),
              const SizedBox(height: 16),
              // Botones de interacción
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  IconButton(
                    onPressed: _onDislike,
                    icon: const Icon(Icons.close, color: Colors.red, size: 40),
                  ),
                  IconButton(
                    onPressed: _onLike,
                    icon: const Icon(Icons.favorite, color: Colors.green, size: 40),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Nombre y edad
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${profile.name}, ${profile.age}',style: const TextStyle(fontSize: 24,fontWeight: FontWeight.bold,),),
                        const SizedBox(height: 8),
                        Text(profile.description,textAlign: TextAlign.center,style: const TextStyle(fontSize: 16)),
                      ],
                    ),
                  ),
              
              // Descripción
              
                ],
              ),
              
              const Spacer(),
            ],
          );
        },
      ),
    );
  }
}
