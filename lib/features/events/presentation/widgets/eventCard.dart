import 'package:flutter/material.dart';
import '../../domain/models/event.dart';
import 'package:juvuit_flutter/core/utils/colors.dart';
// ignore: unused_import
import '../screens/event_info.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:juvuit_flutter/core/utils/routes.dart';

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

    // Verificar directamente en el evento
    final eventDoc = await FirebaseFirestore.instance
        .collection('events')
        .doc(widget.event.id)
        .get();
        
    if (eventDoc.exists) {
      final attendees = List<String>.from(eventDoc.data()?['attendees'] ?? []);
      if (mounted) {
        setState(() {
          isAttending = attendees.contains(userId);
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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Este evento no existe')),
        );
      }
      return;
    }

    final attendees = eventSnapshot.data()?['attendees'] ?? [];

    if (attendees.contains(userId)) {
      // Si ya está asistiendo, dejar de asistir
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
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('¡Has dejado de asistir a este evento!')),
        );
      }
    } else {
      // Si va a asistir, verificar si es evento tipo FIESTA
      if (widget.event.type.toLowerCase() == 'fiesta' || 
          widget.event.type.toLowerCase() == 'boliche' || 
          widget.event.type.toLowerCase() == 'party') {
        
        print('DEBUG: Evento tipo fiesta detectado: ${widget.event.type}');
        
        // Verificar si el usuario tiene canciones y trago completados
        final userDoc = await userRef.get();
        if (userDoc.exists) {
          final userData = userDoc.data()!;
          final hasSongs = userData['top_3canciones'] != null && 
                          (userData['top_3canciones'] as List).isNotEmpty;
          final hasDrink = userData['drink'] != null && 
                          userData['drink'].toString().isNotEmpty;

          print('DEBUG: Usuario tiene canciones: $hasSongs, trago: $hasDrink');

          if (!hasSongs || !hasDrink) {
            print('DEBUG: Mostrando modal obligatorio');
            // Mostrar modal obligatorio
            final shouldContinue = await _showSongsDrinkModal();
            if (!shouldContinue) {
              print('DEBUG: Usuario canceló, no asistir al evento');
              return; // No asistir al evento
            }
            print('DEBUG: Usuario completó perfil, continuar con asistencia');
            
            // Después de completar el perfil, verificar nuevamente si tiene canciones y trago
            final updatedUserDoc = await userRef.get();
            if (updatedUserDoc.exists) {
              final updatedUserData = updatedUserDoc.data()!;
              final hasSongs = updatedUserData['top_3canciones'] != null && 
                              (updatedUserData['top_3canciones'] as List).isNotEmpty;
              final hasDrink = updatedUserData['drink'] != null && 
                              updatedUserData['drink'].toString().isNotEmpty;

              if (!hasSongs || !hasDrink) {
                print('DEBUG: Usuario aún no tiene canciones/trago completados');
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Completá tus canciones y trago favoritos para poder asistir')),
                  );
                }
                return; // No asistir al evento
              }
            }
          }
        }
      }

      // Asistir al evento
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
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('¡Estás asistiendo a este evento!')),
        );
      }
    }
  }

  Future<bool> _showSongsDrinkModal() async {
    return await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              //Icon(Icons.music_note, color: AppColors.darkmedium),
              //SizedBox(width: 8),
              Text('¡Completá tu perfil!'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Siempre vamos a priorizar tu experiencia en el evento, porque vos sos parte.',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.music_note, size: 16, color: Colors.grey[600]),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '¿Qué canciones te gustarían que pasen?',
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.local_bar, size: 16, color: Colors.grey[600]),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Tu trago preferido',
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('Cancelar', style: TextStyle(color: Colors.grey[600])),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.darkmedium,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop(true);
                // Navegar a la pantalla de completar perfil
                Navigator.pushNamed(context, AppRoutes.completeSongsDrink);
              },
              child: Text('Completar perfil'),
            ),
          ],
        );
      },
    ) ?? false;
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
                    style: const TextStyle(fontSize: 12, color: AppColors.black)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      'Fecha: ${widget.event.date.day}/${widget.event.date.month}/${widget.event.date.year}',
                      style: const TextStyle(fontSize: 12, color: AppColors.darkGray),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Asistentes: ${widget.event.attendeesCount}',
                      style: const TextStyle(fontSize: 12, color: AppColors.darkGray),
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
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Venta de entradas ${widget.event.title}')),
                      );
                    }
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
