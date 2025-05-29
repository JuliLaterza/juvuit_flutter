import 'package:flutter/material.dart';
import 'package:juvuit_flutter/features/profile/domain/models/user_profile.dart';
import 'package:juvuit_flutter/features/matching/widgets/profile_card.dart';

class PublicProfileScreen extends StatelessWidget {
  final UserProfile profile;

  const PublicProfileScreen({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
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
                      onPressed: () {
                        // TODO: lógica eliminar match
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
                        // TODO: abrir modal de reporte
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
                      onPressed: () {
                        // TODO: lógica bloquear
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
