// Archivo: features/matching/controllers/matching_profiles_controller.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:juvuit_flutter/features/events/domain/models/event.dart';
import 'package:juvuit_flutter/features/profile/domain/models/user_profile.dart';
import '../domain/match_helper.dart';

class MatchingProfilesController {
  late final PageController pageController;
  final Set<String> likedProfiles = {};
  final Map<int, int> currentCarouselIndex = {};
  late UserProfile currentUserProfile;
  
  MatchingProfilesController({required this.pageController});

  Future<UserProfile?> loadCurrentUserProfile() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return null;

    final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    if (doc.exists) {
      final data = doc.data()!;
      currentUserProfile = UserProfile.fromMap(uid, data);
      return currentUserProfile;
    }
    return null;
  }

  Future<List<UserProfile>> loadProfiles(Event event) async {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    if (currentUserId == null) return [];

    // Obtener likes dados por el usuario en este evento
    final likesGivenSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUserId)
        .collection('likesGiven')
        .get();

    final likedUserIds = likesGivenSnapshot.docs
        .where((doc) => doc.data()['eventId'] == event.id)
        .map((doc) => doc.id)
        .toSet();

    // Obtener matches con chats ya iniciados
    final matchesSnapshot = await FirebaseFirestore.instance
        .collection('matches')
        .where('users', arrayContains: currentUserId)
        .get();

    final Set<String> matchedAndChattedUserIds = {};
    for (final doc in matchesSnapshot.docs) {
      final data = doc.data();
      final users = List<String>.from(data['users']);
      final otherUserId = users.firstWhere((uid) => uid != currentUserId);
      final lastMessage = data['lastMessage'];
      if (lastMessage != null && lastMessage.toString().trim().isNotEmpty) {
        matchedAndChattedUserIds.add(otherUserId);
      }
    }

    final List<UserProfile> loaded = [];
    for (final uid in event.attendees) {
      if (uid == currentUserId || likedUserIds.contains(uid) || matchedAndChattedUserIds.contains(uid)) continue;

      final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (doc.exists) {
        final data = doc.data()!;
        final profile = UserProfile.fromMap(doc.id, data);
        loaded.add(profile);
      }
    }

    return loaded;
  }

  Future<void> onLike({
    required BuildContext context,
    required List<UserProfile> profiles,
    required Event event,
  }) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    final currentPage = pageController.page!.toInt();
    if (currentUser == null || currentPage >= profiles.length) return;

    final likedUser = profiles[currentPage];
    likedProfiles.add(likedUser.userId);

    // Guardar también en likesGiven
    await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.uid)
        .collection('likesGiven')
        .doc(likedUser.userId)
        .set({
      'eventId': event.id,
      'timestamp': FieldValue.serverTimestamp(),
    });

    await handleLikeAndMatch(
      currentUserId: currentUser.uid,
      likedUserId: likedUser.userId,
      eventId: event.id,
      context: context,
      currentUserPhoto: currentUserProfile.photoUrls.first,
      matchedUserPhoto: likedUser.photoUrls.isNotEmpty ? likedUser.photoUrls.first : 'https://via.placeholder.com/150',
      matchedUserName: likedUser.name,
    );

    avanzarPagina(currentPage);
  }

  void onDislike(List<UserProfile> profiles) {
    final currentPage = pageController.page!.toInt();
    avanzarPagina(currentPage);
  }

  void avanzarPagina(int currentPage) {
    pageController.nextPage(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  int calculateAge(DateTime? birthDate) {
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
