import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:juvuit_flutter/features/profile/domain/models/user_profile.dart';
import 'package:intl/intl.dart';
//import 'dart:async';

class ChatScreen extends StatefulWidget {
  final String matchId;
  final String personName;
  final String personPhotoUrl;

  const ChatScreen({
    super.key,
    required this.matchId,
    required this.personName,
    required this.personPhotoUrl,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final String? currentUserId = FirebaseAuth.instance.currentUser?.uid;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // Función para hacer scroll hacia abajo
  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  // Función para verificar permisos del match
  Future<void> _verifyMatchPermissions() async {
    try {
      final matchDoc = await FirebaseFirestore.instance
          .collection('matches')
          .doc(widget.matchId)
          .get();
      
      if (matchDoc.exists) {
        final matchData = matchDoc.data()!;
        final users = List<String>.from(matchData['users'] ?? []);
        
        if (!users.contains(currentUserId)) {
          throw Exception('Usuario no es participante del match');
        }
      } else {
        throw Exception('Match no existe');
      }
    } catch (e) {
      rethrow;
    }
  }

  void _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty || currentUserId == null) return;

    // Limpiar el input inmediatamente
    _controller.clear();

    final now = DateTime.now();
    final messageData = {
      'text': text,
      'senderId': currentUserId,
      'timestamp': FieldValue.serverTimestamp(),
      'localTimestamp': now.millisecondsSinceEpoch,
      'seenBy': [currentUserId],
    };

    try {
      await _verifyMatchPermissions();
      
      await FirebaseFirestore.instance
          .collection('messages')
          .doc(widget.matchId)
          .collection('chats')
          .add(messageData);

      // Actualizar match con información del último mensaje
      await FirebaseFirestore.instance
          .collection('matches')
          .doc(widget.matchId)
          .update({
        'senderId': currentUserId,
        'lastMessage': text,
        'lastTimestamp': FieldValue.serverTimestamp(),
      });

      // Hacer scroll hacia abajo después de que el mensaje se haya agregado
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) {
          _scrollToBottom();
        }
      });

    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  void _goToProfile() async {
    final user = await FirebaseFirestore.instance
        .collection('users')
        .where('name', isEqualTo: widget.personName)
        .limit(1)
        .get();

    if (user.docs.isNotEmpty) {
      final data = user.docs.first.data();
      final userId = user.docs.first.id;
      final profile = UserProfile.fromMap(userId, data);
      if (context.mounted) {
        Navigator.pushNamed(context, '/public_profile', arguments: {'profile': profile});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: GestureDetector(
          onTap: _goToProfile,
          child: Row(
            children: [
              CircleAvatar(backgroundImage: NetworkImage(widget.personPhotoUrl)),
              const SizedBox(width: 10),
              Text(widget.personName),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.info_outline),
                onPressed: _goToProfile,
              ),
            ],
          ),
        ),
      ),
      body: GestureDetector(
        onTap: () {
          // Ocultar teclado al hacer clic en cualquier parte
          FocusScope.of(context).unfocus();
        },
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('messages')
                    .doc(widget.matchId)
                    .collection('chats')
                    .orderBy('timestamp')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                  }
                  
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final messages = snapshot.data!.docs;
                  return ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final msg = messages[index];
                      final isMe = msg['senderId'] == currentUserId;
                      
                      // Usar timestamp local si está disponible, sino el del servidor
                      DateTime messageTime;
                      final data = msg.data() as Map<String, dynamic>;
                      
                      if (data.containsKey('localTimestamp') && data['localTimestamp'] != null) {
                        messageTime = DateTime.fromMillisecondsSinceEpoch(data['localTimestamp']);
                      } else if (data.containsKey('timestamp') && data['timestamp'] != null) {
                        messageTime = (data['timestamp'] as Timestamp).toDate();
                      } else {
                        messageTime = DateTime.now();
                      }
                      
                      final timeString = DateFormat('HH:mm').format(messageTime);
                      
                      return Align(
                        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
                          decoration: BoxDecoration(
                            color: isMe ? Colors.amber : Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                msg['text'] ?? '',
                                style: const TextStyle(fontSize: 14),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                timeString,
                                style: TextStyle(
                                  fontSize: 10,
                                  color: isMe ? Colors.black54 : Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 4.0, 16.0, 40.0),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      //decoration: BoxDecoration(
                        //color: Colors.grey[50],
                        //borderRadius: BorderRadius.circular(25),
                        //border: Border.all(color: Colors.grey[500]!),
                      //),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _controller,
                              maxLines: null,
                              textCapitalization: TextCapitalization.none,
                              decoration: const InputDecoration(
                                hintText: 'Escribí tu mensaje...',
                                hintStyle: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 16,
                                ),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: _sendMessage,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFD600),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Icon(
                                Icons.send_rounded,
                                color: Colors.black87,
                                size: 20,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
