import 'package:cloud_firestore/cloud_firestore.dart';

Future<List<String>> getUserPhotoUrls(String uid) async {
  final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();

  if (!doc.exists || !doc.data()!.containsKey('photoUrls')) return [];
  
  return List<String>.from(doc['photoUrls']);
}