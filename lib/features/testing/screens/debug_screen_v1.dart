import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DebugScreen extends StatefulWidget {
  const DebugScreen({super.key});

  @override
  State<DebugScreen> createState() => _DebugScreenState();
}

class _DebugScreenState extends State<DebugScreen> {
  final String eventDocId = 'pSRHMOVp4zKikw7l1Afd';

  String message = 'Cargando...';

  // Evento
  String eventTitle = '';
  List<dynamic> attendees = [];

  // Usuario
  String userId = '';
  String userEmail = '';
  List<dynamic> attendedEvents = [];

  @override
  void initState() {
    super.initState();
    _loadDebugData();
  }

  Future<void> _loadDebugData() async {
    final auth = FirebaseAuth.instance;
    final user = auth.currentUser;

    if (user == null) {
      setState(() {
        message = 'Usuario no autenticado';
      });
      return;
    }

    userId = user.uid;
    userEmail = user.email ?? '';

    final firestore = FirebaseFirestore.instance;

    // Leer evento
    final eventSnap = await firestore.collection('events').doc(eventDocId).get();
    if (eventSnap.exists) {
      final data = eventSnap.data()!;
      eventTitle = data['title'] ?? '';
      attendees = data['attendees'] ?? [];
    }

    // Leer usuario
    final userSnap = await firestore.collection('users').doc(userId).get();
    if (userSnap.exists) {
      final data = userSnap.data()!;
      attendedEvents = data['attendedEvents'] ?? [];
    }

    setState(() {
      message = 'Datos cargados correctamente';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('DebugScreen')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(message, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 16),

            const Text('🎉 Evento', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text('ID: $eventDocId'),
            Text('Título: $eventTitle'),
            Text('Cantidad de asistentes: ${attendees.length}'),
            Text('Incluye al usuario: ${attendees.contains(userId) ? '✅ Sí' : '❌ No'}'),
            const SizedBox(height: 8),
            const Text('👥 Attendees:'),
            ...attendees.map((uid) => Text('• $uid')).toList(),

            const Divider(height: 32),

            const Text('🙋 Usuario', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text('ID: $userId'),
            Text('Email: $userEmail'),
            Text('Eventos asistidos: ${attendedEvents.length}'),
            const SizedBox(height: 8),
            const Text('📌 Attended Events:'),
            ...attendedEvents.map((eid) => Text('• $eid')).toList(),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
