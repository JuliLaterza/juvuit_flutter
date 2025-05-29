// Archivo: features/matching/widgets/profile_card.dart

import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:juvuit_flutter/core/utils/colors.dart';
import 'package:juvuit_flutter/features/profile/domain/models/user_profile.dart';

class ProfileCard extends StatelessWidget {
  final UserProfile profile;
  final int index;
  final int currentImageIndex;
  final VoidCallback onLike;
  final VoidCallback onDislike;
  final Function(int) onCarouselChange;
  final bool showActions;

  const ProfileCard({
    super.key,
    required this.profile,
    required this.index,
    required this.currentImageIndex,
    required this.onLike,
    required this.onDislike,
    required this.onCarouselChange,
    required this.showActions
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
        child: Padding(
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
              if(showActions)
                Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.close, size: 36, color: Colors.redAccent),
                    onPressed: onDislike,
                  ),
                  const SizedBox(width: 40),
                  IconButton(
                    icon: const Icon(Icons.favorite_border, size: 36, color: AppColors.black),
                    onPressed: onLike,
                  ),
                ],
                ),
              const SizedBox(height: 30),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
