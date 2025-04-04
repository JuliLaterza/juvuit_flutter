import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:juvuit_flutter/features/profile/domain/models/user_profile.dart';

class UserProfileService {
  final _usersRef = FirebaseFirestore.instance.collection('users');

  Future<void> saveUserProfile(UserProfile profile) async {
    await _usersRef.doc(profile.userId).set(profile.toMap(), SetOptions(merge: true));
  }

  Future<UserProfile?> getUserProfile(String userId) async {
    final doc = await _usersRef.doc(userId).get();

    if (!doc.exists || doc.data() == null) return null;

    return UserProfile.fromMap(doc.id, doc.data()!); // 👈 pasás el ID manualmente
  }
}
