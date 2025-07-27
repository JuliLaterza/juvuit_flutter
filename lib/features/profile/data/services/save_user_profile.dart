import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<void> saveUserProfile({
  required String name,
  required String description,
  List<Map<String, String>>? topSongs,
  String? drink,
  required String? sign,
  required DateTime? birthDate,
  required List<String> photoUrls,
}) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return;

  final userData = {
    'name': name,
    'description': description,
    if (topSongs != null) 'top_3canciones': topSongs,
    if (drink != null) 'drink': drink,
    'sign': sign,
    'photoUrls': photoUrls,
    'isPremium': false, // ← nuevo campo
    if (birthDate != null) 'birthDate': Timestamp.fromDate(birthDate),
  };

  await FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .set(userData, SetOptions(merge: true));
}

Future<void> saveUserPersonality({
  String? gender,
  List<String>? interests,
  String? lookingFor,
  String? job,
  String? studies,
  String? university,
  String? smoke,
  List<String>? traits,
  bool profileComplete = true,
}) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return;

  final personalityData = {
    if (gender != null) 'gender': gender,
    if (interests != null) 'interests': interests,
    if (lookingFor != null) 'lookingFor': lookingFor,
    if (job != null) 'job': job,
    if (studies != null) 'studies': studies,
    if (university != null) 'university': university,
    if (smoke != null) 'smoke': smoke,
    if (traits != null) 'traits': traits,
    'profileComplete': profileComplete,
  };

  await FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .set(personalityData, SetOptions(merge: true));
}
