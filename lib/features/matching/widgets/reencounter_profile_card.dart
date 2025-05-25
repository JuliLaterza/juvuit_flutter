// Archivo: features/matching/widgets/reencounter_profile_card.dart

import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:juvuit_flutter/core/utils/colors.dart';
import 'package:juvuit_flutter/features/profile/domain/models/user_profile.dart';

class ReencounterProfileCard extends StatelessWidget {
  final UserProfile profile;
  final int index;
  final int currentImageIndex;
  final VoidCallback onDislike;
  final Function(int) onCarouselChange;

  const ReencounterProfileCard({
    super.key,
    required this.profile,
    required this.index,
    required this.currentImageIndex,
    required this.onDislike,
    required this.onCarouselChange,
  });

  int _calculateAge(DateTime? birthDate) {
    if (birthDate == null) return 0;
    final today = DateTime.now();
    int age = today.year - birthDate.year;
    if (today.month < birthDate.month ||
        (today.month == birthDate.month && today.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  @override
  Widget build(BuildContext context) {
    final photoCount = profile.photoUrls.length;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 20.0),
        child: Column(
          children: [
            CarouselSlider(
              options: CarouselOptions(
                height: 380,
                viewportFraction: 1.0,
                enlargeCenterPage: false,
                enableInfiniteScroll: false,
                onPageChanged: (imgIndex, _) => onCarouselChange(imgIndex),
              ),
              items: profile.photoUrls.map((url) {
                return Image.network(url, fit: BoxFit.cover, width: double.infinity);
              }).toList(),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(photoCount, (i) => Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.symmetric(horizontal: 3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: currentImageIndex == i ? Colors.black : Colors.grey,
                ),
              )),
            ),
            const SizedBox(height: 16),
            Center(
                    child: IconButton(
                      icon: const Icon(Icons.close, size: 36, color: Colors.redAccent),
                      onPressed: onDislike,
                    ),
                  ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.yellow,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Han conectado anteriormente pero nunca hablaron. Quizás... es la oportunidad de romper el hielo con un mensaje.',
                      style: TextStyle(color: AppColors.black),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text('${profile.name}, ${_calculateAge(profile.birthDate)}',
                      style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Text(profile.description,
                      style: const TextStyle(fontSize: 16, color: Colors.black87)),
                  const SizedBox(height: 16),
                  Row(children: [
                    const Text('🥂 ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    Text(profile.favoriteDrink,
                        style: const TextStyle(fontSize: 16, fontStyle: FontStyle.normal))
                  ]),
                  const SizedBox(height: 8),
                  Row(children: [
                    const Text('♈ ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    Text(profile.sign ?? '-', style: const TextStyle(fontSize: 16))
                  ]),
                  const SizedBox(height: 16),
                  const Text('Canciones favoritas',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  for (final song in profile.topSongs)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(song['imageUrl'], width: 46, height: 46, fit: BoxFit.cover),
                        ),
                        const SizedBox(width: 12),
                        Expanded(child: Text('${song['title']} - ${song['artist']}')),
                      ]),
                    ),
                  const SizedBox(height: 30),
                  
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
