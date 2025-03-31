import 'package:flutter/material.dart';
import '../../domain/models/event.dart';
import 'package:juvuit_flutter/core/utils/colors.dart';
import '../screens/event_info.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EventCard extends StatefulWidget {
  final Event event;
  final VoidCallback onAttend;

  const EventCard({
    super.key,
    required this.event,
    required this.onAttend,
  });

  @override
  _EventCardState createState() => _EventCardState();
}

class _EventCardState extends State<EventCard> {
  bool isAttending = false; // Mantener el estado localmente

  // Verificar si el usuario ya está asistiendo al evento
  Future<void> _checkIfAttending() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    final firestore = FirebaseFirestore.instance;
    final userDoc = await firestore.collection('users').doc(userId).get();

    if (userDoc.exists) {
      final attendedEvents = List<String>.from(userDoc.data()?['attendedEvents'] ?? []);
      setState(() {
        isAttending = attendedEvents.contains(widget.event.id); // Actualiza el estado
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _checkIfAttending(); // Verificar al inicio si el usuario está asistiendo
  }

  Future<void> _asistirODejarDeAsistir(String eventId) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    final firestore = FirebaseFirestore.instance;

    // 1. Verificar si el evento existe usando el campo 'id' dentro del documento
    final eventRef = firestore.collection('events');
    final eventQuery = await eventRef.where('id', isEqualTo: eventId).get();

    if (eventQuery.docs.isNotEmpty) {
      final eventDoc = eventQuery.docs.first; // Obtén el primer (y único) documento
      final attendees = eventDoc.data()?['attendees'] ?? [];

      // 2. Si el usuario ya está asistiendo, "dejar de asistir"
      if (attendees.contains(userId)) {
        await eventRef.doc(eventDoc.id).update({
          'attendees': FieldValue.arrayRemove([userId]), // Elimina el userId de la lista de asistentes
        });

        final userRef = firestore.collection('users').doc(userId);
        await userRef.update({
          'attendedEvents': FieldValue.arrayRemove([eventId]), // Elimina el eventId de attendedEvents
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('¡Has dejado de asistir a este evento!'), duration: Duration(seconds: 1),),
        );
      } else {
        // 3. Si el usuario no está asistiendo, "asistir"
        await eventRef.doc(eventDoc.id).update({
          'attendees': FieldValue.arrayUnion([userId]), // Agrega el userId a la lista de asistentes
        });

        final userRef = firestore.collection('users').doc(userId);
        await userRef.update({
          'attendedEvents': FieldValue.arrayUnion([eventId]), // Agrega el eventId al array attendedEvents
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('¡Estás asistiendo a este evento!'), duration: Duration(seconds: 1)),
        );
      }

      // Actualizamos el estado para reflejar el cambio de forma inmediata
      setState(() {
        isAttending = !isAttending; // Cambia el estado local
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Este evento no existe')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.white,
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Imagen del evento
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
            child: Image.network(
              widget.event.imageUrl,
              height: 160,
              width: double.infinity,
              fit: BoxFit.fill,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.event.title,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.black,
                  ),
                ),
                Text(
                  widget.event.subtitle,
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppColors.gray,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      'Fecha: ${widget.event.date.day}/${widget.event.date.month}/${widget.event.date.year}',
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppColors.darkGray,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Asistentes: ${widget.event.attendeesCount}',
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppColors.darkGray,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Botones dentro de la tarjeta
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EventInfoScreen(event: widget.event),
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.black,
                    side: const BorderSide(color: AppColors.darkYellow),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    textStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                  child: const Text('+ Info'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => _asistirODejarDeAsistir(widget.event.id),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isAttending ? Colors.redAccent : AppColors.yellow, // Rojo para "Dejar de asistir"
                    foregroundColor: AppColors.black,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    textStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                  child: Text(isAttending ? 'Dejar de asistir' : 'Asistir'),
                ),
                const SizedBox(width: 8),
                OutlinedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Venta de entradas ${widget.event.title}')),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.black,
                    side: const BorderSide(color: AppColors.darkYellow),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    textStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                  child: const Text('Comprar entradas!'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
