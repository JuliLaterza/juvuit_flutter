import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:juvuit_flutter/features/events/domain/models/event.dart';

class MatchingLoader extends StatelessWidget {
  const MatchingLoader({super.key});

  Future<List<Event>> _fetchUserEvents() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return [];

    final snapshot = await FirebaseFirestore.instance
        .collection('events')
        .where('attendees', arrayContains: user.uid)
        .get();

    return snapshot.docs.map((doc) => Event.fromFirestore(doc)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Event>>(
      future: _fetchUserEvents(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return const Center(child: Text('Error al cargar eventos.'));
        }

        final events = snapshot.data ?? [];

        if (events.isEmpty) {
          return const Center(child: Text('Todavía no te anotaste a ningún evento.'));
        }

        return ListView.builder(
          itemCount: events.length,
          itemBuilder: (context, index) {
            final event = events[index];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
              child: ListTile(
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    event.imageUrl,
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  ),
                ),
                title: Text(
                  event.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Fecha: ${event.date.day}/${event.date.month}/${event.date.year}',
                      style: const TextStyle(fontSize: 12),
                    ),
                    Text(
                      'Asistentes: ${event.attendeesCount}',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
                trailing: ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/profiles'); // futuro
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  child: const Text('Conectar'),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
