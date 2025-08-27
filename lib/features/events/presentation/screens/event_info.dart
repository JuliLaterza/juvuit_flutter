import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:juvuit_flutter/core/utils/colors.dart';
import '../../domain/models/event.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:juvuit_flutter/features/events/application/attend_event_service.dart';
import 'package:apple_maps_flutter/apple_maps_flutter.dart' as apple_maps;
import 'package:url_launcher/url_launcher.dart';
import 'package:juvuit_flutter/core/utils/routes.dart';

class EventInfoScreen extends StatefulWidget {
  const EventInfoScreen({super.key, required this.event});
  final Event event;

  @override
  State<EventInfoScreen> createState() => _EventInfoScreenState();
}

class _EventInfoScreenState extends State<EventInfoScreen> {
  bool isAttending = false;
  bool _isMapReady = false;
  apple_maps.AppleMapController? appleMapController;

  final apple_maps.LatLng _appleLocation = const apple_maps.LatLng(-34.48047028921573, -58.52066647214408);
  
  Set<apple_maps.Annotation> _appleAnnotations = {};

  @override
  void initState() {
    super.initState();
    _checkIfUserIsAttending();
    _initializeMapElements();
  }

  void _initializeMapElements() {
    _appleAnnotations = {
      apple_maps.Annotation(
        annotationId: apple_maps.AnnotationId('ubicacion_evento'),
        position: _appleLocation,
        infoWindow: const apple_maps.InfoWindow(title: 'Costanera Norte'),
      ),
    };
  }

  Future<void> _checkIfUserIsAttending() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;
    
    // Verificar directamente en el evento (sincronizado con eventCard.dart)
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

  Future<void> _handleAttendOrLeave() async {
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
      // Dejar de asistir
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
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Completá tus canciones y trago favoritos para poder asistir')),
                );
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
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('¡Estás asistiendo a este evento!')),
      );
    }
  }

  Future<bool> _showSongsDrinkModal() async {
    final theme = Theme.of(context);
    
    return await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: theme.colorScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(Icons.music_note, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                '¡Completá tu perfil!',
                style: TextStyle(
                  color: theme.colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Para asistir a eventos de fiesta, necesitás:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.music_note, size: 16, color: theme.colorScheme.primary),
                  const SizedBox(width: 8),
                  Text(
                    'Tus 3 canciones favoritas',
                    style: TextStyle(color: theme.colorScheme.onSurface),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.local_bar, size: 16, color: theme.colorScheme.primary),
                  const SizedBox(width: 8),
                  Text(
                    'Tu trago preferido',
                    style: TextStyle(color: theme.colorScheme.onSurface),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                'Cancelar', 
                style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop(true);
                // Navegar a la pantalla de completar perfil
                Navigator.pushNamed(context, AppRoutes.completeSongsDrink);
              },
              child: const Text(
                'Completar perfil',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        );
      },
    ) ?? false;
  }

  Future<void> _openExternalMap(double lat, double lng) async {
    final uri = Platform.isIOS
        ? Uri.parse('http://maps.apple.com/?q=$lat,$lng')
        : Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lng');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo abrir la app de mapas')),
      );
    }
  }

  Widget _buildPlatformMap() {
    if (Platform.isIOS) {
      return apple_maps.AppleMap(
        onMapCreated: (controller) => appleMapController = controller,
        initialCameraPosition: apple_maps.CameraPosition(target: _appleLocation, zoom: 15),
        annotations: _appleAnnotations,
        scrollGesturesEnabled: false,
        zoomGesturesEnabled: false,
      );
    } else {
      return const SizedBox.shrink(); // No mostrar nada en Android
    }
  }


  @override
  Widget build(BuildContext context) {
    final event = widget.event;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          event.title, 
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          )
        ),
        backgroundColor: theme.colorScheme.surface,
        foregroundColor: theme.colorScheme.onSurface,
        elevation: 0,
      ),
      backgroundColor: theme.colorScheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.network(event.imageUrl, width: double.infinity, height: 240, fit: BoxFit.cover),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.title, 
                      style: TextStyle(
                        fontSize: 22, 
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      )
                    ),
                    const SizedBox(height: 8),
                    Text(
                      event.subtitle, 
                      style: TextStyle(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontSize: 16,
                      )
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(Icons.calendar_today, size: 16, color: theme.colorScheme.primary),
                        const SizedBox(width: 8),
                        Text(
                          DateFormat('dd/MM/yyyy').format(event.date),
                          style: TextStyle(color: theme.colorScheme.onSurface),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.people, size: 16, color: theme.colorScheme.primary),
                        const SizedBox(width: 8),
                        Text(
                          '${event.attendeesCount} personas asistirán',
                          style: TextStyle(color: theme.colorScheme.onSurface),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.location_on, size: 16, color: theme.colorScheme.primary),
                        const SizedBox(width: 8),
                        Text(
                          'Costanera Norte',
                          style: TextStyle(color: theme.colorScheme.onSurface),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.attach_money, size: 16, color: theme.colorScheme.primary),
                        const SizedBox(width: 8),
                        Text(
                          'Costo: 170000 - 250000',
                          style: TextStyle(color: theme.colorScheme.onSurface),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      event.description,
                      style: TextStyle(
                        color: theme.colorScheme.onSurface,
                        fontSize: 16,
                        height: 1.5,
                      )
                    ),
                    const SizedBox(height: 16),
                    GestureDetector(
                      onTap: () => _openExternalMap(_appleLocation.latitude, _appleLocation.longitude),
                      child: AbsorbPointer(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            height: 200,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: theme.colorScheme.outline.withOpacity(0.3),
                              ),
                            ),
                            child: _buildPlatformMap(),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _handleAttendOrLeave,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isAttending 
                                  ? Colors.redAccent 
                                  : theme.colorScheme.primary,
                              foregroundColor: isAttending 
                                  ? Colors.white 
                                  : theme.colorScheme.onPrimary,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: Text(
                              isAttending ? 'Dejar de asistir' : 'Asistir',
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              print("Compartir evento");
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: theme.colorScheme.primary,
                              side: BorderSide(color: theme.colorScheme.primary),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: const Text(
                              'Compartir',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
