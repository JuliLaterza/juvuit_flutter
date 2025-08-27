import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:juvuit_flutter/core/widgets/custom_bottom_nav_bar.dart';
import 'package:juvuit_flutter/core/widgets/theme_aware_logo.dart';
import 'package:juvuit_flutter/features/events/domain/utils/events_filter.dart';
import 'package:juvuit_flutter/features/events/presentation/screens/event_info.dart';
import 'package:juvuit_flutter/features/events/presentation/widgets/eventCard.dart';
import '../../domain/models/event.dart';
import '../../data/events_data.dart';
import '../widgets/complete_filter_popup.dart';

class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key});

  @override
  _EventsScreenState createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  String selectedType = 'Todos';
  String? selectedProvince;
  String? selectedZone;
  late Future<List<Event>> _futureEvents;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  final user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
    _futureEvents = fetchEventsFromFirebase();
    if (kDebugMode) {
      print(user?.uid);
    }
  }

  String normalize(String text) {
    return text.toLowerCase().replaceAll(RegExp(r'[^\w\s]+'), '');
  }

  void _showCompleteFilterPopup() {
    showDialog(
      context: context,
      builder: (context) => CompleteFilterPopup(
        selectedType: selectedType,
        selectedProvince: selectedProvince,
        selectedZone: selectedZone,
        onTypeChanged: (type) {
          setState(() {
            selectedType = type;
          });
        },
        onProvinceChanged: (province) {
          setState(() {
            selectedProvince = province;
            selectedZone = null; // Reset zona al cambiar provincia
          });
        },
        onZoneChanged: (zone) {
          setState(() {
            selectedZone = zone;
          });
        },
        onClose: () {
          Navigator.of(context).pop();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(52),
        child: AppBar(
          backgroundColor: theme.colorScheme.surface,
          elevation: 0,
          automaticallyImplyLeading: false, // Evitar botón de volver automático
          title: const HeaderLogo(),
          centerTitle: false,
          actions: [
            const SizedBox(width: 8),
          ],
        ),
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            // Campo de búsqueda y botón de filtros
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  // Campo de búsqueda
                  Expanded(
                    flex: 3,
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Buscar evento',
                        prefixIcon: Icon(Icons.search, color: theme.colorScheme.onSurface),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: Icon(Icons.clear, color: theme.colorScheme.onSurface),
                                onPressed: () {
                                  _searchController.clear();
                                  FocusScope.of(context).unfocus();
                                },
                              )
                            : null,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: theme.colorScheme.outline.withOpacity(0.3)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: theme.colorScheme.primary),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Botón de filtros
                  Expanded(
                    flex: 1,
                    child: SizedBox(
                      height: 56, // Misma altura que el TextField
                      child: OutlinedButton.icon(
                        onPressed: () {
                          _showCompleteFilterPopup();
                        },
                        icon: Icon(
                          selectedType != 'Todos' || selectedProvince != null || selectedZone != null
                              ? Icons.filter_list_alt
                              : Icons.filter_list,
                          color: selectedType != 'Todos' || selectedProvince != null || selectedZone != null
                              ? theme.colorScheme.onPrimary
                              : theme.colorScheme.onSurface,
                        ),
                        label: Text(
                          selectedType != 'Todos' || selectedProvince != null || selectedZone != null
                              ? 'Activos'
                              : 'Filtros',
                          style: TextStyle(
                            fontSize: 12,
                            color: selectedType != 'Todos' || selectedProvince != null || selectedZone != null
                                ? theme.colorScheme.onPrimary
                                : theme.colorScheme.onSurface,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.zero, // Remover padding interno
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          backgroundColor: selectedType != 'Todos' || selectedProvince != null || selectedZone != null
                              ? theme.colorScheme.primary
                              : null,
                          foregroundColor: selectedType != 'Todos' || selectedProvince != null || selectedZone != null
                              ? theme.colorScheme.onPrimary
                              : theme.colorScheme.onSurface,
                          side: BorderSide(
                            color: selectedType != 'Todos' || selectedProvince != null || selectedZone != null
                                ? theme.colorScheme.primary
                                : theme.colorScheme.outline,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Indicador de filtros activos (solo si hay filtros)
            if (selectedType != 'Todos' || selectedProvince != null || selectedZone != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle,
                      size: 16,
                      color: theme.colorScheme.primary, // Amarillo (color principal)
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Filtros aplicados: ${selectedType != 'Todos' ? selectedType : ''}${selectedProvince != null ? ' - ${selectedProvince}' : ''}${selectedZone != null ? ' - ${selectedZone}' : ''}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.primary, // Amarillo (color principal)
                          fontWeight: FontWeight.w600, // Bold para mejor visibilidad
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          selectedType = 'Todos';
                          selectedProvince = null;
                          selectedZone = null;
                        });
                      },
                      child: Text(
                        'Limpiar',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.primary, // Amarillo (color principal)
                          fontWeight: FontWeight.w600, // Bold para mejor visibilidad
                        ),
                      ),
                    ),
                  ],
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

                  final filteredEvents = filterEvents(
                    snapshot.data!,
                    type: selectedType,
                    province: selectedProvince,
                    zone: selectedZone,
                  );
                  
                  // Aplicar filtro de búsqueda
                  final normalizedQuery = normalize(_searchQuery);
                  //if (kDebugMode) {}
                  
                  final searchFilteredEvents = filteredEvents
                      .where((event) {
                        final normalizedTitle = normalize(event.title);
                        final normalizedSubtitle = normalize(event.subtitle);
                        final matchesTitle = normalizedTitle.contains(normalizedQuery);
                        final matchesSubtitle = normalizedSubtitle.contains(normalizedQuery);
                        final matches = matchesTitle || matchesSubtitle;
                        
                        /*if (kDebugMode && _searchQuery.isNotEmpty) {
                          if (matchesTitle || matchesSubtitle) {
                            print('  ✅ COINCIDE: "${event.title}"');
                            if (matchesTitle) print('    - Coincide en título');
                            if (matchesSubtitle) print('    - Coincide en subtítulo');
                          }
                        }*/

                        return matches;
                      })
                      .toList();

                  //if (kDebugMode) {
                    //print('✅ Eventos encontrados: ${searchFilteredEvents.length}');
                  //}

                  if (searchFilteredEvents.isEmpty && _searchQuery.isNotEmpty) {
                    return const Center(child: Text('No se encontraron eventos con ese nombre'));
                  }

                  return ListView.builder(
                    itemCount: searchFilteredEvents.length,
                    itemBuilder: (context, index) {
                      final event = searchFilteredEvents[index];
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
