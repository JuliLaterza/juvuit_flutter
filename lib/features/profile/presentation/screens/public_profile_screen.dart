import 'package:flutter/material.dart';
import 'package:juvuit_flutter/features/profile/domain/models/user_profile.dart';
import 'package:juvuit_flutter/features/matching/widgets/profile_card.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Función utilitaria para generar matchId de forma consistente
String generateMatchId(String userId1, String userId2) {
  final sortedIds = [userId1, userId2]..sort();
  return sortedIds.join('_');
}

class PublicProfileScreen extends StatelessWidget {
  final UserProfile profile;

  const PublicProfileScreen({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    final firestore = FirebaseFirestore.instance;

    Future<void> _blockUser() async {
      if (currentUserId == null) return;
      // 1. Bloquear usuario
      await firestore
          .collection('users')
          .doc(currentUserId)
          .collection('blocked')
          .doc(profile.userId)
          .set({'blockedAt': FieldValue.serverTimestamp()});
      // 2. Eliminar match
      final matchId = generateMatchId(currentUserId, profile.userId);
      await firestore.collection('matches').doc(matchId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Usuario bloqueado y match eliminado')),
      );
      Navigator.of(context).pop();
    }

    Future<void> _deleteMatch() async {
      if (currentUserId == null) return;
      final matchId = generateMatchId(currentUserId, profile.userId);
      await firestore.collection('matches').doc(matchId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Match eliminado')),
      );
      Navigator.of(context).pop();
    }

    Future<void> _confirmAndDeleteMatch() async {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Eliminar match'),
          content: const Text('¿Estás seguro de que quieres eliminar este match? Esta acción no se puede deshacer.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(
                'Cancelar',
                style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text(
                'Eliminar',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        ),
      );
      if (confirmed == true) {
        await _deleteMatch();
      }
    }

    Future<void> _confirmAndBlockUser() async {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Bloquear usuario'),
          content: const Text('¿Estás seguro de que quieres bloquear a este usuario? Esto también eliminará el match y no podrán interactuar más.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(
                'Cancelar',
                style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text(
                'Bloquear',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        ),
      );
      if (confirmed == true) {
        await _blockUser();
      }
    }



    void _showSecurityMenu() {
      final theme = Theme.of(context);
      
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
              // Opción Eliminar match
              ListTile(
                leading: Icon(
                  Icons.person_off,
                  color: Colors.red,
                  size: 24,
                ),
                title: Text(
                  'Eliminar match',
                  style: TextStyle(
                    fontSize: 16,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                subtitle: Text(
                  'Eliminar la conexión con este usuario',
                  style: TextStyle(
                    fontSize: 14,
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _confirmAndDeleteMatch();
                },
              ),
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
                  // Mostrar diálogo de reporte directamente
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
                              style: TextStyle(color: theme.colorScheme.onSurface),
                            ),
                          ),
                          TextButton(
                            onPressed: () async {
                              try {
                                // Aquí podrías guardar el reporte en Firebase
                                // await _saveReport(profile.userId, selectedReason);
                                
                                Navigator.pop(context);
                                
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Perfil reportado por: $selectedReason'),
                                    backgroundColor: Colors.orange,
                                    duration: const Duration(seconds: 3),
                                  ),
                                );
                              } catch (e) {
                                Navigator.pop(context);
                                
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Error al reportar: ${e.toString()}'),
                                    backgroundColor: Colors.red,
                                    duration: const Duration(seconds: 3),
                                  ),
                                );
                              }
                            },
                            child: const Text(
                              'Reportar',
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
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
                  _confirmAndBlockUser();
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      );
    }



    return Scaffold(
      appBar: AppBar(
        title: const Text("Perfil"),
        actions: [
          // Botón de seguridad
          IconButton(
            icon: Icon(
              Icons.security,
              color: Theme.of(context).colorScheme.onSurface,
              size: 24,
            ),
            onPressed: () => _showSecurityMenu(),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              ProfileCard(
                profile: profile,
                index: 0,
                currentImageIndex: 0,
                onDislike: () {},
                onCarouselChange: (_) {},
                onLike: () {},
                showActions: false,
              ),

            ],
          ),
        ),
      ),
    );
  }
}
