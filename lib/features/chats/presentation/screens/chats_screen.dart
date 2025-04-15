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

    final List<Map<String, dynamic>> tempNewMatches = [];
    final List<Map<String, dynamic>> tempActiveChats = [];
    final List<String> userIds = [];

    for (final doc in matchesSnapshot.docs) {
      final match = doc.data();
      final users = List<String>.from(match['users']);
      final otherUserId = users.firstWhere((uid) => uid != currentUserId);
      userIds.add(otherUserId);
    }

    if (userIds.isEmpty) return;

    final usersSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where(FieldPath.documentId, whereIn: userIds)
        .get();

    final userDataMap = {for (var doc in usersSnapshot.docs) doc.id: doc.data()};

    for (final doc in matchesSnapshot.docs) {
      final match = doc.data();
      final users = List<String>.from(match['users']);
      final otherUserId = users.firstWhere((uid) => uid != currentUserId);
      final userData = userDataMap[otherUserId];
      if (userData == null) continue;

      final matchData = {
        'userId': otherUserId,
        'name': userData['name'] ?? 'Usuario',
        'photoUrl': (userData['photoUrls'] as List).isNotEmpty ? userData['photoUrls'][0] : null,
        'matchId': doc.id,
        'lastMessage': match['lastMessage'],
        'lastTimestamp': match['lastTimestamp'] != null ? (match['lastTimestamp'] as Timestamp).toDate() : null,
        'senderId': match['senderId'],
      };

      if (match['lastMessage'] == null || match['lastMessage'].toString().trim().isEmpty) {
        tempNewMatches.add(matchData);
      } else {
        tempActiveChats.add(matchData);
      }
    }
    //Ordenamos la lista de matches nuevos por cuestión de tiempo.
    tempNewMatches.sort((a, b) {
      final aTime = a['lastTimestamp'] as DateTime?;
      final bTime = b['lastTimestamp'] as DateTime?;
      if (aTime == null && bTime == null) return 0;
      if (aTime == null) return 1;
      if (bTime == null) return -1;
      return aTime.compareTo(bTime);
    });

    //Ordenamos los chats activos en función del tiempo.
    tempActiveChats.sort((a, b) {
      final aTime = a['lastTimestamp'] as DateTime?;
      final bTime = b['lastTimestamp'] as DateTime?;
      if (aTime == null && bTime == null) return 0;
      if (aTime == null) return 1;
      if (bTime == null) return -1;
      return bTime.compareTo(aTime);
    });

    setState(() { //obtenemos los matches ordenados, ya sea los nuevos o los chats.
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
                          ).then((_) => fetchMatches());
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
                  subtitle: Text(
                    chat['lastMessage'] ?? '',
                    style: TextStyle(
                      //fontWeight: chat['senderId'] != currentUserId ? FontWeight.bold : FontWeight.normal,
                      fontWeight: FontWeight.normal,

                    ),
                  ),
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
                    ).then((_) => fetchMatches());
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
