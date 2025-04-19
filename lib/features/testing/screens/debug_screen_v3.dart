import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DebugScreen extends StatelessWidget {
  const DebugScreen({super.key});

  Future<List<String>> _fetchPhotoUrls(String uid) async {
    final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    if (!doc.exists || !doc.data()!.containsKey('photoUrls')) return [];
    return List<String>.from(doc['photoUrls']);
  }

  Future<void> _fixUserPhotoUrls(String uid) async {
    await FirebaseFirestore.instance.collection('users').doc(uid).set({
      'photoUrls': [
        'https://upload.wikimedia.org/wikipedia/commons/thumb/b/b4/Lionel-Messi-Argentina-2022-FIFA-World-Cup_%28cropped%29.jpg/250px-Lionel-Messi-Argentina-2022-FIFA-World-Cup_%28cropped%29.jpg'
      ],
    }, SetOptions(merge: true));

    debugPrint('photoUrls actualizado correctamente');
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Debug: Foto de perfil'),
      ),
      body: user != null
          ? FutureBuilder<List<String>>(
              future: _fetchPhotoUrls(user.uid),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final photos = snapshot.data ?? [];

                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('UID: ${user.uid}'),
                      const SizedBox(height: 20),
                      photos.isNotEmpty
                          ? Image.network(
                              photos[0],
                              height: 150,
                              width: 150,
                              fit: BoxFit.cover,
                            )
                          : const Text('No hay foto de perfil'),
                      const SizedBox(height: 10),
                      Text('photoUrls:'),
                      //for (var url in photos) Text(url, textAlign: TextAlign.center),
                      Text('Cantidad de fotos: ${photos.length}'),
                      const SizedBox(height: 30),
                      ElevatedButton(
                        onPressed: () async {
                          await _fixUserPhotoUrls(user.uid);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('photoUrls corregido')),
                          );
                        },
                        child: const Text('Corregir photoUrls'),
                      ),
                    ],
                  ),
                );
              }
            )
          : const Center(child: Text('No hay usuario logueado')),
    );
  }
}
