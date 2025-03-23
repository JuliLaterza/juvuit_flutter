import 'dart:ui';
import 'package:flutter/material.dart';

class MatchAnimationScreen extends StatefulWidget {
  final String userImage;
  final String matchImage;

  const MatchAnimationScreen({
    super.key,
    required this.userImage,
    required this.matchImage,
  });

  @override
  State<MatchAnimationScreen> createState() => _MatchAnimationScreenState();
}

class _MatchAnimationScreenState extends State<MatchAnimationScreen>
    with TickerProviderStateMixin {
  late AnimationController _moveController;
  late AnimationController _pulseController;
  bool showText = false;

  @override
  void initState() {
    super.initState();

    _moveController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 500),
      lowerBound: 1.0,
      upperBound: 1.3,
      vsync: this,
    );

    _moveController.forward().whenComplete(() {
      _pulseController.forward().then((_) {
        _pulseController.reverse();
        setState(() {
          showText = true;
        });
      });
    });
  }

  @override
  void dispose() {
    _moveController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          AnimatedBuilder(
            animation: _moveController,
            builder: (context, child) {
              double left = lerpDouble(0, screenWidth / 2 - 80, _moveController.value)!;
              return Positioned(
                top: 200,
                left: left,
                child: ScaleTransition(
                  scale: _pulseController,
                  child: _buildAvatar(widget.userImage),
                ),
              );
            },
          ),

          AnimatedBuilder(
            animation: _moveController,
            builder: (context, child) {
              double right = lerpDouble(0, screenWidth / 2 - 80, _moveController.value)!;
              return Positioned(
                top: 200,
                right: right,
                child: ScaleTransition(
                  scale: _pulseController,
                  child: _buildAvatar(widget.matchImage),
                ),
              );
            },
          ),

          if (showText)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 250),
                  const Text(
                    '¡Conexión creada!',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context); // Acción posterior al match
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text('Chatear ahora'),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAvatar(String imagePath) {
    return CircleAvatar(
      radius: 80,
      backgroundImage: AssetImage(imagePath),
    );
  }
}
