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


  Future<void> _asistirODejarDeAsistir(String eventId) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    final firestore = FirebaseFirestore.instance;

    // 1. Buscar el evento usando el campo 'id' dentro del documento
    final eventRef = firestore.collection('events');
    final eventQuery = await eventRef.where('id', isEqualTo: eventId).get();

    if (eventQuery.docs.isNotEmpty) {
      final eventDoc = eventQuery.docs.first; // Obtenemos el primer evento que coincide con el 'id'

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
          const SnackBar(content: Text('¡Has dejado de asistir a este evento!')),
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
          const SnackBar(content: Text('¡Estás asistiendo a este evento!')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Este evento no existe')),
      );
    }
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
                          onAttend: () => _asistirODejarDeAsistir(event.id),
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
