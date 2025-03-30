import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/models/user_profile.dart';

class UserProfileService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Guarda el perfil del usuario en Firestore
  Future<void> saveUserProfile(UserProfile profile) async {
    await _firestore.collection('users').doc(profile.userId).set(profile.toMap());
  }

  /// Obtener perfil del usuario desde Firestore
  Future<UserProfile?> getUserProfile(String userId) async {
    final doc = await _firestore.collection('users').doc(userId).get();
    if (!doc.exists) return null;

    return UserProfile.fromMap(doc.data()!);
  }
}


// Para largo plazo, crear una función que cargue las imagenes.