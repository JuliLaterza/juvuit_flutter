import 'package:flutter/material.dart';
import 'package:juvuit_flutter/core/utils/colors.dart';
import 'package:juvuit_flutter/features/events/domain/models/event.dart';
import 'package:juvuit_flutter/features/events/presentation/screens/events_screen.dart';
import '../../../../core/widgets/custom_bottom_nav_bar.dart';

class MatchingScreen extends StatefulWidget {
  final List<Event> attendingEvents;

  const MatchingScreen({super.key, required this.attendingEvents});

  @override
  _MatchingScreenState createState() => _MatchingScreenState();
}

class _MatchingScreenState extends State<MatchingScreen> {
  String filterType = 'date';

  void _sortEvents() {
    setState(() {
      if (filterType == 'date') { 
        widget.attendingEvents.sort((a, b) => a.date.compareTo(b.date));
      } else if (filterType == 'attendees') {
        widget.attendingEvents.sort((a, b) => b.attendeesCount.compareTo(a.attendeesCount));
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
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Align(
              alignment: Alignment.center,
              child: PopupMenuButton<String>(
                onSelected: (value) {
                  filterType = value;
                  _sortEvents();
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
                  onPressed: null,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    backgroundColor: AppColors.white,
                  ),
                  child: const Text('Filtro'),
                ),
              ),
            ),
          ),
          Expanded(
            child: widget.attendingEvents.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.event_busy, size: 80, color: Colors.grey),
                        const SizedBox(height: 16),
                        const Text(
                          'No tienes eventos asistidos aún',
                          style: TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              PageRouteBuilder(
                                transitionDuration: Duration.zero,
                                pageBuilder: (_, __, ___) => const EventsScreen(),
                              ),
                            );
                          },
                          child: const Text('Explorar eventos'),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: widget.attendingEvents.length,
                    itemBuilder: (context, index) {
                      final event = widget.attendingEvents[index];
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
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
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
                              Navigator.pushNamed(context, '/profiles');
                            },
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            ),
                            child: const Text('Conectar'),
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
