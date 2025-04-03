import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:juvuit_flutter/features/events/domain/models/event.dart';
import 'package:juvuit_flutter/features/events/presentation/widgets/EventCard.dart';

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
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: EventCard(
                event: event,
                onAttend: () {}, // Callback vacío ya que el manejo está en EventCard
              ),
            );
          },
        );
      },
    );
  }
}
