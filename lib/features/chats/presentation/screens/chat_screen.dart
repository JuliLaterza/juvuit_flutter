import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:juvuit_flutter/features/profile/domain/models/user_profile.dart';
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
  final String? currentUserId = FirebaseAuth.instance.currentUser?.uid;

  void _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty || currentUserId == null) return;

    //await Future.delayed(const Duration(milliseconds: 500));

    final messageData = {
      'text': text,
      'senderId': currentUserId,
      'timestamp': FieldValue.serverTimestamp(),
      'seenBy': [currentUserId],
    };

    try {
      await FirebaseFirestore.instance
          .collection('messages')
          .doc(widget.matchId)
          .collection('chats')
          .add(messageData);

      await FirebaseFirestore.instance
          .collection('matches')
          .doc(widget.matchId)
          .update({
        'senderId': currentUserId,
        'lastMessage': text,
        'lastTimestamp': FieldValue.serverTimestamp(),
      });

      _controller.clear();
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
      body: Column(
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
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final messages = snapshot.data!.docs;
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index];
                    final isMe = msg['senderId'] == currentUserId;
                    return Align(
                      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
                        decoration: BoxDecoration(
                          color: isMe ? Colors.amber : Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(msg['text'] ?? ''),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12.0, 10.0, 12.0, 24.0),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: TextField(
                      controller: _controller,
                      decoration: const InputDecoration(
                        hintText: 'Escribí tu mensaje...',
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: _sendMessage,
                  child: CircleAvatar(
                    radius: 24,
                    backgroundColor: Color(0xFFFFD600),
                    child: const Icon(Icons.send, color: Colors.black),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
