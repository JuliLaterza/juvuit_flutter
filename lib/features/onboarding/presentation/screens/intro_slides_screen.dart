import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:juvuit_flutter/core/utils/colors.dart';
import 'package:juvuit_flutter/core/utils/routes.dart';

class IntroSlidesScreen extends StatefulWidget {
  const IntroSlidesScreen({super.key});

  @override
  State<IntroSlidesScreen> createState() => _IntroSlidesScreenState();
}

class _IntroSlidesScreenState extends State<IntroSlidesScreen> {
  final PageController _controller = PageController();
  int _currentIndex = 0;

  final List<Map<String, String>> slides = [
    {
      'title': 'Descubrí momentos únicos',
      'description': 'Conectá con personas que van a ir al mismo lugar que vos y comparten tus mismas ganas de divertirse.',
    },
    {
      'title': 'Tu perfil, tu estilo',
      'description': 'Mostrá tus canciones favoritas, trago y más.',
    },
    {
      'title': '¡Empezá a vivir la experiencia!',
      'description': 'Wit Ü es más que una app, es tu nueva forma de conectar. Somos seres humanos y queremos compartir momentos en comunidad.',
    },
  ];

  void _nextSlide() {
    if (_currentIndex < slides.length - 1) {
      _controller.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    } else {
      _finishOnboarding();
    }
  }

  Future<void> _finishOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_seen', true);
    if (mounted) {
      Navigator.pushReplacementNamed(context, AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Stack(
          children: [
            PageView.builder(
              controller: _controller,
              itemCount: slides.length,
              onPageChanged: (index) {
                setState(() => _currentIndex = index);
              },
              itemBuilder: (context, index) {
                final slide = slides[index];
                return Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Spacer(),
                      Container(
                        height: 250,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: AppColors.darkWhite,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Center(child: Icon(Icons.image, size: 100, color: AppColors.gray)),
                      ),
                      const SizedBox(height: 40),
                      Text(
                        slide['title']!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        slide['description']!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 16, color: AppColors.gray),
                      ),
                      const Spacer(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          slides.length,
                          (i) => AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: const EdgeInsets.symmetric(horizontal: 6),
                            width: _currentIndex == i ? 12 : 8,
                            height: _currentIndex == i ? 12 : 8,
                            decoration: BoxDecoration(
                              color: _currentIndex == i ? AppColors.yellow : AppColors.lightGray,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _nextSlide,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.yellow,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: Text(
                            _currentIndex == slides.length - 1 ? 'Comenzar' : 'Siguiente',
                            style: const TextStyle(color: AppColors.black, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                );
              },
            ),
            Positioned(
              top: 12,
              right: 12,
              child: TextButton(
                onPressed: _finishOnboarding,
                child: const Text('Saltar', style: TextStyle(color: AppColors.gray)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
