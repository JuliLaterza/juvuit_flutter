// Archivo: features/matching/controllers/matching_profiles_controller.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:juvuit_flutter/features/events/domain/models/event.dart';
import 'package:juvuit_flutter/features/profile/domain/models/user_profile.dart';
import '../domain/match_helper.dart';
import '../presentation/screens/match_animation_screen.dart';
import 'package:juvuit_flutter/core/utils/routes.dart';

class MatchingProfilesController {
  late final PageController pageController;
  final Set<String> likedProfiles = {};
  final Map<int, int> currentCarouselIndex = {};
  late UserProfile currentUserProfile;
  
  // Mapa para almacenar hasLikedMe para cada perfil
  final Map<String, bool> hasLikedMeMap = {};
  
  // Stream para escuchar matches
  Stream<QuerySnapshot>? _matchesStream;
  
  MatchingProfilesController({required this.pageController}) {
    _initializeMatchesStream();
  }

  void _initializeMatchesStream() {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    if (currentUserId != null) {
      _matchesStream = FirebaseFirestore.instance
          .collection('matches')
          .where('users', arrayContains: currentUserId)
          .snapshots();
    }
  }

  // Función para obtener el stream de matches
  Stream<QuerySnapshot>? get matchesStream => _matchesStream;

  // Función para verificar si un match es nuevo (no anticipado)
  bool isNewMatch(String matchId) {
    // Si el match no estaba en hasLikedMeMap, es nuevo
    final users = matchId.split('_');
    if (users.length == 2) {
      final otherUserId = users.firstWhere((uid) => uid != FirebaseAuth.instance.currentUser?.uid);
      return !(hasLikedMeMap[otherUserId] ?? false);
    }
    return false;
  }

