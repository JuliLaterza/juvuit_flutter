import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:juvuit_flutter/core/widgets/custom_bottom_nav_bar.dart';
import 'package:juvuit_flutter/core/utils/routes.dart';
import 'package:juvuit_flutter/core/widgets/theme_aware_logo.dart';
import 'package:juvuit_flutter/core/services/theme_provider.dart';
import 'package:juvuit_flutter/features/profile/data/services/user_profile_service.dart';
import 'package:juvuit_flutter/features/profile/domain/models/user_profile.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  UserProfile? _userProfile;
  bool _isLoading = true;
  late final PageController _pageController;
  int _currentPage = 0;
  bool _isDescriptionExpanded = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.85);
    _loadProfile();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
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
  /*
  void _showSongsModal(BuildContext context) {
    if (_userProfile == null) return;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Top Canciones'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: _userProfile!.topSongs.map((s) {
            final title = s['title'] ?? '';
            final artist = s['artist'] ?? '';
            return Text('• $title - $artist');
          }).toList(),
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
  */

  void _showSongsModal(BuildContext context) {
    if (_userProfile == null) return;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Top Canciones'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: _userProfile!.topSongs.map((song) {
            final title = song['title'] ?? '';
            final artist = song['artist'] ?? '';
            final imageUrl = song['imageUrl'] ?? '';
            return ListTile(
              leading: imageUrl.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        imageUrl,
                        width: 48,
                        height: 48,
                        fit: BoxFit.cover,
                      ),
                    )
                  : const Icon(Icons.music_note),
              title: Text(title),
              subtitle: Text(artist),
            );
          }).toList(),
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
  bool _notificationsEnabled = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
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
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(52),
        child: AppBar(
          backgroundColor: theme.colorScheme.surface,
          elevation: 0,
          title: const HeaderLogo(),
          centerTitle: false,
          actions: [
            Consumer<ThemeProvider>(
              builder: (context, themeProvider, child) {
                return IconButton(
                  onPressed: () {
                    themeProvider.toggleTheme();
                  },
                  icon: Icon(
                    themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode,
                    color: theme.colorScheme.onSurface,
                  ),
                );
              },
            ),
            const SizedBox(width: 8),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SafeArea(
              top: false,
              child: ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  Column(
                    children: [
                      SizedBox(
                        height: 240,
                        child: Builder(
                          builder: (context) {
                            final photos = _userProfile!.photoUrls;
                            if (photos.isEmpty) {
                              return ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: Image.network(
                                  'https://tse2.mm.bing.net/th?id=OIP.9UPbYqPai-PXbgNHqMUxigHaHa&pid=Api',
                                  width: double.infinity,
                                  height: 240,
                                  fit: BoxFit.cover,
                                ),
                              );
                            }
                            return PageView.builder(
                              itemCount: photos.length,
                              controller: _pageController,
                              onPageChanged: (index) {
                                setState(() {
                                  _currentPage = index;
                                });
                              },
                              itemBuilder: (context, index) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(16),
                                    child: Image.network(
                                      photos[index],
                                      width: double.infinity,
                                      height: 240,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (_userProfile!.photoUrls.isNotEmpty)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            _userProfile!.photoUrls.length,
                            (index) => Container(
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _currentPage == index ? theme.colorScheme.primary : theme.colorScheme.onSurface.withOpacity(0.3),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '${_userProfile!.name},',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.onBackground,
                              ),
                            ),
                            if (_userProfile!.birthDate != null) ...[
                              const SizedBox(width: 8),
                              Text(
                                '${calculateAge(_userProfile!.birthDate!)}',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.onBackground,
                                ),
                              ),
                            ]
                          ],
                        ),
                        if (_userProfile!.description.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Column(
                              children: [
                                Text(
                                  _userProfile!.description,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: 14, color: theme.colorScheme.onSurface.withOpacity(0.6)),
                                  maxLines: _isDescriptionExpanded ? null : 3,
                                  overflow: _isDescriptionExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
                                ),
                                if (_userProfile!.description.length > 65) // Puedes ajustar el umbral
                                  TextButton(
                                    onPressed: () {
                                      setState(() {
                                        _isDescriptionExpanded = !_isDescriptionExpanded;
                                      });
                                    },
                                    child: Text(_isDescriptionExpanded ? 'Ver menos' : 'Ver más'),
                                  ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () => _showSongsModal(context),
                        child: Column(
                          children: [
                            Icon(Icons.music_note, color: theme.colorScheme.primary),
                            const SizedBox(height: 8),
                            const Text('Canciones', style: TextStyle(fontSize: 14)),
                          ],
                        ),
                      ),
                      const SizedBox(width: 24),
                      Column(
                        children: [
                          Icon(Icons.local_bar, color: theme.colorScheme.primary),
                          const SizedBox(height: 8),
                          Text(
                            _userProfile!.favoriteDrink,
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                      const SizedBox(width: 24),
                      Column(
                        children: [
                          Icon(Icons.star, color: theme.colorScheme.primary),
                          const SizedBox(height: 8),
                          Text(
                            _userProfile!.sign ?? '—',
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const Divider(),
                  const Text('Cuenta', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  ListTile(
                    leading: Icon(Icons.person, color: theme.colorScheme.onSurface.withOpacity(0.6)),
                    title: const Text('Editar Perfil'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      Navigator.pushNamed(context, AppRoutes.editProfile);
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.tune, color: theme.colorScheme.onSurface.withOpacity(0.6)),
                    title: const Text('Preferencias'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      Navigator.pushNamed(context, AppRoutes.matchingPreferences);
                    },
                  ),
                  const Divider(),
                  const Text('Seguridad', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  ListTile(
                    leading: const Icon(Icons.emergency, color: Colors.red),
                    title: const Text('Botón antipánico'),
                    subtitle: const Text('Configurar contacto de emergencia'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      Navigator.pushNamed(context, AppRoutes.emergencyContact);
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.health_and_safety, color: Colors.blue),
                    title: const Text('Líneas de emergencia'),
                    subtitle: const Text('Recursos de ayuda profesional'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () async {
                      const url = 'https://findahelpline.com/es-ES/countries/ar';
                      try {
                        await launchUrl(Uri.parse(url));
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('No se pudo abrir el enlace')),
                        );
                      }
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.lock, color: theme.colorScheme.onSurface.withOpacity(0.6)),
                    title: const Text('Privacidad'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {},
                  ),
                  const Divider(),
                  const Text('Notificaciones', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Recibir notificaciones'),
                      Switch(
                        value: _notificationsEnabled,
                        activeColor: theme.colorScheme.primary,
                        onChanged: (value) {
                          setState(() {
                            _notificationsEnabled = value;
                          });
                        },
                      ),
                    ],
                  ),

                  const Divider(),
                  const Text('Ayuda', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  ListTile(
                    leading: Icon(Icons.help_outline, color: theme.colorScheme.onSurface.withOpacity(0.6)),
                    title: const Text('Centro de ayuda'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      Navigator.pushNamed(context, AppRoutes.helpCenter);
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.feedback_outlined, color: theme.colorScheme.onSurface.withOpacity(0.6)),
                    title: const Text('Enviar feedback'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      Navigator.pushNamed(context, AppRoutes.feedback);
                    },
                  ),
                  const Divider(),
                  const Text('Cuenta avanzada', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  ListTile(
                    leading: Icon(Icons.logout, color: theme.colorScheme.onSurface.withOpacity(0.6)),
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
          ),
        ],
      ),
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 4),
    );
  }
}
