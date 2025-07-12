// lib/features/likes_received/presentation/screens/likes_received_screen.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:juvuit_flutter/core/widgets/custom_bottom_nav_bar.dart';
import 'package:juvuit_flutter/core/utils/routes.dart';
import 'package:juvuit_flutter/features/likes_received/data/likes_repository.dart';
import 'package:juvuit_flutter/features/likes_received/presentation/widgets/swipe_card.dart';
import 'package:juvuit_flutter/features/matching/domain/match_helper.dart';

class LikesReceivedScreen extends StatefulWidget {
  const LikesReceivedScreen({super.key});

  @override
  State<LikesReceivedScreen> createState() => _LikesReceivedScreenState();
}

class _LikesReceivedScreenState extends State<LikesReceivedScreen> {
  final _repo = LikesRepository();
  String? _myId;
  List<QueryDocumentSnapshot>? _docs;

  @override
  void initState() {
    super.initState();
    _myId = FirebaseAuth.instance.currentUser?.uid;
    if (_myId != null) {
      _repo.fetchLikes(_myId!).then((list) {
        setState(() => _docs = list);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_myId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Personas que te buscan!')),
        bottomNavigationBar: const CustomBottomNavBar(currentIndex: 2),
        body: const Center(child: Text('Usuario no autenticado')),
      );
    }
    if (_docs == null) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_docs!.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Personas que te buscan!')),
        bottomNavigationBar: const CustomBottomNavBar(currentIndex: 2),
        body: const Center(child: Text('No hay likes recibidos')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Personas que te buscan!')),
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 2),
      body: GridView.builder(
        padding: const EdgeInsets.all(12),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.65,
        ),
        itemCount: _docs!.length,
        itemBuilder: (context, index) {
          final doc     = _docs![index];
          final otherId = doc.id;
          final eventId = doc.get('eventId') as String? ?? '';
          final isLeft  = index % 2 == 0;

          return Dismissible(
            key: ValueKey(otherId),
            direction: isLeft
                ? DismissDirection.startToEnd
                : DismissDirection.endToStart,
            onDismissed: (_) {
              setState(() => _docs!.removeAt(index));
            },
            child: FutureBuilder<Map<String, dynamic>>(
              future: _repo.fetchUserAndEvent(otherId, eventId),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(child: Text('Error al cargar'));
                }
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final data = snapshot.data!;

                return SwipeCard(
                  photoUrl:   data['photoUrl'] as String,
                  name:       data['name'] as String,
                  age:        data['age'] as String,
                  eventTitle: data['eventTitle'] as String,
                  onReject: () {
                    setState(() => _docs!.removeAt(index));
                  },
                  onInfo: () async {
                    final profile = await _repo.queryProfileByName(data['name'] as String);
                    if (profile != null && mounted) {
                      Navigator.pushNamed(
                        context,
                        AppRoutes.profile_action,
                        arguments: {
                          'profile':    profile,
                          'eventTitle': data['eventTitle'],
                          'eventId':    eventId,
                          'myId':       _myId!,
                        },
                      );
                    }
                  },
                  onAccept: () async {
                    final localContext = context;
                    // obtener foto principal
                    final meDoc = await FirebaseFirestore.instance
                        .collection('users')
                        .doc(_myId!)
                        .get();
                    final photos = (meDoc.data()?['photoUrls'] as List<dynamic>?) ?? [];
                    final currentUserPhoto = photos.isNotEmpty ? photos.first as String : '';

                    final matched = await handleLikeAndMatch(
                      currentUserId:    _myId!,
                      likedUserId:      otherId,
                      eventId:          eventId,
                      context:          localContext,
                      currentUserPhoto: currentUserPhoto,
                      matchedUserPhoto: data['photoUrl'] as String,
                      matchedUserName:  data['name'] as String,
                    );

                    if (!mounted) return;
                    if (matched) {
                      setState(() => _docs!.removeAt(index));
                    }
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}