  // Función para mostrar animación de match retroactivo
  void showRetroactiveMatchAnimation(BuildContext context, String matchId, String otherUserId, String otherUserName, String otherUserPhotoUrl) {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    if (currentUserId == null) return;

    // Obtener foto del usuario actual
    final currentUserPhoto = currentUserProfile.photoUrls.isNotEmpty 
        ? currentUserProfile.photoUrls.first 
        : 'https://via.placeholder.com/150';

    // Mostrar animación
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MatchAnimationScreen(
          userImage: currentUserPhoto,
          matchImage: otherUserPhotoUrl,
          matchedUserId: otherUserId,
          matchedUserName: otherUserName,
          matchedUserPhotoUrl: otherUserPhotoUrl,
        ),
      ),
    );
  }

  Future<UserProfile?> loadCurrentUserProfile() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return null;

    final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    if (doc.exists) {
      final data = doc.data()!;
      currentUserProfile = UserProfile.fromMap(uid, data);
      return currentUserProfile;
    }
    return null;
  }

  // Función para verificar si un usuario ya dio like al usuario actual
  Future<bool> checkIfUserLikedMe(String userId) async {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    if (currentUserId == null) return false;

    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('likesGiven')
          .doc(currentUserId)
          .get();
      
      return doc.exists;
    } catch (e) {
      print('Error checking if user liked me: $e');
      return false;
    }
  }

  Future<List<UserProfile>> loadProfiles(Event event) async {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    if (currentUserId == null) return [];

    // Obtener likes dados por el usuario en este evento
    final likesGivenSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUserId)
        .collection('likesGiven')
        .get();

    final likedUserIds = likesGivenSnapshot.docs
        .where((doc) => doc.data()['eventId'] == event.id)
        .map((doc) => doc.id)
        .toSet();

    // Obtener matches con chats ya iniciados
    final matchesSnapshot = await FirebaseFirestore.instance
        .collection('matches')
        .where('users', arrayContains: currentUserId)
        .get();

    final Set<String> matchedAndChattedUserIds = {};
    for (final doc in matchesSnapshot.docs) {
      final data = doc.data();
      final users = List<String>.from(data['users']);
      final otherUserId = users.firstWhere((uid) => uid != currentUserId);
      final lastMessage = data['lastMessage'];
      if (lastMessage != null && lastMessage.toString().trim().isNotEmpty) {
        matchedAndChattedUserIds.add(otherUserId);
      }
    }

    final List<UserProfile> loaded = [];
    for (final uid in event.attendees) {
      if (uid == currentUserId || likedUserIds.contains(uid) || matchedAndChattedUserIds.contains(uid)) continue;

      final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (doc.exists) {
        final data = doc.data()!;
        final profile = UserProfile.fromMap(doc.id, data);
        loaded.add(profile);
        
        // Preconsulta: verificar si este usuario ya dio like al usuario actual
        final hasLikedMe = await checkIfUserLikedMe(uid);
        hasLikedMeMap[uid] = hasLikedMe;
        print('DEBUG: Perfil ${profile.name} - hasLikedMe: $hasLikedMe');
      }
    }

    return loaded;
  }

  // Función para obtener hasLikedMe de un perfil específico
  bool getHasLikedMe(String userId) {
    return hasLikedMeMap[userId] ?? false;
  }

  Future<void> onLike({
    required BuildContext context,
    required List<UserProfile> profiles,
    required Event event,
  }) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    final currentPage = pageController.page!.toInt();
    if (currentUser == null || currentPage >= profiles.length) return;

    // Verificar si es evento tipo "Fiesta" y si el usuario tiene canciones/trago completados
    if (event.type.toLowerCase() == 'fiesta' || event.type.toLowerCase() == 'boliche' || event.type.toLowerCase() == 'party') {
      print('DEBUG: Evento tipo fiesta detectado: ${event.type}');
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get();
      
      if (userDoc.exists) {
        final userData = userDoc.data()!;
        final hasSongs = userData['top_3canciones'] != null && 
                        (userData['top_3canciones'] as List).isNotEmpty;
        final hasDrink = userData['drink'] != null && 
                        userData['drink'].toString().isNotEmpty;

        print('DEBUG: Usuario tiene canciones: $hasSongs, trago: $hasDrink');

        if (!hasSongs || !hasDrink) {
          print('DEBUG: Mostrando modal obligatorio');
          // Mostrar modal obligatorio
          final shouldContinue = await _showSongsDrinkModal(context);
          if (!shouldContinue) return;
        }
      }
    } else {
      print('DEBUG: Evento no es tipo fiesta: ${event.type}');
    }

    final likedUser = profiles[currentPage];
    likedProfiles.add(likedUser.userId);

    // Verificar si ya recibí like de este usuario (preconsulta)
    final hasLikedMe = getHasLikedMe(likedUser.userId);
    print('DEBUG: hasLikedMe para ${likedUser.name}: $hasLikedMe');

    // Guardar like en Firestore
    await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.uid)
        .collection('likesGiven')
        .doc(likedUser.userId)
        .set({
      'eventId': event.id,
      'timestamp': FieldValue.serverTimestamp(),
    });

    // Si ya recibí like, mostrar animación instantánea
    if (hasLikedMe) {
      print('DEBUG: ¡MATCH INSTANTÁNEO! Mostrando animación...');
      // Navegar directo al MatchAnimationScreen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MatchAnimationScreen(
            userImage: currentUserProfile.photoUrls.first,
            matchImage: likedUser.photoUrls.isNotEmpty ? likedUser.photoUrls.first : 'https://via.placeholder.com/150',
            matchedUserId: likedUser.userId,
            matchedUserName: likedUser.name,
            matchedUserPhotoUrl: likedUser.photoUrls.isNotEmpty ? likedUser.photoUrls.first : 'https://via.placeholder.com/150',
          ),
        ),
      );
    } else {
      print('DEBUG: No es match instantáneo, procesando normalmente...');
      // Procesar normalmente (Cloud Function se encargará del match si corresponde)
      await handleLikeAndMatch(
        currentUserId: currentUser.uid,
        likedUserId: likedUser.userId,
        eventId: event.id,
        context: context,
        currentUserPhoto: currentUserProfile.photoUrls.first,
        matchedUserPhoto: likedUser.photoUrls.isNotEmpty ? likedUser.photoUrls.first : 'https://via.placeholder.com/150',
        matchedUserName: likedUser.name,
      );
    }

    avanzarPagina(currentPage);
  }

  Future<bool> _showSongsDrinkModal(BuildContext context) async {
    return await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(Icons.music_note, color: Colors.yellow),
              SizedBox(width: 8),
              Text('¡Completá tu perfil!'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Para conectar en eventos de fiesta, necesitás:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.music_note, size: 16, color: Colors.grey[600]),
                  SizedBox(width: 8),
                  Text('Tus 3 canciones favoritas'),
                ],
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.local_bar, size: 16, color: Colors.grey[600]),
                  SizedBox(width: 8),
                  Text('Tu trago preferido'),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('Cancelar', style: TextStyle(color: Colors.grey[600])),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop(true);
                // Navegar a la pantalla de completar perfil
                Navigator.pushNamed(context, AppRoutes.completeSongsDrink);
              },
              child: Text('Completar perfil'),
            ),
          ],
        );
      },
    ) ?? false;
  }

  void onDislike(List<UserProfile> profiles) {
    final currentPage = pageController.page!.toInt();
    avanzarPagina(currentPage);
  }

  void avanzarPagina(int currentPage) {
    pageController.nextPage(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  int calculateAge(DateTime? birthDate) {
    if (birthDate == null) return 0;
    final today = DateTime.now();
    int age = today.year - birthDate.year;
    if (today.month < birthDate.month ||
        (today.month == birthDate.month && today.day < birthDate.day)) {
      age--;
    }
    return age;
  }
}
