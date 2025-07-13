import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<void> saveUserProfile({
  required String name,
  required String description,
  required List<Map<String, String>> topSongs,
  required String drink,
  required String? sign,
  required DateTime? birthDate,
  required List<String> photoUrls,
}) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return;

  final userData = {
    'name': name,
    'description': description,
    'top_3canciones': topSongs,
    'drink': drink,
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
