import 'package:cloud_firestore/cloud_firestore.dart';
import '../domain/models/event.dart';

Future<List<Event>> fetchEventsFromFirebase() async {
  final snapshot = await FirebaseFirestore.instance.collection('events').get();

  return snapshot.docs.map((doc) {
    final data = doc.data();
    return Event(
      docId: doc.id,
      title: data['title'] ?? '',
      subtitle: data['subtitle'] ?? '',
      date: (data['date'] as Timestamp).toDate(),
      imageUrl: data['imageUrl'] ?? '',
      attendeesCount: (data['attendees'] as List?)?.length ?? 0,
      description: data['description'] ?? '',
      type: data['type'] ?? '',
    );
  }).toList();
}
