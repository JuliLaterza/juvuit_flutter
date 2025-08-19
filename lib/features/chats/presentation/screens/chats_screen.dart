import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:juvuit_flutter/core/widgets/custom_bottom_nav_bar.dart';
import 'package:juvuit_flutter/core/widgets/theme_aware_logo.dart';
import 'package:juvuit_flutter/core/utils/routes.dart';
import 'package:juvuit_flutter/core/utils/colors.dart';
import 'package:intl/intl.dart';

class ChatsScreen extends StatefulWidget {
  const ChatsScreen({super.key});

  @override
  State<ChatsScreen> createState() => _ChatsScreenState();
}

class _ChatsScreenState extends State<ChatsScreen> {
  final currentUserId = FirebaseAuth.instance.currentUser?.uid;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  Stream<QuerySnapshot>? _matchesStream;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
    _initializeMatchesStream();
  }

  void _initializeMatchesStream() {
    if (currentUserId != null) {
      _matchesStream = FirebaseFirestore.instance
          .collection('matches')
          .where('users', arrayContains: currentUserId)
          .snapshots();
    }
  }

  String normalize(String text) {
    return text.toLowerCase().replaceAll(RegExp(r'[^\w\s]+'), '');
  }

  Future<Map<String, Map<String, dynamic>>> _fetchUserData(List<String> userIds) async {
    if (userIds.isEmpty) return {};
    
    final usersSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where(FieldPath.documentId, whereIn: userIds)
        .get();

    return {for (var doc in usersSnapshot.docs) doc.id: doc.data()};
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
    final theme = Theme.of(context);
    final normalizedQuery = normalize(_searchQuery);

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(52),
        child: AppBar(
          backgroundColor: theme.colorScheme.surface,
          elevation: 0,
          title: const HeaderLogo(),
          centerTitle: false,
        ),
      ),
      body: SafeArea(
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
                    borderSide: const BorderSide(color: AppColors.gray),
                  ),
                ),
              ),
            ),
            Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: StreamBuilder<QuerySnapshot>(
                stream: _matchesStream,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Text(
                      'Nuevos matches',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    );
                  }

                  return FutureBuilder<Map<String, Map<String, dynamic>>>(
                    future: _fetchUserData(
                      snapshot.data!.docs.map((doc) {
                        final match = doc.data() as Map<String, dynamic>;
                        final users = List<String>.from(match['users']);
                        return users.firstWhere((uid) => uid != currentUserId);
                      }).toList(),
                    ),
                    builder: (context, userDataSnapshot) {
                      if (!userDataSnapshot.hasData) {
                        return const Text(
                          'Nuevos matches',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        );
                      }

                      final userDataMap = userDataSnapshot.data!;
                      int newMatchesCount = 0;

                      for (final doc in snapshot.data!.docs) {
                        final match = doc.data() as Map<String, dynamic>;
                        final users = List<String>.from(match['users']);
                        final otherUserId = users.firstWhere((uid) => uid != currentUserId);
                        final userData = userDataMap[otherUserId];
                        
                        if (userData != null) {
                          if (match['lastMessage'] == null || match['lastMessage'].toString().trim().isEmpty) {
                            if (normalize(userData['name'] ?? '').contains(normalizedQuery)) {
                              newMatchesCount++;
                            }
                          }
                        }
                      }

                      return RichText(
                        text: TextSpan(
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: theme.colorScheme.onBackground),
                          children: [
                            TextSpan(text: 'Nuevos matches '),
                            TextSpan(
                              text: '(${newMatchesCount})',
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.normal, color: theme.colorScheme.onBackground),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            SizedBox(
              height: 110,
              child: StreamBuilder<QuerySnapshot>(
                stream: _matchesStream,
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.error_outline, size: 32, color: Colors.red),
                          SizedBox(height: 8),
                          Text('Error al cargar matches'),
                        ],
                      ),
                    );
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text('Aún no tenés matches'));
                  }

                  return FutureBuilder<Map<String, Map<String, dynamic>>>(
                    future: _fetchUserData(
                      snapshot.data!.docs.map((doc) {
                        final match = doc.data() as Map<String, dynamic>;
                        final users = List<String>.from(match['users']);
                        return users.firstWhere((uid) => uid != currentUserId);
                      }).toList(),
                    ),
                    builder: (context, userDataSnapshot) {
                      if (userDataSnapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (!userDataSnapshot.hasData) {
                        return const Center(child: Text('Error al cargar usuarios'));
                      }

                      final userDataMap = userDataSnapshot.data!;
                      final List<Map<String, dynamic>> newMatches = [];
                      final List<Map<String, dynamic>> activeChats = [];

                      for (final doc in snapshot.data!.docs) {
                        final match = doc.data() as Map<String, dynamic>;
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
                          newMatches.add(matchData);
                        } else {
                          activeChats.add(matchData);
                        }
                      }

                      newMatches.sort((a, b) => _compareTimes(a['lastTimestamp'], b['lastTimestamp']));
                      activeChats.sort((a, b) => _compareTimes(b['lastTimestamp'], a['lastTimestamp']));

                      final filteredNewMatches = newMatches
                          .where((match) => normalize(match['name']).contains(normalizedQuery))
                          .toList();

                      return filteredNewMatches.isEmpty
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
                                    );
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
                            );
                    },
                  );
                },
              ),
            ),
            const Divider(),
            Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: StreamBuilder<QuerySnapshot>(
                stream: _matchesStream,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Text(
                      'Chats',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    );
                  }

                  return FutureBuilder<Map<String, Map<String, dynamic>>>(
                    future: _fetchUserData(
                      snapshot.data!.docs.map((doc) {
                        final match = doc.data() as Map<String, dynamic>;
                        final users = List<String>.from(match['users']);
                        return users.firstWhere((uid) => uid != currentUserId);
                      }).toList(),
                    ),
                    builder: (context, userDataSnapshot) {
                      if (!userDataSnapshot.hasData) {
                        return const Text(
                          'Chats',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        );
                      }

                      final userDataMap = userDataSnapshot.data!;
                      int activeChatsCount = 0;

                      for (final doc in snapshot.data!.docs) {
                        final match = doc.data() as Map<String, dynamic>;
                        final users = List<String>.from(match['users']);
                        final otherUserId = users.firstWhere((uid) => uid != currentUserId);
                        final userData = userDataMap[otherUserId];
                        
                        if (userData != null) {
                          if (match['lastMessage'] != null && match['lastMessage'].toString().trim().isNotEmpty) {
                            if (normalize(userData['name'] ?? '').contains(normalizedQuery)) {
                              activeChatsCount++;
                            }
                          }
                        }
                      }

                      return RichText(
                        text: TextSpan(
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: theme.colorScheme.onBackground),
                          children: [
                            TextSpan(text: 'Chats '),
                            TextSpan(
                              text: '(${activeChatsCount})',
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.normal, color: theme.colorScheme.onBackground),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _matchesStream,
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.error_outline, size: 32, color: Colors.red),
                          SizedBox(height: 8),
                          Text('Error al cargar chats'),
                        ],
                      ),
                    );
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text('Aún no tenés chats activos'));
                  }

                  return FutureBuilder<Map<String, Map<String, dynamic>>>(
                    future: _fetchUserData(
                      snapshot.data!.docs.map((doc) {
                        final match = doc.data() as Map<String, dynamic>;
                        final users = List<String>.from(match['users']);
                        return users.firstWhere((uid) => uid != currentUserId);
                      }).toList(),
                    ),
                    builder: (context, userDataSnapshot) {
                      if (userDataSnapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (!userDataSnapshot.hasData) {
                        return const Center(child: Text('Error al cargar usuarios'));
                      }

                      final userDataMap = userDataSnapshot.data!;
                      final List<Map<String, dynamic>> newMatches = [];
                      final List<Map<String, dynamic>> activeChats = [];

                      for (final doc in snapshot.data!.docs) {
                        final match = doc.data() as Map<String, dynamic>;
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
                          newMatches.add(matchData);
                        } else {
                          activeChats.add(matchData);
                        }
                      }

                      newMatches.sort((a, b) => _compareTimes(a['lastTimestamp'], b['lastTimestamp']));
                      activeChats.sort((a, b) => _compareTimes(b['lastTimestamp'], a['lastTimestamp']));

                      final filteredActiveChats = activeChats
                          .where((chat) => normalize(chat['name']).contains(normalizedQuery))
                          .toList();

                      return filteredActiveChats.isEmpty
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
                                    );
                                  },
                                );
                              },
                            );
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
