// lib/features/likes_received/presentation/screens/likes_received_screen.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:juvuit_flutter/core/widgets/custom_bottom_nav_bar.dart';
import 'package:juvuit_flutter/features/likes_received/data/likes_repository.dart';
import 'package:juvuit_flutter/features/likes_received/presentation/widgets/swipe_card.dart';
//import 'package:juvuit_flutter/features/profile/domain/models/user_profile.dart';

class LikesReceivedScreen extends StatefulWidget {
  const LikesReceivedScreen({Key? key}) : super(key: key);
  @override
  State<LikesReceivedScreen> createState() => _LikesReceivedScreenState();
}

class _LikesReceivedScreenState extends State<LikesReceivedScreen> {
  final _repo = LikesRepository();
  final _myId = FirebaseAuth.instance.currentUser?.uid;

  @override
  Widget build(BuildContext context) {
    if (_myId == null) return _notAuth();
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
            itemBuilder: (ctx,i) {
              final doc     = docs[i];
              final otherId = doc.id;
              final eventId = doc.get('eventId') as String? ?? '';
              return FutureBuilder<Map<String, dynamic>>(
                future: _repo.fetchUserAndEvent(otherId, eventId),
                builder: (c,s) {
                  if (s.hasError)  return _error();
                  if (!s.hasData)  return _loading();
                  final data = s.data!;
                  return SwipeCard(
                    photoUrl:   data['photoUrl'],
                    name:       data['name'],
                    age:        data['age'],
                    eventTitle: data['eventTitle'],
                    onReject: () {/*…*/},
                    onInfo:   () async {
                      final profile = await _repo.queryProfileByName(data['name']);
                      if (profile != null && context.mounted) {
                        Navigator.pushNamed(
                          context,
                          '/public_profile',
                          arguments: {'profile': profile},
                        );
                      }
                    },
                    onAccept: () {/*…*/},
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
