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

  // Si en el futuro necesitas convertir a/from JSON:
  // factory Event.fromJson(Map<String, dynamic> json) {
  //   return Event(
  //     id: json['id'] as String,
  //     title: json['title'] as String,
  //     subtitle: json['subtitle'] as String,
  //     date: DateTime.parse(json['date'] as String),
  //     imageUrl: json['imageUrl'] as String,
  //     attendeesCount: json['attendeesCount'] as int,
  //   );
  // }

  // Map<String, dynamic> toJson() {
  //   return {
  //     'id': id,
  //     'title': title,
  //     'subtitle': subtitle,
  //     'date': date.toIso8601String(),
  //     'imageUrl': imageUrl,
  //     'attendeesCount': attendeesCount,
  //   };
  // }
}
