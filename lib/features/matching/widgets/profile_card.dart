import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:juvuit_flutter/core/utils/colors.dart';
import 'package:juvuit_flutter/features/profile/domain/models/user_profile.dart';

class ProfileCard extends StatefulWidget {
  final UserProfile profile;
  final int index;
  final int currentImageIndex;
  final VoidCallback onLike;
  final VoidCallback onDislike;
  final Function(int) onCarouselChange;

  const ProfileCard({
    super.key,
    required this.profile,
    required this.index,
    required this.currentImageIndex,
    required this.onLike,
    required this.onDislike,
    required this.onCarouselChange,
  });

  @override
  State<ProfileCard> createState() => _ProfileCardState();
}

class _ProfileCardState extends State<ProfileCard> {
  final ScrollController _scrollController = ScrollController();
  bool hasReachedEnd = false;
  bool dislikeTriggered = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      final isAtBottom = _scrollController.offset >= _scrollController.position.maxScrollExtent;
      if (isAtBottom && !hasReachedEnd) {
        hasReachedEnd = true;
        dislikeTriggered = false;
      }
      if (!isAtBottom) {
        hasReachedEnd = false;
        dislikeTriggered = false;
      }
    });
  }

  int _calculateAge(DateTime? birthDate) {
    if (birthDate == null) return 0;
    final today = DateTime.now();
    int age = today.year - birthDate.year;
    if (today.month < birthDate.month ||
        (today.month == birthDate.month && today.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  @override
  Widget build(BuildContext context) {
    final photoCount = widget.profile.photoUrls.length;

    return SafeArea(
      child: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          if (notification is ScrollUpdateNotification) {
            final isAtEnd = notification.metrics.pixels >= notification.metrics.maxScrollExtent;
            final isScrollingDown = notification.scrollDelta != null && notification.scrollDelta! > 10;

            if (isAtEnd && hasReachedEnd && !dislikeTriggered && isScrollingDown) {
              dislikeTriggered = true;
              widget.onDislike();
            }

            if (isAtEnd && !hasReachedEnd) {
              hasReachedEnd = true;
            }

            if (!isAtEnd) {
              hasReachedEnd = false;
              dislikeTriggered = false;
            }
          }
          return false;
        },
        child: SingleChildScrollView(
          controller: _scrollController,
          physics: Theme.of(context).platform == TargetPlatform.iOS
              ? const BouncingScrollPhysics()
              : const ClampingScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 50),
          child: Column(
            children: [
              CarouselSlider(
                options: CarouselOptions(
                  height: 380,
                  viewportFraction: 1.0,
                  enlargeCenterPage: false,
                  enableInfiniteScroll: false,
                  onPageChanged: (imgIndex, _) => widget.onCarouselChange(imgIndex),
                ),
                items: widget.profile.photoUrls.map((url) {
                  return Image.network(url, fit: BoxFit.cover, width: double.infinity);
                }).toList(),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(photoCount, (i) => Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: widget.currentImageIndex == i ? Colors.black : Colors.grey,
                  ),
                )),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.close, size: 36, color: Colors.redAccent),
                    onPressed: widget.onDislike,
                  ),
                  const SizedBox(width: 40),
                  IconButton(
                    icon: const Icon(Icons.favorite_border, size: 36, color: AppColors.black),
                    onPressed: widget.onLike,
                  ),
                ],
              ),
              const SizedBox(height: 30),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${widget.profile.name}, ${_calculateAge(widget.profile.birthDate)}',
                        style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    Text(widget.profile.description,
                        style: const TextStyle(fontSize: 16, color: Colors.black87)),
                    const SizedBox(height: 16),
                    Row(children: [
                      const Text('🥂 ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      Text(widget.profile.favoriteDrink,
                          style: const TextStyle(fontSize: 16, fontStyle: FontStyle.normal))
                    ]),
                    const SizedBox(height: 8),
                    Row(children: [
                      const Text('♈ ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      Text(widget.profile.sign ?? '-', style: const TextStyle(fontSize: 16))
                    ]),
                    const SizedBox(height: 16),
                    const Text('Canciones favoritas',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    for (final song in widget.profile.topSongs)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(song['imageUrl'], width: 46, height: 46, fit: BoxFit.cover),
                          ),
                          const SizedBox(width: 12),
                          Expanded(child: Text('${song['title']} - ${song['artist']}')),
                        ]),
                      ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}