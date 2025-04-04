import 'package:cloud_firestore/cloud_firestore.dart';

class Event {
  final String id;
  final String title;
  final String subtitle;
  final DateTime date;
  final String imageUrl;
  final int attendeesCount;
  final String description;
  final String type;
  final List<String> attendees; // ✅ nuevo campo

  const Event({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.date,
    required this.imageUrl,
    required this.attendeesCount,
    required this.description,
    required this.type,
    required this.attendees,
  });

  factory Event.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Event(
      id: doc.id,
      title: data['title'] ?? '',
      subtitle: data['subtitle'] ?? '',
      date: (data['date'] as Timestamp).toDate(),
      imageUrl: data['imageUrl'] ?? '',
      attendeesCount: data['attendeesCount'] ?? 0,
      description: data['description'] ?? '',
      type: data['type'] ?? '',
      attendees: List<String>.from(data['attendees'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'subtitle': subtitle,
      'date': Timestamp.fromDate(date),
      'imageUrl': imageUrl,
      'attendeesCount': attendeesCount,
      'description': description,
      'type': type,
      'attendees': attendees,
    };
  }
}
