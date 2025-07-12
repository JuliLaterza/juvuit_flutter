// lib/features/likes_received/presentation/widgets/swipe_card.dart

import 'package:flutter/material.dart';
import 'package:juvuit_flutter/core/utils/colors.dart';

class SwipeCard extends StatelessWidget {
  final String photoUrl, name, age, eventTitle;
  final VoidCallback onReject, onInfo, onAccept;

  const SwipeCard({
    super.key,
    required this.photoUrl,
    required this.name,
    required this.age,
    required this.eventTitle,
    required this.onReject,
    required this.onInfo,
    required this.onAccept,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.hardEdge,
      child: Stack(children: [
        Positioned.fill(
          child: photoUrl.isNotEmpty
              ? Image.network(photoUrl, fit: BoxFit.cover)
              : Container(color: Colors.grey[300]),
        ),
        Positioned(
          bottom: 0, left: 0, right: 0, height: 80,
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end:   Alignment.topCenter,
                stops: [0.0, 0.3],
                colors: [Colors.black54, Colors.transparent],
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 0, left: 0, right: 0,
          child: Container(
            padding: const EdgeInsets.symmetric(
                vertical: 8, horizontal: 12),
            decoration: const BoxDecoration(
              color: Colors.black45,
              borderRadius: BorderRadius.only(
                bottomLeft:  Radius.circular(12),
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
                    color: Colors.white, fontSize:16,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines:1, overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height:4),
                Text(
                  eventTitle,
                  style: const TextStyle(
                    color: Colors.white70, fontSize:12),
                  maxLines:1, overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height:8),
                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceAround,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.clear),
                      color: Colors.white,
                      onPressed: onReject,
                    ),
                    IconButton(
                      icon: const Icon(Icons.info_outline),
                      color: Colors.white,
                      onPressed: onInfo,
                    ),
                    IconButton(
                      icon: const Icon(Icons.favorite),
                      color: AppColors.yellow,
                      onPressed: onAccept,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ]),
    );
  }
}
