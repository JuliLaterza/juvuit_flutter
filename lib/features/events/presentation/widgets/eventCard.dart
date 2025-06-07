import 'package:flutter/material.dart';
import '../../domain/models/event.dart';
import 'package:juvuit_flutter/core/utils/colors.dart';
// ignore: unused_import
import '../screens/event_info.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EventCard extends StatefulWidget {
  final Event event;
  final VoidCallback onTap; // usado para +Info

  const EventCard({
    super.key,
    required this.event,
    required this.onTap,
  });

  @override
  _EventCardState createState() => _EventCardState();
}

class _EventCardState extends State<EventCard> {
  bool isAttending = false;

  @override
  void initState() {
    super.initState();
    _checkIfAttending();
  }

  Future<void> _checkIfAttending() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    final userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
    if (userDoc.exists) {
      final attendedEvents = List<String>.from(userDoc.data()?['attendedEvents'] ?? []);
      if (mounted) {
        setState(() {
          isAttending = attendedEvents.contains(widget.event.id);
        });
      }
    }
  }

  Future<void> _asistirODejarDeAsistir() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    final firestore = FirebaseFirestore.instance;
    final eventRef = firestore.collection('events').doc(widget.event.id);
    final userRef = firestore.collection('users').doc(userId);

    final eventSnapshot = await eventRef.get();
    if (!eventSnapshot.exists) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Este evento no existe')),
      );
      return;
    }

    final attendees = eventSnapshot.data()?['attendees'] ?? [];

    if (attendees.contains(userId)) {
      await eventRef.update({
        'attendees': FieldValue.arrayRemove([userId]),
      });
      await userRef.update({
        'attendedEvents': FieldValue.arrayRemove([widget.event.id]),
      });

      if (mounted) {
        setState(() {
          isAttending = false;
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('¡Has dejado de asistir a este evento!')),
      );
    } else {
      await eventRef.update({
        'attendees': FieldValue.arrayUnion([userId]),
      });
      await userRef.update({
        'attendedEvents': FieldValue.arrayUnion([widget.event.id]),
      });

      if (mounted) {
        setState(() {
          isAttending = true;
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('¡Estás asistiendo a este evento!')),
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
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
            child: Image.network(
              widget.event.imageUrl,
              height: 160,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.event.title,
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.black)),
                const SizedBox(height: 4),
                Text(widget.event.subtitle,
                    style: const TextStyle(fontSize: 10, color: AppColors.black)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      'Fecha: ${widget.event.date.day}/${widget.event.date.month}/${widget.event.date.year}',
                      style: const TextStyle(fontSize: 10, color: AppColors.darkGray),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Asistentes: ${widget.event.attendeesCount}',
                      style: const TextStyle(fontSize: 10, color: AppColors.darkGray),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton(
                  onPressed: widget.onTap,
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
                  onPressed: _asistirODejarDeAsistir,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isAttending ? Colors.redAccent : AppColors.yellow,
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
                  child: const Text('Entradas'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
