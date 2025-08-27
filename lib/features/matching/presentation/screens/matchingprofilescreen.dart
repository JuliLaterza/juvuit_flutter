import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:juvuit_flutter/core/utils/colors.dart';
import 'package:juvuit_flutter/features/events/domain/models/event.dart';
import 'package:juvuit_flutter/features/profile/domain/models/user_profile.dart';
import 'package:juvuit_flutter/features/matching/controllers/matching_profiles_controller.dart';
import '../../widgets/profile_card.dart';
import '../../widgets/NoMoreProfilesCard.dart';
import '../../widgets/reencounter_profile_card.dart';

class MatchingProfilesScreen extends StatefulWidget {
  final Event event;
  const MatchingProfilesScreen({super.key, required this.event});

  @override
  State<MatchingProfilesScreen> createState() => _MatchingProfilesScreenState();
}

class _MatchingProfilesScreenState extends State<MatchingProfilesScreen> {
  final PageController _pageController = PageController();
  late final MatchingProfilesController _controller;
  List<UserProfile> _profiles = [];
  bool _isLoading = true;
  Set<String> reencounterUserIds = {};

  @override
  void initState() {
    super.initState();
    _controller = MatchingProfilesController(pageController: _pageController);
    

    
    _loadData();
  }

  Future<void> _loadData() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    // Resetear contadores para nueva sesión
    _controller.resetForNewSession();

    final currentUserProfile = await _controller.loadCurrentUserProfile();
    if (currentUserProfile == null) return;

    // Inicializar sistema de tracking de matches
    await _controller.initializeMatchesTracking();

    // Cargar primer lote de perfiles
    await _controller.loadNextBatch(widget.event);
    
    final matchesSnapshot = await FirebaseFirestore.instance
        .collection('matches')
        .where('users', arrayContains: currentUser.uid)
        .get();

    final Set<String> seenButNotChatted = {};
    for (final doc in matchesSnapshot.docs) {
      final data = doc.data();
      final users = List<String>.from(data['users']);
      final otherUserId = users.firstWhere((uid) => uid != currentUser.uid);
      final lastMessage = data['lastMessage'];
      if (lastMessage == null || lastMessage.toString().trim().isEmpty) {
        seenButNotChatted.add(otherUserId);
      }
    }

