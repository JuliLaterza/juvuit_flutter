import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:juvuit_flutter/core/widgets/custom_bottom_nav_bar.dart';
import 'package:juvuit_flutter/core/utils/routes.dart';
import 'package:juvuit_flutter/core/utils/colors.dart';
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
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
    fetchMatches();
  }

  String normalize(String text) {
    return text.toLowerCase().replaceAll(RegExp(r'[^\w\s]+'), '');
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

    if (userIds.isEmpty) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
      return;
    }

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

    tempNewMatches.sort((a, b) => _compareTimes(a['lastTimestamp'], b['lastTimestamp']));
    tempActiveChats.sort((a, b) => _compareTimes(b['lastTimestamp'], a['lastTimestamp']));

    if (!mounted) return;
    setState(() {
      newMatches = tempNewMatches;
      activeChats = tempActiveChats;
      isLoading = false;
    });
  }

  int _compareTimes(DateTime? a, DateTime? b) {
    if (a == null && b == null) return 0;
    if (a == null) return 1;
    if (b == null) return -1;
    return a.compareTo(b);
  }

  String formatTime(DateTime? dateTime) {
    if (dateTime == null) return '';
    return DateFormat('HH:mm').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    final normalizedQuery = normalize(_searchQuery);

    final filteredNewMatches = newMatches
        .where((match) => normalize(match['name']).contains(normalizedQuery))
        .toList();

    final filteredActiveChats = activeChats
        .where((chat) => normalize(chat['name']).contains(normalizedQuery))
        .toList();

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(52),
        child: AppBar(
          backgroundColor: AppColors.white,
          elevation: 0,
          title: Image.asset(
            'assets/images/homescreen/logo_witu.png',
            height: 32,
          ),
          centerTitle: false,
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              top: false,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Buscar persona',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  _searchController.clear();
                                  FocusScope.of(context).unfocus();
                                },
                              )
                            : null,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppColors.lightGray),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppColors.yellow),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: const Text(
                      'Nuevos matches',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(
                    height: 110,
                    child: filteredNewMatches.isEmpty
                        ? const Center(child: Text('Aún no tenés nuevos matches'))
                        : ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: filteredNewMatches.length,
                            itemBuilder: (context, index) {
                              final match = filteredNewMatches[index];
                              return GestureDetector(
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
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 10),
                                  child: Column(
                                    children: [
                                      CircleAvatar(
                                        radius: 35,
                                        backgroundColor: Colors.grey.shade300,
                                        backgroundImage: match['photoUrl'] != null
                                            ? CachedNetworkImageProvider(match['photoUrl'])
                                            : null,
                                        child: match['photoUrl'] == null
                                            ? const Icon(Icons.person, color: Colors.white, size: 35)
                                            : null,
                                      ),
                                      const SizedBox(height: 4),
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
                                ),
                              );
                            },
                          ),
                  ),
                  const Divider(),
                  Container(
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: const Text(
                      'Chats',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Expanded(
                    child: filteredActiveChats.isEmpty
                        ? const Center(child: Text('Aún no tenés chats activos'))
                        : ListView.builder(
                            itemCount: filteredActiveChats.length,
                            itemBuilder: (context, index) {
                              final chat = filteredActiveChats[index];
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
                                title: Text(
                                  chat['name'],
                                  style: const TextStyle(fontWeight: FontWeight.w600),
                                ),
                                subtitle: Text(
                                  chat['lastMessage'] ?? '',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                trailing: chat['lastTimestamp'] != null
                                    ? Text(
                                        formatTime(chat['lastTimestamp']),
                                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                                      )
                                    : null,
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
            ),
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 3),
    );
  }
}
