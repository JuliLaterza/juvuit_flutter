import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:juvuit_flutter/core/utils/colors.dart';
import 'package:juvuit_flutter/core/widgets/custom_bottom_nav_bar.dart';
import 'package:juvuit_flutter/core/utils/routes.dart';
import 'package:juvuit_flutter/features/profile/data/services/user_profile_service.dart';
import 'package:juvuit_flutter/features/profile/domain/models/user_profile.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  UserProfile? _userProfile;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    final service = UserProfileService();
    final profile = await service.getUserProfile(currentUser.uid);

    setState(() {
      _userProfile = profile;
      _isLoading = false;
    });
  }

  int calculateAge(DateTime birthDate) {
    final today = DateTime.now();
    int age = today.year - birthDate.year;
    if (today.month < birthDate.month ||
        (today.month == birthDate.month && today.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  void _showLogoutConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirmar'),
        content: const Text('¿Estás seguro que deseas cerrar la sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await FirebaseAuth.instance.signOut();
              if (mounted) {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  AppRoutes.login,
                  (_) => false,
                );
              }
            },
            child: const Text('Sí'),
          ),
        ],
      ),
    );
  }

  void _showSongsModal(BuildContext context) {
    if (_userProfile == null) return;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Top Canciones'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: _userProfile!.topSongs.map((s) => Text('• $s')).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_userProfile == null) {
      return const Scaffold(
        body: Center(child: Text('Perfil no encontrado')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: AppColors.white,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            Center(
              child: Builder(
                builder: (context) {
                  final photos = _userProfile!.photoUrls;
                  //print('photoUrls: $photos'); // Depuración

                  if (photos.isEmpty) {
                    return const CircleAvatar(
                      radius: 80,
                      backgroundImage: NetworkImage(
                        'https://tse2.mm.bing.net/th?id=OIP.9UPbYqPai-PXbgNHqMUxigHaHa&pid=Api',
                      ),
                    );
                  }



                  return CircleAvatar(
                    radius: 80,
                    backgroundImage: NetworkImage(photos[0]),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Column(
                children: [
                  Text(
                    _userProfile!.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.black,
                    ),
                  ),
                  if (_userProfile!.birthDate != null)
                    Text(
                      '${calculateAge(_userProfile!.birthDate!)} años',
                      style: const TextStyle(fontSize: 14, color: AppColors.gray),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                _userProfile!.description,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14, color: AppColors.gray),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () => _showSongsModal(context),
                  child: const Column(
                    children: [
                      Icon(Icons.music_note, color: AppColors.yellow),
                      SizedBox(height: 4),
                      Text('Top Canciones', style: TextStyle(fontSize: 12)),
                    ],
                  ),
                ),
                const SizedBox(width: 24),
                Column(
                  children: [
                    const Icon(Icons.local_bar, color: AppColors.yellow),
                    const SizedBox(height: 4),
                    Text(
                      _userProfile!.favoriteDrink,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(width: 24),
                Column(
                  children: [
                    const Icon(Icons.star, color: AppColors.yellow),
                    const SizedBox(height: 4),
                    Text(
                      _userProfile!.sign ?? '—',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
            const Divider(),
            const Text('Cuenta', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ListTile(
              leading: const Icon(Icons.person, color: AppColors.gray),
              title: const Text('Editar Perfil'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                // Navegar a edición de perfil
              },
            ),
            ListTile(
              leading: const Icon(Icons.lock, color: AppColors.gray),
              title: const Text('Privacidad'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {},
            ),
            const Divider(),
            const Text('Notificaciones', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            SwitchListTile(
              activeColor: AppColors.yellow,
              contentPadding: EdgeInsets.zero,
              title: const Text('Recibir notificaciones'),
              value: true,
              onChanged: (value) {},
            ),
            const Divider(),
            const Text('Ayuda', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ListTile(
              leading: const Icon(Icons.help_outline, color: AppColors.gray),
              title: const Text('Centro de ayuda'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.feedback_outlined, color: AppColors.gray),
              title: const Text('Enviar feedback'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {},
            ),
            const Divider(),
            const Text('Cuenta avanzada', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ListTile(
              leading: const Icon(Icons.logout, color: AppColors.gray),
              title: const Text('Cerrar sesión'),
              onTap: () => _showLogoutConfirmationDialog(context),
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.red),
              title: const Text('Eliminar cuenta'),
              titleTextStyle: const TextStyle(color: Colors.red),
              onTap: () {
                // Lógica para eliminar cuenta
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 3),
    );
  }
}
