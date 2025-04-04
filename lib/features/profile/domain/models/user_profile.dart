import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfile {
  final String userId;
  final String name;
  final String description;
  final List<String> topSongs;
  final String favoriteDrink;
  final String? sign;
  final List<String> photoUrls;
  final List<String> attendedEvents;
  final DateTime? birthDate;

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
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'name': name,
      'description': description,
      'topSongs': topSongs,
      'favoriteDrink': favoriteDrink,
      'sign': sign,
      'photoUrls': photoUrls,
      'attendedEvents': attendedEvents,
      if (birthDate != null) 'birthDate': Timestamp.fromDate(birthDate!),
    };
  }

  factory UserProfile.fromMap(String userId, Map<String, dynamic> map) {
  return UserProfile(
    userId: userId, // <- lo recibís desde afuera
    name: map['name'] ?? '',
    description: map['description'] ?? '',
    topSongs: List<String>.from(map['topSongs'] ?? []),
    favoriteDrink: map['favoriteDrink'] ?? '',
    sign: map['sign'],
    photoUrls: List<String>.from(map['photoUrls'] ?? []),
    attendedEvents: List<String>.from(map['attendedEvents'] ?? []),
    birthDate: map['birthDate'] != null
        ? (map['birthDate'] as Timestamp).toDate()
        : null,
  );
}
}
