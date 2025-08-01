import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:juvuit_flutter/core/utils/routes.dart';

class MatchAnimationScreen extends StatefulWidget {
  final String userImage;
  final String matchImage;
  final String matchedUserId; // ID del usuario con quien se hizo match
  final String matchedUserName; // Nombre del usuario con quien se hizo match
  final String matchedUserPhotoUrl; // URL de la foto del usuario con quien se hizo match

  const MatchAnimationScreen({
    super.key,
    required this.userImage,
    required this.matchImage,
    required this.matchedUserId,
    required this.matchedUserName,
    required this.matchedUserPhotoUrl,
  });

  @override
  State<MatchAnimationScreen> createState() => _MatchAnimationScreenState();
}

class _MatchAnimationScreenState extends State<MatchAnimationScreen>
    with TickerProviderStateMixin {
  late AnimationController _moveController;
  late AnimationController _burstController;
  late AnimationController _textController;
  bool showText = false;
  String? matchId;

  static const Color appYellow = Color(0xFFFFD600);

  @override
  void initState() {
    super.initState();

    _moveController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _burstController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _textController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _moveController.forward().whenComplete(() async {
      await _burstController.forward();
      setState(() {
        showText = true;
      });
      _textController.forward();
    });

    // Obtener el matchId
    _getMatchId();
  }

  Future<void> _getMatchId() async {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    if (currentUserId == null) return;

    // Crear el matchId de la misma manera que en match_helper.dart
    final userIds = [currentUserId, widget.matchedUserId]..sort();
    final generatedMatchId = userIds.join('_');

    // Verificar si el match existe en Firestore
    final matchDoc = await FirebaseFirestore.instance
        .collection('matches')
        .doc(generatedMatchId)
        .get();

    if (matchDoc.exists) {
      setState(() {
        matchId = generatedMatchId;
      });
    }
  }

  void _navigateToChat() async {
    if (matchId == null) {
      // Si no hay matchId, mostrar un mensaje de error
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error: No se pudo encontrar el chat'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    // Navegar al chat
    Navigator.pushNamed(
      context,
      AppRoutes.chat,
      arguments: {
        'matchId': matchId,
        'personName': widget.matchedUserName,
        'personPhotoUrl': widget.matchedUserPhotoUrl,
      },
    );
  }

  @override
  void dispose() {
    _moveController.dispose();
    _burstController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 600),
        color: appYellow,
        width: screenWidth,
        height: screenHeight,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Botón X en la esquina superior derecha
            Positioned(
              top: MediaQuery.of(context).padding.top + 10,
              right: 20,
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.3),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
            ),

            // Onda expansiva
            AnimatedBuilder(
              animation: _burstController,
              builder: (context, child) {
                double scale = Tween(begin: 0.0, end: 3.0).evaluate(_burstController);
                double opacity = 1.0 - _burstController.value;
                return Container(
                  width: 100 * scale,
                  height: 100 * scale,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(opacity * 0.3),
                  ),
                );
              },
            ),

            // Avatar izquierdo
            AnimatedBuilder(
              animation: _moveController,
              builder: (context, child) {
                double left = lerpDouble(0, screenWidth / 2 - 160, Curves.easeOutBack.transform(_moveController.value))!;
                return Positioned(
                  top: screenHeight * 0.3,
                  left: left,
                  child: Transform.rotate(
                    angle: -0.2 + (_moveController.value * 0.2),
                    child: _buildGlowingAvatar(widget.userImage),
                  ),
                );
              },
            ),

            // Avatar derecho
            AnimatedBuilder(
              animation: _moveController,
              builder: (context, child) {
                double right = lerpDouble(0, screenWidth / 2 - 160, Curves.easeOutBack.transform(_moveController.value))!;
                return Positioned(
                  top: screenHeight * 0.3,
                  right: right,
                  child: Transform.rotate(
                    angle: 0.2 - (_moveController.value * 0.2),
                    child: _buildGlowingAvatar(widget.matchImage),
                  ),
                );
              },
            ),

            // Texto
            if (showText)
              Positioned(
                bottom: screenHeight * 0.25,
                left: 0,
                right: 0,
                child: FadeTransition(
                  opacity: _textController,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 0.5),
                      end: Offset.zero,
                    ).animate(CurvedAnimation(
                      parent: _textController,
                      curve: Curves.easeOut,
                    )),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          '¡Conexión creada!',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: _navigateToChat,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: const Text('Chatear ahora'),
                        )
                      ],
                    ),
                  ),
                ),
              )
          ],
        ),
      ),
    );
  }

  Widget _buildGlowingAvatar(String imagePath) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.white.withOpacity(0.6),
            blurRadius: 12,
            spreadRadius: 4,
          ),
        ],
      ),
      child: CircleAvatar(
        radius: 80,
        backgroundImage: imagePath.startsWith('http') 
            ? NetworkImage(imagePath) 
            : AssetImage(imagePath) as ImageProvider,
      ),
    );
  }
}
