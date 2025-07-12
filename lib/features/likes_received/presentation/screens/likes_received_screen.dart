import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:juvuit_flutter/core/widgets/custom_bottom_nav_bar.dart';
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
    if (_myId == null) return _notAuth();
    if (_isLoadingProfile) return _loading();

    return Scaffold(
      appBar: AppBar(title: const Text('Likes recibidos')),
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 2),
      body: FutureBuilder<List<QueryDocumentSnapshot>>(
        future: _repo.fetchLikes(_myId),
        builder: (ctx, snap) {
          if (snap.hasError)   return _error();
          if (!snap.hasData)   return _loading();
          final docs = snap.data!;
          if (docs.isEmpty)    return _empty();

          return GridView.builder(
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
                    // ---- SKELETON CARD ----
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
          );
        },
      ),
    );
  }

  Widget _notAuth()  => Scaffold(
    appBar: AppBar(title: const Text('Likes recibidos')),
    bottomNavigationBar: const CustomBottomNavBar(currentIndex: 2),
    body: const Center(child: Text('Usuario no autenticado')),
  );
  Widget _loading()  => const Center(child: CircularProgressIndicator());
  Widget _error()    => const Center(child: Text('Error al cargar'));
  Widget _empty()    => const Center(child: Text('No hay likes recibidos'));
}
