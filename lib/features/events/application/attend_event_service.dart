import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<void> attendEvent(String eventId) async {
  final userId = FirebaseAuth.instance.currentUser?.uid;
  if (userId == null) return;

  final firestore = FirebaseFirestore.instance;

  // Agrega el evento al usuario
  await firestore.collection('users').doc(userId).set({
    'attendedEvents': FieldValue.arrayUnion([eventId])
  }, SetOptions(merge: true));

  // Agrega el usuario al evento
  await firestore.collection('events').doc(eventId).set({
    'attendees': FieldValue.arrayUnion([userId])
  }, SetOptions(merge: true));
}

