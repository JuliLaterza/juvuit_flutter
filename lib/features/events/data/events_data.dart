import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:juvuit_flutter/features/events/domain/models/event.dart';

Future<List<Event>> fetchEventsFromFirebase() async {
  try {
    final snapshot = await FirebaseFirestore.instance
        .collection('events')
        .orderBy('date')
        .get();

    return snapshot.docs.map((doc) => Event.fromJson(doc.data())).toList();
  } catch (e) {
    print('Error al obtener eventos: $e');
    return [];
  }
}
