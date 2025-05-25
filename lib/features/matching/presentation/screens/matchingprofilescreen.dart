import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:juvuit_flutter/core/utils/colors.dart';
import 'package:juvuit_flutter/features/events/domain/models/event.dart';
import 'package:juvuit_flutter/features/profile/domain/models/user_profile.dart';
import 'package:juvuit_flutter/features/matching/controllers/matching_profiles_controller.dart';
import '../../widgets/profile_card.dart';
import '../../widgets/NoMoreProfilesCard.dart';
import '../../widgets/reencounter_profile_card.dart';

class MatchingProfilesScreen extends StatefulWidget {
  final Event event;
  const MatchingProfilesScreen({super.key, required this.event});

  @override
  State<MatchingProfilesScreen> createState() => _MatchingProfilesScreenState();
}

class _MatchingProfilesScreenState extends State<MatchingProfilesScreen> {
  final PageController _pageController = PageController();
  late final MatchingProfilesController _controller;
  List<UserProfile> _profiles = [];
  bool _isLoading = true;
  Set<String> reencounterUserIds = {};

  @override
  void initState() {
    super.initState();
    _controller = MatchingProfilesController(pageController: _pageController);
    _loadData();
  }

  Future<void> _loadData() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    final currentUserProfile = await _controller.loadCurrentUserProfile();
    if (currentUserProfile == null) return;

    final profiles = await _controller.loadProfiles(widget.event);
    final matchesSnapshot = await FirebaseFirestore.instance
        .collection('matches')
        .where('users', arrayContains: currentUser.uid)
        .get();

    final Set<String> seenButNotChatted = {};
    for (final doc in matchesSnapshot.docs) {
      final data = doc.data();
      final users = List<String>.from(data['users']);
      final otherUserId = users.firstWhere((uid) => uid != currentUser.uid);
      final lastMessage = data['lastMessage'];
      if (lastMessage == null || lastMessage.toString().trim().isEmpty) {
        seenButNotChatted.add(otherUserId);
      }
    }

    setState(() {
      _profiles = profiles;
      reencounterUserIds = seenButNotChatted;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Wit Ü', style: TextStyle(color: AppColors.black)),
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
          final currentIndex = _controller.currentCarouselIndex[index] ?? 0;

          if (reencounterUserIds.contains(profile.userId)) {
            return ReencounterProfileCard(
              profile: profile,
              index: index,
              currentImageIndex: currentIndex,
              onDislike: () => _controller.onDislike(_profiles),
              onCarouselChange: (imgIndex) {
                setState(() {
                  _controller.currentCarouselIndex[index] = imgIndex;
                });
              },
            );
          }

          return ProfileCard(
            profile: profile,
            index: index,
            currentImageIndex: currentIndex,
            onLike: () => _controller.onLike(
              context: context,
              profiles: _profiles,
              event: widget.event,
            ),
            onDislike: () => _controller.onDislike(_profiles),
            onCarouselChange: (imgIndex) {
              setState(() {
                _controller.currentCarouselIndex[index] = imgIndex;
              });
            },
          );
        },
      ),
    );
  }
}
