// Archivo: match_helper.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../presentation/screens/match_animation_screen.dart';

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

  // Guardar en likesReceived del usuario destino
  await likesReceivedRef.set({
    'eventId': eventId,
    'timestamp': FieldValue.serverTimestamp(),
  }, SetOptions(merge: true));

  // Guardar en likesGiven del usuario actual
  await FirebaseFirestore.instance
      .collection('users')
      .doc(currentUserId)
      .collection('likesGiven')
      .doc(likedUserId)
      .set({
    'eventId': eventId,
    'timestamp': FieldValue.serverTimestamp(),
  });

  print("Se dio like correctamente");

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

    // Navegar directo al MatchAnimationScreen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MatchAnimationScreen(
          userImage: currentUserPhoto,
          matchImage: matchedUserPhoto,
          matchedUserId: likedUserId,
          matchedUserName: matchedUserName,
          matchedUserPhotoUrl: matchedUserPhoto,
        ),
      ),
    );

    return true;
  }

  return false;
}
