  // Archivo: features/testing/screens/debugscreen_restartusers.dart

  import 'package:flutter/material.dart';
  import 'package:cloud_firestore/cloud_firestore.dart';
  import 'package:firebase_auth/firebase_auth.dart';

  class DebugScreenRestartUsers extends StatefulWidget {
    const DebugScreenRestartUsers({super.key});

    @override
    State<DebugScreenRestartUsers> createState() => _DebugScreenRestartUsersState();
  }

  class _DebugScreenRestartUsersState extends State<DebugScreenRestartUsers> {
    bool isLoading = false;
    String result = '';

    Future<void> restartData() async {
      setState(() {
        isLoading = true;
        result = '';
      });

      try {
        final firestore = FirebaseFirestore.instance;

        /// 1. Borrar likes recibidos
        final users = await firestore.collection('users').get();
        for (final user in users.docs) {
          final likes = await user.reference.collection('likesReceived').get();
          for (final like in likes.docs) {
            await like.reference.delete();
          }
        }

        /// 2. Borrar matches y mensajes
        final matches = await firestore.collection('matches').get();
        for (final match in matches.docs) {
          final messages = await match.reference.collection('messages').get();
          for (final msg in messages.docs) {
            await msg.reference.delete();
          }
          await match.reference.delete();
        }

        /// 3. Vaciar attendees en eventos
        final events = await firestore.collection('events').get();
        for (final event in events.docs) {
          await event.reference.update({'attendees': []});
        }

        /// 4. Vaciar attendedEvents en usuarios
        for (final user in users.docs) {
          await user.reference.update({'attendedEvents': []});
        }
        
        /// 5. Borrar mensajes (messages/chats)
        final messages = await firestore.collection('messages').get();
        for (final matchDoc in messages.docs) {
          final chats = await matchDoc.reference.collection('chats').get();

          for (final chatDoc in chats.docs) {
            final chatMessages = await chatDoc.reference.collection('messages').get();
            for (final msg in chatMessages.docs) {
              await msg.reference.delete();
            }

            await chatDoc.reference.delete(); // borra el chatId
          }

          await matchDoc.reference.delete(); // borra el matchId
        }

        setState(() {
          result = '✅ Reinicio completado con éxito';
        });
      } catch (e) {
        setState(() {
          result = '❌ Error: $e';
        });
      } finally {
        setState(() {
          isLoading = false;
        });
      }
    }

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Reiniciar Usuarios'),
          centerTitle: true,
        ),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: isLoading ? null : restartData,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  ),
                  child: const Text(
                    'Reiniciar base de datos',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 20),
                if (isLoading) const CircularProgressIndicator(),
                if (result.isNotEmpty)
                  Text(
                    result,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: result.startsWith('✅') ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
    }
  }
