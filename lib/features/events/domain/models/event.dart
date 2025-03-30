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

  const Event({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.date,
    required this.imageUrl,
    required this.attendeesCount,
    required this.description,
    required this.type,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      subtitle: json['subtitle'] ?? '',
      date: (json['date'] as Timestamp).toDate(),
      imageUrl: json['imageUrl'] ?? '',
      attendeesCount: json['attendeesCount'] ?? 0,
      description: json['description'] ?? '',
      type: json['type'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'subtitle': subtitle,
      'date': Timestamp.fromDate(date),
      'imageUrl': imageUrl,
      'attendeesCount': attendeesCount,
      'description': description,
      'type': type,
    };
  }
}
