import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:juvuit_flutter/features/profile/domain/models/user_profile.dart';

class LikesRepository {
  final FirebaseFirestore _fire = FirebaseFirestore.instance;

  /// Nueva versión: obtiene todos los datos necesarios para la card en un solo Future.
  Future<List<Map<String, dynamic>>> fetchLikesWithFullInfo(String myId) async {
    // 1. Traer todos los likes recibidos
    final snap = await _fire
        .collection('users')
        .doc(myId)
        .collection('likesReceived')
        .get();
    final likes = snap.docs;

    // 2. Para cada like, comprobar si existe un match
    final results = await Future.wait(likes.map((doc) async {
      final otherId = doc.id;
      final matchId1 = '${myId}_$otherId';
      final matchId2 = '${otherId}_$myId';
      final m1 = await _fire.collection('matches').doc(matchId1).get();
      final m2 = await _fire.collection('matches').doc(matchId2).get();
      return (!m1.exists && !m2.exists);
    }));

    // 3. Traer datos completos de usuario y evento
    final List<Map<String, dynamic>> fullData = [];
    for (var i = 0; i < likes.length; i++) {
      if (!results[i]) continue;
      final doc = likes[i];
      final otherId = doc.id;
      final eventId = doc.get('eventId') as String? ?? '';

      // Usuario
      final userSnap = await _fire.collection('users').doc(otherId).get();
      final photos = (userSnap.data()?['photoUrls'] as List<dynamic>?) ?? [];
      final name = userSnap.data()?['name'] as String? ?? '';
      final age = userSnap.data()?['age']?.toString() ?? '';

      // Evento
      final eventSnap = await _fire.collection('events').doc(eventId).get();
      final eventTitle = eventSnap.exists
          ? (eventSnap.data()?['title'] as String?) ?? ''
          : '';

      fullData.add({
        'otherId': otherId,
        'eventId': eventId,
        'photoUrl': photos.isNotEmpty ? photos.first as String : '',
        'name': name,
        'age': age,
        'eventTitle': eventTitle,
      });
    }
    return fullData;
  }

  /// (Antiguo) Obtiene la lista de documentos de "likesReceived" para el usuario dado,
  /// excluyendo aquellos con los que ya hay un match.
  Future<List<QueryDocumentSnapshot>> fetchLikes(String myId) async {
    final snap = await _fire
        .collection('users')
        .doc(myId)
        .collection('likesReceived')
        .get();
    final likes = snap.docs;
    final results = await Future.wait(likes.map((doc) async {
      final otherId = doc.id;
      final matchId1 = '${myId}_$otherId';
      final matchId2 = '${otherId}_$myId';
      final m1 = await _fire.collection('matches').doc(matchId1).get();
      final m2 = await _fire.collection('matches').doc(matchId2).get();
      return (!m1.exists && !m2.exists);
    }));
    final filtered = <QueryDocumentSnapshot>[];
    for (var i = 0; i < likes.length; i++) {
      if (results[i]) filtered.add(likes[i]);
    }
    return filtered;
  }

  /// Lee los datos del usuario que dio like y del evento asociado
  Future<Map<String, dynamic>> fetchUserAndEvent(
      String userId, String eventId) async {
    final userSnap = await _fire.collection('users').doc(userId).get();
    final eventSnap = await _fire.collection('events').doc(eventId).get();

    final photos = (userSnap.data()?['photoUrls'] as List<dynamic>?) ?? [];
    final name = userSnap.data()?['name'] as String? ?? '';
    final age = userSnap.data()?['age']?.toString() ?? '';
    final eventTitle = eventSnap.exists
        ? (eventSnap.data()?['title'] as String?) ?? ''
        : '';

    return {
      'photoUrl': photos.isNotEmpty ? photos.first as String : '',
      'name': name,
      'age': age,
      'eventTitle': eventTitle,
    };
  }

  /// Busca el perfil público de un usuario por nombre
  Future<UserProfile?> queryProfileByName(String name) async {
    final q = await _fire
        .collection('users')
        .where('name', isEqualTo: name)
        .limit(1)
        .get();
    if (q.docs.isEmpty) return null;
    final doc = q.docs.first;
    final data = doc.data();
    return UserProfile.fromMap(doc.id, data);
  }
}
