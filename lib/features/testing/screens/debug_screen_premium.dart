import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DebugSetPremiumScreen extends StatelessWidget {
  const DebugSetPremiumScreen({super.key});

  Future<void> _addIsPremiumField() async {
    final usersCollection = FirebaseFirestore.instance.collection('users');
    final snapshot = await usersCollection.get();

    for (final doc in snapshot.docs) {
      final data = doc.data();
      if (data.containsKey('isPremium')) continue;

      await usersCollection.doc(doc.id).update({'isPremium': false});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Migrar isPremium')),
      body: Center(
        child: ElevatedButton(
          child: const Text('Agregar isPremium = false'),
          onPressed: () async {
            await _addIsPremiumField();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Campo agregado exitosamente')),
            );
          },
        ),
      ),
    );
  }
}
