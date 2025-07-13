import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfile {
  final String userId;
  final String name;
  final String description;
  final List<Map<String, dynamic>> topSongs;
  final String favoriteDrink;
  final String? sign;
  final List<String> photoUrls;
  final List<String> attendedEvents;
  final DateTime? birthDate;
  final bool isPremium;

  UserProfile({
    required this.userId,
    required this.name,
    required this.description,
    required this.topSongs,
    required this.favoriteDrink,
    this.sign,
    required this.photoUrls,
    required this.attendedEvents,
    this.birthDate,
    required this.isPremium,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'name': name,
      'description': description,
      'top_3canciones': topSongs,
      'drink': favoriteDrink,
      'sign': sign,
      'photoUrls': photoUrls,
      'attendedEvents': attendedEvents,
      'isPremium': isPremium,
      if (birthDate != null) 'birthDate': Timestamp.fromDate(birthDate!),
    };
  }

  factory UserProfile.fromMap(String userId, Map<String, dynamic> map) {
    final rawSongs = map['top_3canciones'];
    final List<Map<String, dynamic>> parsedSongs = [];

    if (rawSongs is List) {
      for (var item in rawSongs) {
        if (item is Map) {
          parsedSongs.add({
            'title': item['title'] ?? '',
            'artist': item['artist'] ?? '',
            'imageUrl': item['imageUrl'] ?? '',
          });
        }
      }
    }

    return UserProfile(
      userId: userId,
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      topSongs: parsedSongs,
      favoriteDrink: map['drink'] ?? '',
      sign: map['sign'],
      photoUrls: List<String>.from(map['photoUrls'] ?? []),
      attendedEvents: List<String>.from(map['attendedEvents'] ?? []),
      birthDate: map['birthDate'] != null
          ? (map['birthDate'] as Timestamp).toDate()
          : null,
      isPremium: map['isPremium'] ?? false,
    );
  }
}
