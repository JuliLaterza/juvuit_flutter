import 'package:flutter/material.dart';
import 'package:juvuit_flutter/features/events/domain/models/event.dart';
import '../../../../core/widgets/custom_bottom_nav_bar.dart';
import 'package:juvuit_flutter/features/events/data/events_data.dart';

class MatchingScreen extends StatefulWidget {
  const MatchingScreen({super.key});

  @override
  _MatchingScreenState createState() => _MatchingScreenState();
}

class _MatchingScreenState extends State<MatchingScreen> {
  late List<Event> attendingEvents;

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  void _loadEvents() {
    // Inicializar eventos ordenados por fecha por defecto
    attendingEvents = events
        .where((event) => event.attendeesCount > 0) // Ajusta esta lógica según tu necesidad
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }

  void _sortEventsBy(String criteria) {
    setState(() {
      if (criteria == 'date') {
        attendingEvents.sort((a, b) => a.date.compareTo(b.date));
      } else if (criteria == 'attendees') {
        attendingEvents.sort((a, b) => b.attendeesCount.compareTo(a.attendeesCount));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Eventos Asistidos'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Botón de Filtro
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Align(
              alignment: Alignment.centerRight,
              child: PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'date') {
                    _sortEventsBy('date');
                  } else if (value == 'attendees') {
                    _sortEventsBy('attendees');
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'date',
                    child: Text('Ordenar por fecha próxima'),
                  ),
                  const PopupMenuItem(
                    value: 'attendees',
                    child: Text('Ordenar por cantidad de asistentes'),
                  ),
                ],
                child: ElevatedButton(
                  onPressed: null, // El PopupMenuButton maneja el clic
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  child: const Text('Filtro'),
                ),
              ),
            ),
          ),
          // Listado de eventos
          Expanded(
            child: attendingEvents.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.event_busy,
                          size: 80,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'No tienes eventos asistidos aún',
                          style: TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/events'); // Ruta a la pantalla de eventos
                          },
                          child: const Text('Explorar eventos'),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: attendingEvents.length,
                    itemBuilder: (context, index) {
                      final event = attendingEvents[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                        child: ListTile(
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              event.imageUrl,
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                            ),
                          ),
                          title: Text(
                            event.title,
                            maxLines: 1, // Limitar a 1 línea
                            overflow: TextOverflow.ellipsis, // Agregar "..."
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Fecha: ${event.date.day}/${event.date.month}/${event.date.year}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 12),
                              ),
                              Text(
                                'Asistentes: ${event.attendeesCount}',
                                style: const TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                            ],
                          ),
                          trailing: ElevatedButton(
                            onPressed: () {
                              print("Ingresé al evento: ${event.title}");
                            },
                            child: const Text('Matchear'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 8.0,
                            horizontal: 12.0,
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 1),
    );
  }
}