    setState(() {
      _profiles = _controller.profiles;
      reencounterUserIds = seenButNotChatted;
      _isLoading = false;
    });


  }

  // Función para mostrar animación de match retroactivo
  void _showRetroactiveMatchAnimation(String otherUserId, String matchId) async {
    try {
      // Obtener información del otro usuario
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(otherUserId)
          .get();
      
      if (userDoc.exists) {
        final userData = userDoc.data()!;
        final otherUserName = userData['name'] ?? 'Usuario';
        final otherUserPhotoUrl = (userData['photoUrls'] as List).isNotEmpty 
            ? userData['photoUrls'][0] 
            : 'https://via.placeholder.com/150';
        
        // Marcar match como mostrado
        _controller.markMatchAsShown(matchId);
        
        // Mostrar animación usando el controlador
        _controller.showRetroactiveMatchAnimation(
          context, 
          matchId, 
          otherUserId, 
          otherUserName, 
          otherUserPhotoUrl
        );
      }
    } catch (e) {
      print('Error showing retroactive match animation: $e');
    }
  }

  void _showSecurityMenu(BuildContext context) {
    final theme = Theme.of(context);
    
    // Obtener el perfil actual
    final currentIndex = _pageController.hasClients ? _pageController.page?.round() ?? 0 : 0;
    if (currentIndex >= _profiles.length) return; // No mostrar si estamos en "NoMoreProfilesCard"
    
    final currentProfile = _profiles[currentIndex];
    
    showModalBottomSheet(
      context: context,
      backgroundColor: theme.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Indicador de arrastre
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurface.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            // Título
            Text(
              'Opciones de seguridad',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 20),
            // Opción Reportar
            ListTile(
              leading: Icon(
                Icons.report,
                color: Colors.orange,
                size: 24,
              ),
              title: Text(
                'Reportar perfil',
                style: TextStyle(
                  fontSize: 16,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              subtitle: Text(
                'Reportar contenido inapropiado',
                style: TextStyle(
                  fontSize: 14,
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                _showReportDialog(context, currentProfile);
              },
            ),
            // Opción Bloquear
            ListTile(
              leading: Icon(
                Icons.block,
                color: Colors.red,
                size: 24,
              ),
              title: Text(
                'Bloquear usuario',
                style: TextStyle(
                  fontSize: 16,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              subtitle: Text(
                'Dejar de ver este perfil',
                style: TextStyle(
                  fontSize: 14,
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                _showBlockDialog(context, currentProfile);
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _showReportDialog(BuildContext context, UserProfile profile) {
    final theme = Theme.of(context);
    String selectedReason = 'Contenido inapropiado';
    
    final List<String> reportReasons = [
      'Contenido inapropiado',
      'Perfil falso o spam',
      'Acoso o comportamiento abusivo',
      'Información personal falsa',
      'Contenido ofensivo',
      'Menor de edad',
      'Otro motivo',
    ];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(
            'Reportar perfil',
            style: TextStyle(color: theme.colorScheme.onSurface),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Selecciona el motivo del reporte:',
                style: TextStyle(
                  color: theme.colorScheme.onSurface,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                child: DropdownButtonFormField<String>(
                  value: selectedReason,
                  isExpanded: true,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: theme.colorScheme.outline.withOpacity(0.3)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: theme.colorScheme.outline.withOpacity(0.3)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: theme.colorScheme.primary),
                    ),
                    hintText: 'Seleccionar motivo',
                  ),
                  dropdownColor: theme.colorScheme.surface,
                  style: TextStyle(
                    color: theme.colorScheme.onSurface,
                    fontSize: 14,
                  ),
                  items: reportReasons.map((String reason) {
                    return DropdownMenuItem<String>(
                      value: reason,
                      child: Text(
                        reason,
                        style: TextStyle(
                          color: theme.colorScheme.onSurface,
                          fontSize: 14,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedReason = newValue!;
                    });
                  },
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Tu reporte nos ayuda a mantener la comunidad segura.',
                style: TextStyle(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                  fontSize: 12,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancelar',
                style: TextStyle(color: theme.colorScheme.primary),
              ),
            ),
            TextButton(
              onPressed: () async {
                try {
                  // Guardar el reporte en Firebase
                  await _saveReport(profile.userId, selectedReason);
                  
                  // Cerrar el diálogo después de guardar exitosamente
                  Navigator.pop(context);
                  
                  // Mostrar mensaje de éxito
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Perfil reportado por: $selectedReason'),
                        backgroundColor: Colors.orange,
                        duration: const Duration(seconds: 3),
                      ),
                    );
                  }
                } catch (e) {
                  // Cerrar el diálogo incluso si hay error
                  Navigator.pop(context);
                  
                  // Mostrar mensaje de error
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error al reportar: ${e.toString()}'),
                        backgroundColor: Colors.red,
                        duration: const Duration(seconds: 3),
                      ),
                    );
                  }
                }
              },
              child: Text(
                'Reportar',
                style: TextStyle(color: Colors.orange),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showBlockDialog(BuildContext context, UserProfile profile) {
    final theme = Theme.of(context);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Bloquear usuario',
          style: TextStyle(color: theme.colorScheme.onSurface),
        ),
        content: Text(
          '¿Estás seguro de que quieres bloquear a ${profile.name}? No volverás a ver este perfil.',
          style: TextStyle(color: theme.colorScheme.onSurface),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancelar',
              style: TextStyle(color: theme.colorScheme.primary),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Aquí iría la lógica para bloquear al usuario
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Usuario bloqueado'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            child: Text(
              'Bloquear',
              style: TextStyle(color: Colors.orange),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _saveReport(String reportedUserId, String reason) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      throw Exception('Usuario no autenticado');
    }

    try {
      await FirebaseFirestore.instance.collection('reports').add({
        'reportedUserId': reportedUserId,
        'reporterUserId': currentUser.uid,
        'reason': reason,
        'timestamp': FieldValue.serverTimestamp(),
        'status': 'pending',
        'eventId': widget.event.id,
        'eventName': widget.event.title,
      });
    } catch (e) {
      throw Exception('Error al guardar el reporte: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final theme = Theme.of(context);

    return StreamBuilder<QuerySnapshot>(
      stream: _controller.matchesStream,
      builder: (context, snapshot) {
        // Procesar nuevos matches si los hay
        if (snapshot.hasData) {
          for (final doc in snapshot.data!.docs) {
            final matchId = doc.id;
            final data = doc.data() as Map<String, dynamic>;
            final users = List<String>.from(data['users']);
            final currentUserId = FirebaseAuth.instance.currentUser?.uid;
            
            if (currentUserId != null && users.contains(currentUserId)) {
              final otherUserId = users.firstWhere((uid) => uid != currentUserId);
              
              // Verificar si es un match nuevo (no anticipado)
              if (_controller.isNewMatch(matchId)) {

                // Obtener información del otro usuario y mostrar animación
                _showRetroactiveMatchAnimation(otherUserId, matchId);
              }
            }
          }
        }

        return Scaffold(
          appBar: AppBar(
            title: Text('Wit Ü', style: TextStyle(color: theme.colorScheme.onSurface)),
            backgroundColor: theme.colorScheme.surface,
            centerTitle: true,
            elevation: 0,
            actions: [
              // Botón de seguridad
              IconButton(
                icon: Icon(
                  Icons.security,
                  color: theme.colorScheme.onSurface,
                  size: 24,
                ),
                onPressed: () => _showSecurityMenu(context),
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: PageView.builder(
            scrollDirection: Axis.vertical,
            controller: _pageController,
            itemCount: _profiles.length + 1,
            itemBuilder: (context, index) {
              if (index == _profiles.length) {
                return NoMoreProfilesCard(onSeeEvents: () => Navigator.pop(context));
              }

              final profile = _profiles[index];
              final currentIndex = _controller.currentCarouselIndex[index] ?? 0;

              if (reencounterUserIds.contains(profile.userId)) {
                return ReencounterProfileCard(
                  profile: profile,
                  index: index,
                  currentImageIndex: currentIndex,
                  onDislike: () {
                    _controller.onDislike(_profiles);
                    setState(() {
                      _profiles = _controller.profiles;
                    });
                  },
                  onCarouselChange: (imgIndex) {
                    setState(() {
                      _controller.currentCarouselIndex[index] = imgIndex;
                    });
                  },
                );
              }

              return ProfileCard(
                profile: profile,
                index: index,
                currentImageIndex: currentIndex,
                onLike: () async {
                  await _controller.onLike(
                    context: context,
                    profiles: _profiles,
                    event: widget.event,
                  );
                  setState(() {
                    _profiles = _controller.profiles;
                  });
                },
                onDislike: () {
                  _controller.onDislike(_profiles);
                  setState(() {
                    _profiles = _controller.profiles;
                  });
                },
                onCarouselChange: (imgIndex) {
                  setState(() {
                    _controller.currentCarouselIndex[index] = imgIndex;
                  });
                },
                showActions: true,
              );
            },
          ),
        );
      },
    );
  }
}
