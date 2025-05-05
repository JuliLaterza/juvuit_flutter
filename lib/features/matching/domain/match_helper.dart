import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../widgets/match_popup.dart';

Future<bool> handleLikeAndMatch({
  required String currentUserId,
  required String likedUserId,
  required String eventId,
  required BuildContext context,
  required String currentUserPhoto,
  required String matchedUserPhoto,
  required String matchedUserName,
}) async {
  final likesReceivedRef = FirebaseFirestore.instance
      .collection('users')
      .doc(likedUserId)
      .collection('likesReceived')
      .doc(currentUserId);

  final currentUserLikesRef = FirebaseFirestore.instance
      .collection('users')
      .doc(currentUserId)
      .collection('likesReceived')
      .doc(likedUserId);

  await likesReceivedRef.set({'eventId': eventId}, SetOptions(merge: true));

  final snapshot = await currentUserLikesRef.get();

  if (snapshot.exists) {
    final matchId = [currentUserId, likedUserId]..sort();

    await FirebaseFirestore.instance
        .collection('matches')
        .doc(matchId.join('_'))
        .set({
      'users': [currentUserId, likedUserId],
      'eventId': eventId,
      'createdAt': FieldValue.serverTimestamp(),
    });

    final result = await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => MatchPopup(
        currentUserPhoto: currentUserPhoto,
        matchedUserPhoto: matchedUserPhoto,
        matchedUserName: matchedUserName,
        onMessagePressed: () {
          Navigator.pop(context, 'ok'); // Se cierra con botón
        },
      ),
    );

    return result != null; // true si se cerró con botón, false si tocó fuera
  }

  return false;
}
