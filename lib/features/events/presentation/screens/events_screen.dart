import 'package:flutter/material.dart';
import 'package:juvuit_flutter/core/widgets/custom_bottom_nav_bar.dart';
import 'package:juvuit_flutter/features/events/domain/utils/events_filter.dart';
import '../../domain/models/event.dart';
import '../../data/events_data.dart';
import '../widgets/EventCard.dart';
import '../widgets/EventFilterButtons.dart'; // Importa el nuevo widget

class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key});

  @override
  _EventsScreenState createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  String selectedType = 'Todos'; // Estado para el filtro seleccionado

  @override
  Widget build(BuildContext context) {
    // Lista filtrada según el tipo seleccionado
    List<Event> filteredEvents = filterEventsByType(events, selectedType);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Momentos que Importan',
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
            // Lista de eventos
            Expanded(
              child: ListView.builder(
                itemCount: filteredEvents.length,
                itemBuilder: (context, index) {
                  final event = filteredEvents[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                    child: EventCard(event: event),
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
