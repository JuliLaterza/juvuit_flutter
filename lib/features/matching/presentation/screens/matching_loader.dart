import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:juvuit_flutter/features/events/domain/models/event.dart';
import 'package:juvuit_flutter/features/matching/presentation/screens/matching_screen.dart';

class MatchingLoader extends StatefulWidget {
  const MatchingLoader({super.key});

  @override
  State<MatchingLoader> createState() => _MatchingLoaderState();
}

class _MatchingLoaderState extends State<MatchingLoader> {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _loadUserEvents();
  }

  Future<void> _loadUserEvents() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    // Obtener el documento del usuario
    final userDoc = await _firestore.collection('users').doc(userId).get();
    final List attendedEventIds = userDoc.data()?['attendedEvents'] ?? [];
    print('IDs en attendedEvents: $attendedEventIds');
    if (attendedEventIds.isEmpty) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const MatchingScreen(attendingEvents: []),
        ),
      );
      return;
    }

    // Consultamos los eventos por los IDs almacenados en attendedEvents
    final eventsSnapshot = await _firestore
        .collection('events')
        .where('id', whereIn: attendedEventIds)
        .get();
        //.where(FieldPath.documentId, whereIn: attendedEventIds) cuando queramos hacerlo por doc.id
    print('Eventos encontrados: ${eventsSnapshot.docs.length}');
    // Convertir los documentos a una lista de objetos Event
    final events = eventsSnapshot.docs.map((doc) {
      final data = doc.data();
      return Event(
        id: doc.id,
        title: data['title'] ?? '',
        subtitle: data['subtitle'] ?? '',
        date: (data['date'] as Timestamp).toDate(),
        imageUrl: data['imageUrl'] ?? '',
        attendeesCount: (data['attendees'] as List?)?.length ?? 0,
        description: data['description'] ?? '',
        type: data['type'] ?? '',
      );
    }).toList();

    if (mounted) {
      // Pasar la lista de eventos a MatchingScreen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => MatchingScreen(attendingEvents: events),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
