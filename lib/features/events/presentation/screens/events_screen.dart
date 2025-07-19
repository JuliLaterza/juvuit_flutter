import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:juvuit_flutter/core/utils/colors.dart';
import 'package:juvuit_flutter/core/widgets/custom_bottom_nav_bar.dart';
import 'package:juvuit_flutter/features/events/domain/utils/events_filter.dart';
import 'package:juvuit_flutter/features/events/presentation/screens/event_info.dart';
import 'package:juvuit_flutter/features/events/presentation/widgets/eventCard.dart';
import '../../domain/models/event.dart';
import '../../data/events_data.dart';
import '../widgets/EventFilterButtons.dart';

class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key});

  @override
  _EventsScreenState createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  String selectedType = 'Todos';
  late Future<List<Event>> _futureEvents;

  final user = FirebaseAuth.instance.currentUser;


  @override
  void initState() {
    super.initState();
    _futureEvents = fetchEventsFromFirebase();
    if (kDebugMode) {
      print(user?.uid);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(52),
        child: AppBar(
          backgroundColor: AppColors.white,
          elevation: 0,
          title: Image.asset(
            'assets/images/homescreen/logo_witu.png',
            height: 32,
          ),
          centerTitle: false,
        ),
      ),
      body: SafeArea(
        top: false,
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
                    _futureEvents = fetchEventsFromFirebase();
                  });
                },
              ),
            ),
            // Lista de eventos
            Expanded(
              child: FutureBuilder<List<Event>>(
                future: _futureEvents,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return const Center(child: Text('Error al cargar eventos'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('No hay eventos disponibles'));
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
                          onTap: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => EventInfoScreen(event: event),
                              ),
                            );
                            setState(() {
                              _futureEvents = fetchEventsFromFirebase(); // 🔁 refresca al volver
                            });
                          },
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
