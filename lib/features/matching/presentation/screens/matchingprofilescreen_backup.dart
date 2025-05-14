import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:juvuit_flutter/core/utils/colors.dart';
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
  final Set<String> _likedProfiles = {};

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
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    if (currentUserId == null) return;

    // Usuarios a los que ya di like
    final likesSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUserId)
        .collection('likesReceived')
        .get();
    final likedUserIds = likesSnapshot.docs.map((doc) => doc.id).toSet();

    // Usuarios con los que ya hice match
    final matchesSnapshot = await FirebaseFirestore.instance
        .collection('matches')
        .where('users', arrayContains: currentUserId)
        .get();
    final matchedUserIds = matchesSnapshot.docs.expand((doc) {
      final users = List<String>.from(doc['users']);
      return users.where((uid) => uid != currentUserId);
    }).toSet();

    final List<UserProfile> loaded = [];
    for (final uid in widget.event.attendees) {
      if (uid == currentUserId || likedUserIds.contains(uid) || matchedUserIds.contains(uid)) continue;

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

    setState(() {
      _likedProfiles.add(likedUser.userId);
    });

    await handleLikeAndMatch(
      currentUserId: currentUser.uid,
      likedUserId: likedUser.userId,
      eventId: widget.event.id,
      context: context,
      currentUserPhoto: _currentUserProfile.photoUrls.first,
      matchedUserPhoto: likedUser.photoUrls.isNotEmpty ? likedUser.photoUrls.first : 'https://via.placeholder.com/150',
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
      appBar: AppBar(
        title: const Text('Wit  Ü', style: TextStyle(color: AppColors.black)),
        backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
      ),
      body: PageView.builder(
        scrollDirection: Axis.vertical,
        controller: _pageController,
        itemCount: _profiles.length + 1,
        itemBuilder: (context, index) {
          if (index == _profiles.length) {
            return NoMoreProfilesCard(onSeeEvents: () => Navigator.pop(context));
          }

          final profile = _profiles[index];
          final photoCount = profile.photoUrls.length;
          final currentImageIndex = _currentCarouselIndex[index] ?? 0;
          final hasLiked = _likedProfiles.contains(profile.userId);

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
                        onPageChanged: (imgIndex, _) {
                          setState(() {
                            _currentCarouselIndex[index] = imgIndex;
                          });
                        },
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.close, size: 36, color: Colors.redAccent),
                          onPressed: _onDislike,
                        ),
                        const SizedBox(width: 40),
                        IconButton(
                          icon: Icon(
                            Icons.favorite_border,
                            size: 36,
                            color: hasLiked ? AppColors.yellow : Colors.black,
                          ),
                          onPressed: _onLike,
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
        },
      ),
    );
  }

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
}
