import 'package:flutter/material.dart';

class MatchPopup extends StatelessWidget {
  final String currentUserPhoto;
  final String matchedUserPhoto;
  final String matchedUserName;
  final VoidCallback onMessagePressed;

  const MatchPopup({
    super.key,
    required this.currentUserPhoto,
    required this.matchedUserPhoto,
    required this.matchedUserName,
    required this.onMessagePressed,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.yellow[100],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '¡Conexión lograda! 🎉',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildProfileImage(currentUserPhoto),
                const SizedBox(width: 16),
                _buildProfileImage(matchedUserPhoto),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              'Conectaste con $matchedUserName',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: onMessagePressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: const Text('Enviar un mensaje'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileImage(String url) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(50),
      child: Image.network(
        url,
        width: 80,
        height: 80,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => const Icon(Icons.error, size: 60),
      ),
    );
  }
}
