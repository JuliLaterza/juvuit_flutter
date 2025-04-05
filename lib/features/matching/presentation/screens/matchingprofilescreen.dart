import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:juvuit_flutter/features/profile/domain/models/user_profile.dart';
import 'package:juvuit_flutter/features/events/domain/models/event.dart';

import '../../domain/match_helper.dart';
import '../../widgets/NoMoreProfilesCard.dart';

class MatchingProfilesScreen extends StatefulWidget {
  final Event event;
  const MatchingProfilesScreen({super.key, required this.event});

  @override
  State<MatchingProfilesScreen> createState() => _MatchingProfilesScreenState();
}

class _MatchingProfilesScreenState extends State<MatchingProfilesScreen> {
  final PageController _pageController = PageController();
  List<UserProfile> _profiles = [];
  bool _isLoading = true;
  late UserProfile _currentUserProfile;
  final Map<int, int> _currentCarouselIndex = {};

  @override
  void initState() {
    super.initState();
    _loadCurrentUserProfile().then((_) => _loadProfiles());
  }

  Future<void> _loadCurrentUserProfile() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    if (doc.exists) {
      final data = doc.data()!;
      _currentUserProfile = UserProfile.fromMap(uid, data);
    }
  }

  Future<void> _loadProfiles() async {
    final List<UserProfile> loaded = [];
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;

    for (final uid in widget.event.attendees) {
      if (uid == currentUserId) continue;

      final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (doc.exists) {
        final data = doc.data()!;
        final profile = UserProfile.fromMap(doc.id, data);
        loaded.add(profile);
      }
    }

    setState(() {
      _profiles = loaded;
      _isLoading = false;
    });
  }

  void _onLike() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    final currentPage = _pageController.page!.toInt();

    if (currentUser == null || currentPage >= _profiles.length) return;

    final likedUser = _profiles[currentPage];

    await handleLikeAndMatch(
      currentUserId: currentUser.uid,
      likedUserId: likedUser.userId,
      eventId: widget.event.id,
      context: context,
      currentUserPhoto: _currentUserProfile.photoUrls.first,
      matchedUserPhoto: likedUser.photoUrls.first,
      matchedUserName: likedUser.name,
    );

    if (context.mounted) {
      _avanzarPagina(currentPage);
    }
  }

  void _onDislike() {
    final currentPage = _pageController.page!.toInt();
    _avanzarPagina(currentPage);
  }

  void _avanzarPagina(int currentPage) {
    if (currentPage < _profiles.length) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: Text('Conectá en ${widget.event.title}')),
      body: PageView.builder(
        scrollDirection: Axis.vertical,
        controller: _pageController,
        itemCount: _profiles.length + 1,
        itemBuilder: (context, index) {
          if (index == _profiles.length) {
            return NoMoreProfilesCard(
              onSeeEvents: () {
                Navigator.pop(context);
              },
            );
          }

          final profile = _profiles[index];
          final photoCount = profile.photoUrls.length;
          final currentImageIndex = _currentCarouselIndex[index] ?? 0;

          return Container(
            color: Colors.white,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CarouselSlider(
                  options: CarouselOptions(
                    height: 400,
                    autoPlay: false,
                    enlargeCenterPage: true,
                    viewportFraction: 0.9,
                    onPageChanged: (imgIndex, reason) {
                      setState(() {
                        _currentCarouselIndex[index] = imgIndex;
                      });
                    },
                  ),
                  items: profile.photoUrls.map((imageUrl) {
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(Icons.error, size: 100, color: Colors.red);
                        },
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(photoCount, (i) {
                    return Container(
                      width: 8,
                      height: 8,
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: currentImageIndex == i ? Colors.black : Colors.grey,
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.redAccent,
                      radius: 30,
                      child: IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        iconSize: 30,
                        onPressed: _onDislike,
                      ),
                    ),
                    const SizedBox(width: 60),
                    CircleAvatar(
                      backgroundColor: Colors.green,
                      radius: 30,
                      child: IconButton(
                        icon: const Icon(Icons.favorite, color: Colors.white),
                        iconSize: 30,
                        onPressed: _onLike,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '${profile.name}${profile.birthDate != null ? ", ${DateTime.now().year - profile.birthDate!.year}" : ''}',
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      profile.description,
                      textAlign: TextAlign.left,
                      style: const TextStyle(fontSize: 16, color: Colors.black87),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
