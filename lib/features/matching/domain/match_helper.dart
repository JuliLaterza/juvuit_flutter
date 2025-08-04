// Archivo: match_helper.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../presentation/screens/match_animation_screen.dart';

// Función utilitaria para generar matchId de forma consistente
String _generateMatchId(String userId1, String userId2) {
  final sortedIds = [userId1, userId2]..sort();
  return sortedIds.join('_');
}

Future<bool> handleLikeAndMatch({
  required String currentUserId,
  required String likedUserId,
  required String eventId,
  required BuildContext context,
  required String currentUserPhoto,
  required String matchedUserPhoto,
  required String matchedUserName,
}) async {
  try {
    // Guardar likes en paralelo
    await Future.wait([
      // Guardar en likesReceived del usuario destino
      FirebaseFirestore.instance
          .collection('users')
          .doc(likedUserId)
          .collection('likesReceived')
          .doc(currentUserId)
          .set({
        'eventId': eventId,
        'timestamp': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true)),

      // Guardar en likesGiven del usuario actual
      FirebaseFirestore.instance
          .collection('users')
          .doc(currentUserId)
          .collection('likesGiven')
          .doc(likedUserId)
          .set({
        'eventId': eventId,
        'timestamp': FieldValue.serverTimestamp(),
      }),
    ]);

    print("Se dio like correctamente");

    // Verificar si hay match (ya sabemos que no es instantáneo, pero verificamos por si acaso)
    final currentUserLikesRef = FirebaseFirestore.instance
        .collection('users')
        .doc(currentUserId)
        .collection('likesReceived')
        .doc(likedUserId);

    final snapshot = await currentUserLikesRef.get();

    if (snapshot.exists) {
      // ¡Hay match! Crear documento de match
      final generatedMatchId = _generateMatchId(currentUserId, likedUserId);
      
      await FirebaseFirestore.instance
          .collection('matches')
          .doc(generatedMatchId)
          .set({
        'users': [currentUserId, likedUserId],
        'eventId': eventId,
        'createdAt': FieldValue.serverTimestamp(),
      });

      print('DEBUG: Match creado después de like: $generatedMatchId');

      // Navegar al MatchAnimationScreen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MatchAnimationScreen(
            userImage: currentUserPhoto,
            matchImage: matchedUserPhoto,
            matchedUserId: likedUserId,
            matchedUserName: matchedUserName,
            matchedUserPhotoUrl: matchedUserPhoto,
            matchId: generatedMatchId, // ← PASAR matchId DIRECTAMENTE
          ),
        ),
      );

      return true;
    }

    return false;
  } catch (e) {
    print('Error en handleLikeAndMatch: $e');
    return false;
  }
}
