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

// Nueva función específica para actualizar solo canciones y trago
Future<void> updateUserSongsAndDrink({
  required List<Map<String, String>> topSongs,
  required String drink,
}) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return;

  // Usar update() para modificar SOLO estos campos específicos
  await FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .update({
        'top_3canciones': topSongs,
        'drink': drink,
      });
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

  // Usar update() para modificar solo los campos específicos
  final updateData = <String, dynamic>{};
  
  if (gender != null) updateData['gender'] = gender;
  if (interests != null) updateData['interests'] = interests;
  if (lookingFor != null) updateData['lookingFor'] = lookingFor;
  if (job != null) updateData['job'] = job;
  if (studies != null) updateData['studies'] = studies;
  if (university != null) updateData['university'] = university;
  if (smoke != null) updateData['smoke'] = smoke;
  if (traits != null) updateData['traits'] = traits;
  updateData['profileComplete'] = profileComplete;

  await FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .update(updateData);
}
