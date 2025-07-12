// lib/features/likes/presentation/screens/likes_received_screen.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:juvuit_flutter/core/widgets/custom_bottom_nav_bar.dart';
import 'package:juvuit_flutter/features/profile/domain/models/user_profile.dart';

class LikesReceivedScreen extends StatelessWidget {
  const LikesReceivedScreen({super.key});

  Future<void> _goToProfile(BuildContext context, String personName) async {
    final query = await FirebaseFirestore.instance
        .collection('users')
        .where('name', isEqualTo: personName)
        .limit(1)
        .get();

    if (query.docs.isNotEmpty) {
      final doc = query.docs.first;
      final profile = UserProfile.fromMap(doc.id, doc.data());
      if (context.mounted) {
        Navigator.pushNamed(
          context,
          '/public_profile',
          arguments: {'profile': profile},
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final current = FirebaseAuth.instance.currentUser;
    if (current == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Likes recibidos')),
        bottomNavigationBar: const CustomBottomNavBar(currentIndex: 2),
        body: const Center(child: Text('Usuario no autenticado')),
      );
    }
    final myId = current.uid;

    return Scaffold(
      appBar: AppBar(title: const Text('Likes recibidos')),
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 2),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(myId)
            .collection('likesReceived')
            .snapshots(),
        builder: (context, snap) {
          if (snap.hasError) {
            return Center(child: Text('Error: ${snap.error}'));
          }
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final likes = snap.data!.docs;
          if (likes.isEmpty) {
            return const Center(child: Text('No hay likes recibidos'));
          }

          return GridView.builder(
            padding: const EdgeInsets.all(12),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.65,
            ),
            itemCount: likes.length,
            itemBuilder: (ctx, i) {
              final doc = likes[i];
              final otherId = doc.id;
              final eventId = doc.get('eventId') as String? ?? '';

              return FutureBuilder<Map<String, dynamic>>(
                future: _fetchData(otherId, eventId),
                builder: (ctx2, fb) {
                  if (fb.hasError) {
                    return const Center(child: Text('Error al cargar'));
                  }
                  if (!fb.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final data = fb.data!;
                  return SwipeCard(
                    photoUrl: data['photoUrl'] as String,
                    name: data['name'] as String,
                    age: data['age'] as String,
                    eventTitle: data['eventTitle'] as String,
                    onReject: () { /*…*/ },
                    onInfo: () => _goToProfile(context, data['name'] as String),
                    onAccept: () { /*…*/ },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Future<Map<String, dynamic>> _fetchData(
      String userId, String eventId) async {
    final u = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .get();
    final e = await FirebaseFirestore.instance
        .collection('events')
        .doc(eventId)
        .get();

    final photos = (u.data()?['photoUrls'] as List<dynamic>?) ?? [];
    final name = u.data()?['name'] as String? ?? '';
    final age = u.data()?['age']?.toString() ?? '';
    final eventTitle = e.exists
        ? (e.data()?['title'] as String?) ?? ''
        : '';

    return {
      'photoUrl': photos.isNotEmpty ? photos.first as String : '',
      'name': name,
      'age': age,
      'eventTitle': eventTitle,
    };
  }
}

class SwipeCard extends StatelessWidget {
  final String photoUrl, name, age, eventTitle;
  final VoidCallback onReject, onInfo, onAccept;

  const SwipeCard({
    Key? key,
    required this.photoUrl,
    required this.name,
    required this.age,
    required this.eventTitle,
    required this.onReject,
    required this.onInfo,
    required this.onAccept,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.hardEdge,
      child: Stack(
        children: [
          Positioned.fill(
            child: photoUrl.isNotEmpty
                ? Image.network(photoUrl, fit: BoxFit.cover)
                : Container(color: Colors.grey[300]),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: 80,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  stops: [0.0, 0.3],
                  colors: [Colors.black54, Colors.transparent],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              decoration: const BoxDecoration(
                color: Colors.black45,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$name, $age',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    eventTitle,
                    style:
                        const TextStyle(color: Colors.white70, fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.clear),
                        color: Colors.white,
                        splashRadius: 20,
                        onPressed: onReject,
                      ),
                      IconButton(
                        icon: const Icon(Icons.info_outline),
                        color: Colors.white,
                        splashRadius: 20,
                        onPressed: onInfo,
                      ),
                      IconButton(
                        icon: const Icon(Icons.favorite),
                        color: const Color(0xFFFFD600),
                        splashRadius: 20,
                        onPressed: onAccept,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
