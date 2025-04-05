import 'package:flutter/material.dart';

class NoMoreProfilesCard extends StatelessWidget {
  final VoidCallback onSeeEvents;

  const NoMoreProfilesCard({super.key, required this.onSeeEvents});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.celebration, size: 80, color: Colors.amber),
            const SizedBox(height: 16),
            const Text(
              '¡Ya viste todos los perfiles para este evento!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: onSeeEvents,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Ver otros eventos'),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () {}, // sin acción por ahora
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.grey[700],
                side: BorderSide(color: Colors.grey.shade400),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
              child: const Text('Ajustar mis preferencias'),
            ),
          ],
        ),
      ),
    );
  }
}
