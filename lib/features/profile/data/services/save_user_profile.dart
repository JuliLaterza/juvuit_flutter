import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Guarda el perfil inicial del usuario usando set() con merge: true
/// Esto permite crear el documento si no existe, o actualizar solo los campos especificados
/// sin sobrescribir información existente (comportamiento tipo "append")
Future<void> saveUserProfile({
  required String name,
  required String description,
  List<Map<String, String>>? topSongs,
  String? drink,
  required DateTime? birthDate,
  required List<String> photoUrls,
}) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return;

  // Debug: Verificar que birthDate se está procesando correctamente
  print('DEBUG: saveUserProfile - birthDate received: $birthDate');
  
  final userData = {
    'name': name,
    'description': description,
    if (topSongs != null) 'top_3canciones': topSongs,
    if (drink != null) 'drink': drink,
    'photoUrls': photoUrls,
    'isPremium': false, // ← nuevo campo
    if (birthDate != null) 'birthDate': Timestamp.fromDate(birthDate),
  };
  
  // Debug: Verificar el objeto userData final
  print('DEBUG: saveUserProfile - userData keys: ${userData.keys.toList()}');
  if (birthDate != null) {
    print('DEBUG: saveUserProfile - birthDate in userData: ${userData['birthDate']}');
  }

  // set() con merge: true = crear si no existe, o actualizar solo campos especificados
  // NO sobrescribe campos existentes que no están en userData
  await FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .set(userData, SetOptions(merge: true));
}

/// Actualiza solo canciones y trago usando update()
/// update() solo modifica campos específicos y falla si el documento no existe
/// Es más seguro para actualizaciones parciales
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

/// Guarda la personalidad del usuario usando update()
/// update() es ideal para actualizaciones parciales sin riesgo de sobrescribir
/// Solo actualiza los campos que se proporcionan (no null)
Future<void> saveUserPersonality({
  String? gender,
  String? sign,
  DateTime? birthDate, // ← AGREGAR birthDate
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

  // Debug: Verificar que birthDate se está procesando correctamente
  print('DEBUG: saveUserPersonality - birthDate received: $birthDate');
  
  // Usar update() para modificar solo los campos específicos
  // Solo incluye campos que no son null para evitar sobrescribir con valores vacíos
  final updateData = <String, dynamic>{};
  
  if (gender != null) updateData['gender'] = gender;
  if (sign != null) updateData['sign'] = sign;
  if (birthDate != null) {
    updateData['birthDate'] = Timestamp.fromDate(birthDate); // ← AGREGAR birthDate
    print('DEBUG: saveUserPersonality - birthDate added to updateData: ${updateData['birthDate']}');
  }
  if (interests != null) updateData['interests'] = interests;
  if (lookingFor != null) updateData['lookingFor'] = lookingFor;
  if (job != null) updateData['job'] = job;
  if (studies != null) updateData['studies'] = studies;
  if (university != null) updateData['university'] = university;
  if (smoke != null) updateData['smoke'] = smoke;
  if (traits != null) updateData['traits'] = traits;
  updateData['profileComplete'] = profileComplete;
  
  // Debug: Verificar el objeto updateData final
  print('DEBUG: saveUserPersonality - updateData keys: ${updateData.keys.toList()}');
  if (birthDate != null) {
    print('DEBUG: saveUserPersonality - birthDate in updateData: ${updateData['birthDate']}');
  }

  await FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .update(updateData);
}
