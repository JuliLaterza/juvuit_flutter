import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DebugScreenDelete extends StatelessWidget {
  const DebugScreenDelete({super.key});

  Future<void> _deleteAllUsersAndCleanEvents(BuildContext context) async {
    final firestore = FirebaseFirestore.instance;

    try {
      // Confirmación
      final confirm = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Confirmar eliminación'),
          content: const Text(
              '¿Estás seguro de que querés borrar todos los usuarios, matches, likesReceived, mensajes y limpiar los asistentes de todos los eventos?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('Sí, borrar todo'),
            ),
          ],
        ),
      );

      if (confirm != true) return;

      // 1. Obtener todos los usuarios
      final usersSnapshot = await firestore.collection('users').get();
      final userIds = usersSnapshot.docs.map((doc) => doc.id).toList();

      // 2. Eliminar todos los usuarios y sus subcolecciones likesReceived
      for (final userId in userIds) {
        final likesSnapshot = await firestore
            .collection('users')
            .doc(userId)
            .collection('likesReceived')
            .get();

        for (final likeDoc in likesSnapshot.docs) {
          await likeDoc.reference.delete();
        }

        await firestore.collection('users').doc(userId).delete();
      }

      // 3. Limpiar los arrays attendees en todos los eventos
      final eventsSnapshot = await firestore.collection('events').get();
      for (final eventDoc in eventsSnapshot.docs) {
        final attendees = List<String>.from(eventDoc['attendees'] ?? []);
        final updatedAttendees = attendees.where((uid) => !userIds.contains(uid)).toList();

        await firestore.collection('events').doc(eventDoc.id).update({
          'attendees': updatedAttendees,
        });
      }

      // 4. Eliminar todos los matches
      final matchesSnapshot = await firestore.collection('matches').get();
      for (final matchDoc in matchesSnapshot.docs) {
        await matchDoc.reference.delete();
      }

      // 5. Eliminar todos los mensajes y subcolección chats
      final messagesSnapshot = await firestore.collection('messages').get();
      for (final messageDoc in messagesSnapshot.docs) {
        final chatsSnapshot = await messageDoc.reference.collection('chats').get();
        for (final chatDoc in chatsSnapshot.docs) {
          await chatDoc.reference.delete();
        }
        await messageDoc.reference.delete();
      }

      // 6. Eliminar todos los hashes de mensajes (matchIds) si quedaron
      final messageHashesSnapshot = await firestore.collection('messages').get();
      for (final hashDoc in messageHashesSnapshot.docs) {
        await hashDoc.reference.delete();
      }

      // Feedback
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Todo fue eliminado correctamente')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Debug - Borrar Todo')),
      body: Center(
        child: ElevatedButton(
          onPressed: () => _deleteAllUsersAndCleanEvents(context),
          child: const Text('Borrar TODOS los usuarios, eventos y matches'),
        ),
      ),
    );
  }
}
