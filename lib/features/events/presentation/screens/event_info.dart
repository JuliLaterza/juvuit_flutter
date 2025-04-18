import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:juvuit_flutter/core/utils/colors.dart';
import '../../domain/models/event.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:juvuit_flutter/features/events/application/attend_event_service.dart';

class EventInfoScreen extends StatefulWidget {
  const EventInfoScreen({super.key, required this.event});

  final Event event;

  @override
  State<EventInfoScreen> createState() => _EventInfoScreenState();
}

class _EventInfoScreenState extends State<EventInfoScreen> {
  bool isAttending = false;

  @override
  void initState() {
    super.initState();
    _checkIfUserIsAttending();
  }

  Future<void> _checkIfUserIsAttending() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    final doc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
    final attendedEvents = List<String>.from(doc.data()?['attendedEvents'] ?? []);

    if (mounted) {
      setState(() {
        isAttending = attendedEvents.contains(widget.event.id);
      });
    }
  }

  void _handleAttend() {
    setState(() {
      isAttending = true;
    });

    attendEvent(widget.event.id).catchError((e) {
      setState(() {
        isAttending = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al asistir: $e')),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final event = widget.event;

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: Text(
          event.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.black,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
                child: Image.network(
                  event.imageUrl,
                  width: MediaQuery.of(context).size.width,
                  height: 240,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 500),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(event.title,
                            style: const TextStyle(
                                fontSize: 22, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text(event.subtitle,
                            style: const TextStyle(
                                fontSize: 16, color: AppColors.gray)),
                        const SizedBox(height: 12),
                        Text(
                          '📅 ${DateFormat('dd/MM/yyyy').format(event.date)}',
                          style: const TextStyle(fontSize: 14),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '🧑‍🤝‍🧑 ${event.attendeesCount} personas asistirán',
                          style: const TextStyle(fontSize: 14),
                        ),
                        const SizedBox(height: 4),
                        const Text('📍 Costanera Norte'),
                        const SizedBox(height: 4),
                        const Text('💰 Costo: 170000 - 250000'),
                        const SizedBox(height: 16),
                        Text(event.description,
                            style: const TextStyle(fontSize: 16)),
                        const SizedBox(height: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              height: 180,
                              decoration: BoxDecoration(
                                color: AppColors.lightGray,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Center(child: Text("Mapa aquí")),
                            ),
                            const SizedBox(height: 8),
                            const Text("Agregar API de Google Maps"),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: isAttending ? null : _handleAttend,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: isAttending
                                      ? Colors.grey
                                      : AppColors.yellow,
                                  foregroundColor: AppColors.black,
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: Text(
                                    isAttending ? 'Ya estás unido' : 'Asistir'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () {},
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppColors.black,
                                  side: const BorderSide(
                                      color: AppColors.darkYellow),
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text('Compartir'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () {
                                  print('Venta de entradas.');
                                },
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppColors.black,
                                  side: const BorderSide(
                                      color: AppColors.darkYellow),
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text('Entradas'),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
