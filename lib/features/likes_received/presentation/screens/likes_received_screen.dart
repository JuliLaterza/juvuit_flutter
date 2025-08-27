import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:juvuit_flutter/core/widgets/custom_bottom_nav_bar.dart';
import 'package:juvuit_flutter/core/widgets/theme_aware_logo.dart';
import 'package:juvuit_flutter/core/services/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:juvuit_flutter/features/likes_received/data/likes_repository.dart';
import 'package:juvuit_flutter/features/likes_received/presentation/widgets/swipe_card.dart';
import 'package:juvuit_flutter/features/matching/domain/match_helper.dart';
import 'package:juvuit_flutter/features/profile/data/services/user_profile_service.dart';
import 'package:juvuit_flutter/features/profile/domain/models/user_profile.dart';
import 'like_preview_screen.dart';

class LikesReceivedScreen extends StatefulWidget {
  const LikesReceivedScreen({super.key});
  @override
  State<LikesReceivedScreen> createState() => _LikesReceivedScreenState();
}

class _LikesReceivedScreenState extends State<LikesReceivedScreen> {
  final _repo = LikesRepository();
  final _myId = FirebaseAuth.instance.currentUser?.uid;

  UserProfile? _myProfile;
  bool _isLoadingProfile = true;

  @override
  void initState() {
    super.initState();
    _loadMyProfile();
  }

  Future<void> _loadMyProfile() async {
    if (_myId == null) return;
    final service = UserProfileService();
    final profile = await service.getUserProfile(_myId);
    setState(() {
      _myProfile = profile;
      _isLoadingProfile = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    if (_myId == null) return _notAuth();
    if (_isLoadingProfile) return _loading();

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(52),
        child: Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.onBackground.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
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
      ),
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 2),
      body: SafeArea(
        top: false,
        child: FutureBuilder<List<QueryDocumentSnapshot>>(
          future: _repo.fetchLikes(_myId),
          builder: (ctx, snap) {
            if (snap.hasError) return _error();
            if (!snap.hasData) return _loading();
            final docs = snap.data!;
            if (docs.isEmpty) return _empty();

            return Stack(
              children: [
                GridView.builder(
                  padding: const EdgeInsets.all(12),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12,
                    childAspectRatio: 0.65,
                  ),
                  itemCount: docs.length,
                  itemBuilder: (ctx, i) {
                    final doc     = docs[i];
                    final otherId = doc.id;
                    final eventId = doc.get('eventId') as String? ?? '';
                    return FutureBuilder<Map<String, dynamic>>(
                      future: _repo.fetchUserAndEvent(otherId, eventId),
                      builder: (c, s) {
                        if (s.connectionState == ConnectionState.waiting) {
                          return Card(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            elevation: 2,
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 80, height: 80,
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade300, shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Container(
                                    width: 60, height: 12, color: Colors.grey.shade300,
                                  ),
                                  const SizedBox(height: 8),
                                  Container(
                                    width: 80, height: 12, color: Colors.grey.shade300,
                                  ),
                                ],
                              ),
                            ),
                          );
                        }
                        if (s.hasError || !s.hasData) return _error();
                        final data = s.data!;
                        return SwipeCard(
                          photoUrl:   data['photoUrl'],
                          name:       data['name'],
                          age:        data['age'],
                          eventTitle: data['eventTitle'],
                          onReject: () async {
                            await FirebaseFirestore.instance
                                .collection('users')
                                .doc(_myId)
                                .collection('likesReceived')
                                .doc(otherId)
                                .delete();
                            setState(() {
                              docs.removeAt(i);
                            });
                          },
                          onInfo: () async {
                            final profile = await _repo.queryProfileByName(data['name']);
                            if (profile != null && context.mounted) {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => LikePreviewScreen(
                                    profile: profile,
                                    onLike: () async {
                                      await handleLikeAndMatch(
                                        currentUserId: _myId,
                                        likedUserId: otherId,
                                        eventId: eventId,
                                        context: context,
                                        currentUserPhoto: _myProfile?.photoUrls.isNotEmpty == true
                                            ? _myProfile!.photoUrls.first
                                            : 'https://via.placeholder.com/150',
                                        matchedUserPhoto: data['photoUrl'],
                                        matchedUserName: data['name'],
                                      );
                                    },
                                    onDislike: () async {
                                      await FirebaseFirestore.instance
                                          .collection('users')
                                          .doc(_myId)
                                          .collection('likesReceived')
                                          .doc(otherId)
                                          .delete();
                                    },
                                  ),
                                ),
                              );
                              setState(() {
                                docs.removeAt(i);
                              });
                            }
                          },
                          onAccept: () async {
                            await handleLikeAndMatch(
                              currentUserId: _myId,
                              likedUserId: otherId,
                              eventId: eventId,
                              context: context,
                              currentUserPhoto: _myProfile?.photoUrls.isNotEmpty == true
                                  ? _myProfile!.photoUrls.first
                                  : 'https://via.placeholder.com/150',
                              matchedUserPhoto: data['photoUrl'],
                              matchedUserName: data['name'],
                            );
                            setState(() {
                              docs.removeAt(i);
                            });
                          },
                        );
                      },
                    );
                  },
                ),
                if (!(_myProfile?.isPremium ?? false))
                  Positioned.fill(
                    child: Container(
                      color: Colors.white.withOpacity(0.6),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.lock, 
                                size: 48, 
                                color: theme.colorScheme.onBackground.withOpacity(0.5),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Descubrí quiénes te quieren conocer!',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 18, 
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.onBackground,
                                ),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: () {}, // futura navegación a premium
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: theme.colorScheme.primary,
                                  foregroundColor: theme.colorScheme.onPrimary,
                                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                ),
                                child: const Text('Activar Premium'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _notAuth() {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(52),
        child: Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.onBackground.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: AppBar(
            backgroundColor: theme.colorScheme.surface,
            elevation: 0,
            title: const HeaderLogo(),
            centerTitle: false,
          ),
        ),
      ),
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 2),
      body: Center(
        child: Text(
          'Usuario no autenticado',
          style: TextStyle(color: theme.colorScheme.onBackground),
        ),
      ),
    );
  }
  Widget _loading() => const Center(child: CircularProgressIndicator());
  Widget _error()   => const Center(child: Text('Error al cargar'));
  Widget _empty() {
    final theme = Theme.of(context);
    
    return Container(
      color: theme.colorScheme.surface.withOpacity(0.6),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.lock, 
                size: 48, 
                color: theme.colorScheme.onBackground.withOpacity(0.5),
              ),
              const SizedBox(height: 16),
              Text(
                'Descubrí quiénes te quieren conocer!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18, 
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onBackground,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {}, // futura navegación a premium
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: const Text('Activar Premium'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
