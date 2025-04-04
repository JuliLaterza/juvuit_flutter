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
  String eventTitle = '';
  List<dynamic> attendees = [];
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

    final eventSnap = await firestore.collection('events').doc(eventDocId).get();
    if (eventSnap.exists) {
      final data = eventSnap.data()!;
      eventTitle = data['title'] ?? '';
      attendees = data['attendees'] ?? [];
    }

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

            const Divider(height: 32),

            // 👇 Botón para verificación en consola
            ComprobarAsistenciaButton(eventDocId: eventDocId),
          ],
        ),
      ),
    );
  }
}

class ComprobarAsistenciaButton extends StatelessWidget {
  final String eventDocId;

  const ComprobarAsistenciaButton({super.key, required this.eventDocId});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        final userId = FirebaseAuth.instance.currentUser?.uid;
        if (userId == null) {
          print('⚠️ Usuario no autenticado');
          return;
        }

        final firestore = FirebaseFirestore.instance;

        final userDoc = await firestore.collection('users').doc(userId).get();
        final attendedEvents = userDoc.data()?['attendedEvents'] ?? [];

        final eventDoc = await firestore.collection('events').doc(eventDocId).get();
        final attendees = eventDoc.data()?['attendees'] ?? [];

        print('============================');
        print('🧑‍💻 Usuario actual: $userId');
        print('✅ Eventos asistidos: $attendedEvents');
        print('🎉 Evento actual: $eventDocId');
        print('👥 Attendees: $attendees');
        print('¿Usuario está en attendees? ${attendees.contains(userId)}');
        print('¿Evento está en attendedEvents? ${attendedEvents.contains(eventDocId)}');
        print('============================');
      },
      child: const Text('Verificar asistencia'),
    );
  }
}
