import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:juvuit_flutter/core/utils/colors.dart';
import 'package:juvuit_flutter/features/events/domain/models/event.dart';
import 'package:juvuit_flutter/features/matching/presentation/screens/matchingprofilescreen.dart';

class MatchingLoader extends StatefulWidget {
  final String orderBy;
  final String searchQuery;
  
  const MatchingLoader({
    super.key, 
    required this.orderBy,
    this.searchQuery = '',
  });

  @override
  State<MatchingLoader> createState() => _MatchingLoaderState();
}

class _MatchingLoaderState extends State<MatchingLoader> {
  List<Event> _events = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserEvents();
  }

  @override
  void didUpdateWidget(MatchingLoader oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.orderBy != widget.orderBy || oldWidget.searchQuery != widget.searchQuery) {
      _fetchUserEvents();
    }
  }

  Future<void> _fetchUserEvents() async {
    setState(() {
      _isLoading = true;
    });

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() {
        _isLoading = false;
        _events = [];
      });
      return;
    }

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('events')
          .where('attendees', arrayContains: user.uid)
          .get();

      final events = snapshot.docs.map((doc) => Event.fromFirestore(doc)).toList();

      // Filtrar por búsqueda
      List<Event> filteredEvents = events;
      if (widget.searchQuery.isNotEmpty) {
        filteredEvents = events.where((event) {
          final query = widget.searchQuery.toLowerCase();
          return event.title.toLowerCase().contains(query) ||
                 event.subtitle.toLowerCase().contains(query) ||
                 event.description.toLowerCase().contains(query);
        }).toList();
      }

      // Ordenar según el criterio
      if (widget.orderBy == 'fecha') {
        filteredEvents.sort((a, b) => a.date.compareTo(b.date));
      } else if (widget.orderBy == 'asistentes') {
        filteredEvents.sort((a, b) => b.attendees.length.compareTo(a.attendees.length));
      }

      setState(() {
        _events = filteredEvents;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _events = [];
      });
    }
  }

  Future<void> _dejarDeAsistir(Event event) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    try {
      final firestore = FirebaseFirestore.instance;
      final eventRef = firestore.collection('events').doc(event.id);
      final userRef = firestore.collection('users').doc(userId);

      // Remover usuario del evento
      await eventRef.update({
        'attendees': FieldValue.arrayRemove([userId]),
      });

      // Remover evento del usuario
      await userRef.update({
        'attendedEvents': FieldValue.arrayRemove([event.id]),
      });

      // Actualizar la lista local
      setState(() {
        _events.removeWhere((e) => e.id == event.id);
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('¡Has dejado de asistir a este evento!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al dejar de asistir al evento'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.yellow),
            ),
            const SizedBox(height: 16),
            Text(
              'Cargando eventos...',
              style: TextStyle(
                color: Theme.of(context).brightness == Brightness.dark 
                    ? AppColors.darkTextSecondary 
                    : AppColors.gray,
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    if (_events.isEmpty) {
      final isDark = Theme.of(context).brightness == Brightness.dark;
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              widget.searchQuery.isNotEmpty ? Icons.search_off : Icons.event_busy,
              size: 64,
              color: isDark ? AppColors.darkTextSecondary : AppColors.gray,
            ),
            const SizedBox(height: 16),
            Text(
              widget.searchQuery.isNotEmpty 
                ? 'No se encontraron eventos que coincidan con "${widget.searchQuery}"'
                : 'Todavía no te anotaste a ningún evento',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isDark ? AppColors.darkTextSecondary : AppColors.gray,
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _events.length,
      itemBuilder: (context, index) {
        final event = _events[index];
        return _buildEventCard(context, event);
      },
    );
  }

  Widget _buildEventCard(BuildContext context, Event event) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCardBackground : AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: isDark 
                ? Colors.black.withOpacity(0.3)
                : Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Imagen del evento
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                width: 60,
                height: 60,
                child: Image.network(
                  event.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: isDark ? AppColors.darkCardSurface : AppColors.darkWhite,
                      child: Icon(
                        Icons.image_not_supported,
                        size: 24,
                        color: isDark ? AppColors.darkTextSecondary : AppColors.gray,
                      ),
                    );
                  },
                ),
              ),
            ),
            
            const SizedBox(width: 12),
            
            // Información del evento
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Título
                  Text(
                    event.title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.darkTextPrimary : AppColors.black,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  const SizedBox(height: 4),
                  
                  // Información del evento
                  Row(
                    children: [
                      // Fecha
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            size: 14,
                            color: isDark ? AppColors.darkTextSecondary : AppColors.gray,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${event.date.day}/${event.date.month}/${event.date.year}',
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? AppColors.darkTextSecondary : AppColors.gray,
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(width: 16),
                      
                      // Asistentes
                      Row(
                        children: [
                          Icon(
                            Icons.people,
                            size: 14,
                            color: isDark ? AppColors.darkTextSecondary : AppColors.gray,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${event.attendees.length}',
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? AppColors.darkTextSecondary : AppColors.gray,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(width: 6),
            
            // Botón Conectar
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => MatchingProfilesScreen(event: event),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.yellow,
                foregroundColor: AppColors.black,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
                minimumSize: const Size(70, 36),
              ),
              child: const Text(
                'Conectar',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            
            const SizedBox(width: 6),
            
            // Botón de darse de baja (cruz)
            GestureDetector(
              onTap: () => _showLeaveEventDialog(event),
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  Icons.close,
                  size: 16,
                  color: Colors.red,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLeaveEventDialog(Event event) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Dejar de asistir',
            style: TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Text(
            '¿Estás seguro de que quieres dejar de asistir a ${event.title}?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Cancelar',
                style: TextStyle(color: AppColors.gray),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _dejarDeAsistir(event);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Dejar de asistir'),
            ),
          ],
        );
      },
    );
  }
}
