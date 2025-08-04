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
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Eliminar'),
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
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Bloquear'),
            ),
          ],
        ),
      );
      if (confirmed == true) {
        await _blockUser();
      }
    }

    void _showReportDialog() {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Reportar usuario'),
          content: const Text('¿Por qué quieres reportar a este usuario?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Usuario reportado (demo)')),
                );
              },
              child: const Text('Reportar'),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Perfil")),
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
              const Divider(),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        minimumSize: const Size.fromHeight(48),
                      ),
                      icon: const Icon(Icons.person_off),
                      label: const Text('Eliminar match'),
                      onPressed: () async {
                        await _confirmAndDeleteMatch();
                      },
                    ),
                    const SizedBox(height: 12),
                    FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.orange,
                        minimumSize: const Size.fromHeight(48),
                      ),
                      icon: const Icon(Icons.flag_outlined),
                      label: const Text('Reportar usuario'),
                      onPressed: () {
                        _showReportDialog();
                      },
                    ),
                    const SizedBox(height: 12),
                    FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.grey.shade700,
                        minimumSize: const Size.fromHeight(48),
                      ),
                      icon: const Icon(Icons.block),
                      label: const Text('Bloquear usuario'),
                      onPressed: () async {
                        await _confirmAndBlockUser();
                      },
                    ),
                    
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
