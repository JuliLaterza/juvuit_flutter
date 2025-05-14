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

    final likesSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUserId)
        .collection('likesReceived')
        .get();
    final likedUserIds = likesSnapshot.docs.map((doc) => doc.id).toSet();

    final matchesSnapshot = await FirebaseFirestore.instance
        .collection('matches')
        .where('users', arrayContains: currentUserId)
        .get();
    final matchedUserIds = matchesSnapshot.docs.expand((doc) {
      final users = List<String>.from(doc['users']);
      return users.where((uid) => uid != currentUserId);
    }).toSet();

    final List<UserProfile> loaded = [];
    for (final uid in event.attendees) {
      if (uid == currentUserId || likedUserIds.contains(uid) || matchedUserIds.contains(uid)) continue;

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
    print('[CONTROLLER] onDislike llamado - página actual: $currentPage');
    avanzarPagina(currentPage);
  }

  void avanzarPagina(int currentPage) {
    pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.linear,
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