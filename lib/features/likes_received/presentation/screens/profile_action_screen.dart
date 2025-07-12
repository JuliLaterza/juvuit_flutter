// lib/features/likes_received/presentation/screens/profile_action_screen.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:juvuit_flutter/features/matching/domain/match_helper.dart';
import 'package:juvuit_flutter/features/profile/domain/models/user_profile.dart';
import 'package:juvuit_flutter/features/matching/widgets/profile_card.dart';

class ProfileActionScreen extends StatefulWidget {
  final UserProfile profile;
  final String eventTitle;
  final String eventId;
  final String myId;

  const ProfileActionScreen({
    Key? key,
    required this.profile,
    required this.eventTitle,
    required this.eventId,
    required this.myId,
  }) : super(key: key);

  @override
  _ProfileActionScreenState createState() => _ProfileActionScreenState();
}

class _ProfileActionScreenState extends State<ProfileActionScreen> {
  int currentImageIndex = 0;

  @override
  Widget build(BuildContext context) {
    final currentUserPhoto = FirebaseAuth.instance.currentUser?.photoURL ?? '';

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.profile.name),
      ),
      body: ProfileCard(
        profile: widget.profile,
        index: 0,
        currentImageIndex: currentImageIndex,
        onCarouselChange: (index) {
          setState(() {
            currentImageIndex = index;
          });
        },
        showActions: true,
        onDislike: () {
          Navigator.pop(context);
        },
        onLike: () async {
          final matched = await handleLikeAndMatch(
            currentUserId:    widget.myId,
            likedUserId:      widget.profile.userId,
            eventId:          widget.eventId,
            context:          context,
            currentUserPhoto: currentUserPhoto,
            matchedUserPhoto: widget.profile.photoUrls.first,
            matchedUserName:  widget.profile.name,
          );
          if (matched && context.mounted) {
            Navigator.pop(context);
          }
        },
      ),
    );
  }
}