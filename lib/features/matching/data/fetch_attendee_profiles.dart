import 'package:cloud_firestore/cloud_firestore.dart';

class Profile {
  final String id;
  final String name;
  final int age;
  final String description;
  final List<String> imagePath;

  Profile({
    required this.id,
    required this.name,
    required this.age,
    required this.description,
    required this.imagePath,
  });
}

Future<List<Profile>> fetchAttendeeProfiles(String eventId) async {
  final eventDoc = await FirebaseFirestore.instance.collection('events').doc(eventId).get();
  final attendees = List<String>.from(eventDoc.data()?['attendees'] ?? []);

  if (attendees.isEmpty) return [];

  final usersQuery = await FirebaseFirestore.instance
      .collection('users')
      .where(FieldPath.documentId, whereIn: attendees)
      .get();

  return usersQuery.docs.map((doc) {
    final data = doc.data();
    return Profile(
      id: doc.id,
      name: data['name'] ?? '',
      age: data['age'] ?? 0,
      description: data['description'] ?? '',
      imagePath: List<String>.from(data['photoUrls'] ?? []), // debe existir este campo
    );
  }).toList();
}


// Este archivo define el modelo Profile y la función para cargar los perfiles asistentes a un evento.