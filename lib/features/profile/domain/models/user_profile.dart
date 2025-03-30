class UserProfile {
  final String userId;
  final String name;
  final String description;
  final List<String> topSongs;
  final String favoriteDrink;
  final String? sign;
  final List<String> photoUrls;
  final List<String> attendedEvents;

  UserProfile({
    required this.userId,
    required this.name,
    required this.description,
    required this.topSongs,
    required this.favoriteDrink,
    this.sign,
    required this.photoUrls,
    required this.attendedEvents,
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
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      userId: map['userId'],
      name: map['name'],
      description: map['description'],
      topSongs: List<String>.from(map['topSongs']),
      favoriteDrink: map['favoriteDrink'],
      sign: map['sign'],
      photoUrls: List<String>.from(map['photoUrls']),
      attendedEvents: List<String>.from(map['attendedEvents']),
    );
  }
}
