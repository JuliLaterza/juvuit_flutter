import 'package:flutter/material.dart';
import 'package:juvuit_flutter/features/profile/domain/models/user_profile.dart';
import 'package:juvuit_flutter/features/matching/widgets/profile_card.dart';

class LikePreviewScreen extends StatelessWidget {
  final UserProfile profile;
  final Future<void> Function()? onLike;
  final Future<void> Function()? onDislike;

  const LikePreviewScreen({
    super.key,
    required this.profile,
    this.onLike,
    this.onDislike,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Perfil")),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ProfileCard(
                profile: profile,
                index: 0,
                currentImageIndex: 0,
                onLike: () async {
                  if (onLike != null) await onLike!();
                  if (context.mounted) Navigator.pop(context);
                },
                onDislike: () async {
                  if (onDislike != null) await onDislike!();
                  if (context.mounted) Navigator.pop(context);
                },
                onCarouselChange: (_) {},
                showActions: true,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
