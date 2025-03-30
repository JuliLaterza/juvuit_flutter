import 'package:flutter/material.dart';
import 'package:juvuit_flutter/core/widgets/custom_bottom_nav_bar.dart';
import 'package:juvuit_flutter/features/events/domain/utils/events_filter.dart';
import '../../domain/models/event.dart';
import '../../data/events_data.dart';
import '../widgets/EventCard.dart';
import '../widgets/EventFilterButtons.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key});

  @override
  _EventsScreenState createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  String selectedType = 'Todos'; // Estado del filtro

  // Función para agregar eventos al listado de asistencia
  final List<Event> attendingEvents = [];

  void addToAttending(Event event) {
  if (!attendingEvents.contains(event)) {
    attendingEvents.add(event); // sin setState
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Agregado: ${event.title}'), duration: Duration(seconds: 1),),
    );
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Ya estás asistiendo a ${event.title}'), duration: Duration(seconds: 1)),
    );
  }
}


    Future<void> _asistirAlEvento(String eventId) async {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) return;

      final firestore = FirebaseFirestore.instance;

      // 1. Agregar el usuario a la lista de asistentes del evento
      final eventRef = firestore.collection('events').doc(eventId);
      final eventDoc = await eventRef.get();
      print(eventId);
      if (eventDoc.exists) {
        await eventRef.update({
          'attendees': FieldValue.arrayUnion([userId]), // Agrega el userId a la lista de asistentes
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Este evento no existe')),
        );
        return;
      }

      // 2. Agregar el evento a la lista de eventos asistidos del usuario
      final userRef = firestore.collection('users').doc(userId);
      await userRef.set({
        'attendedEvents': FieldValue.arrayUnion([eventId]), // Agrega el eventId al array attendedEvents
      }, SetOptions(merge: true));

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('¡Estás asistiendo a este evento!')),
      );
    }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Momentos que importan 🎉',
          style: TextStyle(fontStyle: FontStyle.normal),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Botones de filtro
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: EventFilterButtons(
                selectedType: selectedType,
                onFilterChanged: (type) {
                  setState(() {
                    selectedType = type;
                  });
                },
              ),
            ),
            // Lista de eventos desde Firebase
            Expanded(
              child: FutureBuilder<List<Event>>(
                future: fetchEventsFromFirebase(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error al cargar eventos'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text('No hay eventos disponibles'));
                  }

                  final filteredEvents = filterEventsByType(snapshot.data!, selectedType);

                  return ListView.builder(
                    itemCount: filteredEvents.length,
                    itemBuilder: (context, index) {
                      final event = filteredEvents[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                        child: EventCard(
                          event: event,
                          onAttend: () => _asistirAlEvento(event.id),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 0),
    );
  }
}
