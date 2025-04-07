import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:juvuit_flutter/core/widgets/custom_bottom_nav_bar.dart';
import 'package:juvuit_flutter/core/utils/routes.dart';
import 'package:intl/intl.dart';

class ChatsScreen extends StatefulWidget {
  const ChatsScreen({super.key});

  @override
  State<ChatsScreen> createState() => _ChatsScreenState();
}

class _ChatsScreenState extends State<ChatsScreen> {
  List<Map<String, dynamic>> newMatches = [];
  List<Map<String, dynamic>> activeChats = [];
  final currentUserId = FirebaseAuth.instance.currentUser?.uid;

  @override
  void initState() {
    super.initState();
    fetchMatches();
  }

  Future<void> fetchMatches() async {
    if (currentUserId == null) return;

    final matchesSnapshot = await FirebaseFirestore.instance
        .collection('matches')
        .where('users', arrayContains: currentUserId)
        .get();

    final List<String> otherUserIds = [];
    final Map<String, String> matchToUserMap = {};

    for (final doc in matchesSnapshot.docs) {
      final users = List<String>.from(doc['users']);
      final otherUserId = users.firstWhere((uid) => uid != currentUserId);
      otherUserIds.add(otherUserId);
      matchToUserMap[otherUserId] = doc.id;
    }

    if (otherUserIds.isEmpty) return;

    final usersSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where(FieldPath.documentId, whereIn: otherUserIds)
        .get();

    final List<Map<String, dynamic>> tempNewMatches = [];
    final List<Map<String, dynamic>> tempActiveChats = [];

    for (final doc in usersSnapshot.docs) {
      final data = doc.data();
      final matchId = matchToUserMap[doc.id];
      if (matchId == null) continue;

      final photoUrl = (data['photoUrls'] as List).isNotEmpty ? data['photoUrls'][0] : null;

      final chatSnapshot = await FirebaseFirestore.instance
          .collection('messages')
          .doc(matchId)
          .collection('chats')
          .orderBy('timestamp', descending: true)
          .limit(1)
          .get();

      final matchData = {
        'userId': doc.id,
        'name': data['name'] ?? 'Usuario',
        'photoUrl': photoUrl,
        'matchId': matchId,
      };

      if (chatSnapshot.docs.isEmpty) {
        tempNewMatches.add(matchData);
      } else {
        final lastMessage = chatSnapshot.docs.first.data();
        matchData['lastMessage'] = lastMessage['text'] ?? '';
        matchData['lastTimestamp'] = lastMessage['timestamp'] != null
            ? (lastMessage['timestamp'] as Timestamp).toDate()
            : null;
        tempActiveChats.add(matchData);
      }
    }

    setState(() {
      newMatches = tempNewMatches;
      activeChats = tempActiveChats;
    });
  }

  String formatTime(DateTime? dateTime) {
    if (dateTime == null) return '';
    return DateFormat('HH:mm').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(centerTitle: true),
      body: Column(
        children: [
          Container(
            height: 120,
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: newMatches.length,
              itemBuilder: (context, index) {
                final match = newMatches[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            AppRoutes.chat,
                            arguments: {
                              'matchId': match['matchId'],
                              'personName': match['name'],
                              'personPhotoUrl': match['photoUrl'],
                            },
                          );
                        },
                        child: CircleAvatar(
                          radius: 35,
                          backgroundColor: Colors.grey.shade300,
                          child: match['photoUrl'] != null
                              ? ClipOval(
                                  child: CachedNetworkImage(
                                    imageUrl: match['photoUrl'],
                                    width: 70,
                                    height: 70,
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) => const CircularProgressIndicator(strokeWidth: 2),
                                    errorWidget: (context, url, error) => const Icon(Icons.person, color: Colors.white, size: 35),
                                  ),
                                )
                              : const Icon(Icons.person, size: 35, color: Colors.white),
                        ),
                      ),
                      const SizedBox(height: 6),
                      SizedBox(
                        width: 70,
                        child: Text(
                          match['name'],
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView.builder(
              itemCount: activeChats.length,
              itemBuilder: (context, index) {
                final chat = activeChats[index];
                return ListTile(
                  leading: CircleAvatar(
                    radius: 25,
                    backgroundImage: chat['photoUrl'] != null
                        ? CachedNetworkImageProvider(chat['photoUrl'])
                        : null,
                    backgroundColor: Colors.grey.shade300,
                    child: chat['photoUrl'] == null
                        ? const Icon(Icons.person, color: Colors.white)
                        : null,
                  ),
                  title: Text(chat['name']),
                  subtitle: Text(chat['lastMessage'] ?? ''),
                  trailing: Text(
                    formatTime(chat['lastTimestamp']),
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                  ),
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      AppRoutes.chat,
                      arguments: {
                        'matchId': chat['matchId'],
                        'personName': chat['name'],
                        'personPhotoUrl': chat['photoUrl'],
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 2),
    );
  }
}
