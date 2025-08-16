// Archivo: features/matching/controllers/matching_profiles_controller.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:juvuit_flutter/features/profile/domain/models/user_profile.dart';
import 'package:juvuit_flutter/features/events/domain/models/event.dart';
import 'package:juvuit_flutter/features/matching/domain/match_helper.dart';
import 'package:juvuit_flutter/features/matching/presentation/screens/match_animation_screen.dart';
import 'dart:collection';
import 'dart:math';

class MatchingProfilesController {
  final PageController pageController;
  final Map<String, UserProfile> profileCache = {};
  final Queue<String> recentlyViewed = Queue();
  final int maxCacheSize = 50;
  final int batchSize = 15;
  
  List<UserProfile> profiles = [];
  bool isLoading = false;
  bool hasMoreProfiles = true;
  int currentIndex = 0;
  int totalProcessedProfiles = 0; // ✅ NUEVA VARIABLE para trackear perfiles procesados
  UserProfile? currentUserProfile;
  Set<String> likedProfiles = {};
  Map<int, int> currentCarouselIndex = {};
  
  // Sistema para trackear matches ya mostrados
  final Set<String> shownMatches = {};
  final Set<String> pendingMatches = {};
  bool isInitialized = false;

  MatchingProfilesController({required this.pageController});

  // Función utilitaria para generar matchId de forma consistente
  static String generateMatchId(String userId1, String userId2) {
    final sortedIds = [userId1, userId2]..sort();
    return sortedIds.join('_');
  }

  // Inicializar el sistema de tracking de matches
  Future<void> initializeMatchesTracking() async {
    if (isInitialized) return;
    
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    if (currentUserId == null) return;

    try {
      // Obtener todos los matches existentes
      final matchesSnapshot = await FirebaseFirestore.instance
          .collection('matches')
          .where('users', arrayContains: currentUserId)
          .get();

      // Marcar todos los matches existentes como ya mostrados
      for (final doc in matchesSnapshot.docs) {
        shownMatches.add(doc.id);
      }
      
      isInitialized = true;
      print('DEBUG: Sistema de tracking de matches inicializado. Matches existentes: ${shownMatches.length}');
    } catch (e) {
      print('Error inicializando tracking de matches: $e');
    }
  }

  // Resetear contadores para nueva sesión de matcheo
  void resetForNewSession() {
    totalProcessedProfiles = 0;
    currentIndex = 0;
    profiles.clear();
    hasMoreProfiles = true;
    isLoading = false;
    print('DEBUG: Contadores reseteados para nueva sesión de matcheo');
  }

  // Tinder-style lazy loading
  Future<void> loadNextBatch(Event event) async {
    if (isLoading || !hasMoreProfiles) {
      print('DEBUG: loadNextBatch - isLoading: $isLoading, hasMoreProfiles: $hasMoreProfiles');
      return;
    }
    
    isLoading = true;
    print('DEBUG: Cargando siguiente lote de perfiles...');
    print('DEBUG: Perfiles actuales: ${profiles.length}, totalProcessedProfiles: $totalProcessedProfiles, batchSize: $batchSize');
    
    try {
      final newProfiles = await fetchProfilesBatch(event, totalProcessedProfiles, batchSize);
      
      print('DEBUG: Nuevos perfiles obtenidos: ${newProfiles.length}');
      
      if (newProfiles.length < batchSize) {
        hasMoreProfiles = false;
        print('DEBUG: No hay más perfiles disponibles (${newProfiles.length} < $batchSize)');
      } else {
        print('DEBUG: Aún hay más perfiles disponibles (${newProfiles.length} >= $batchSize)');
      }
      
      profiles.addAll(newProfiles);
      print('DEBUG: Cargados ${newProfiles.length} nuevos perfiles. Total: ${profiles.length}');
      
      // Pre-cargar imágenes de los próximos perfiles
      await preloadNextImages();
      
    } catch (e) {
      print('Error cargando perfiles: $e');
    } finally {
      isLoading = false;
    }
  }

  // Cache management
  void addToCache(UserProfile profile) {
    if (profileCache.length >= maxCacheSize) {
      final oldest = recentlyViewed.removeFirst();
      profileCache.remove(oldest);
    }
    
    profileCache[profile.userId] = profile;
    recentlyViewed.add(profile.userId);
  }

  UserProfile? getFromCache(String userId) {
    return profileCache[userId];
  }

  // Pre-carga de imágenes
  Future<void> preloadNextImages() async {
    final nextProfiles = profiles.skip(currentIndex).take(3);
    for (final profile in nextProfiles) {
      for (final imageUrl in profile.photoUrls.take(2)) { // Solo primeras 2 imágenes
        try {
          // Pre-cargar imagen sin contexto (para evitar errores)
          final image = NetworkImage(imageUrl);
          await image.resolve(ImageConfiguration.empty);
        } catch (e) {
          print('Error pre-cargando imagen: $e');
        }
      }
    }
  }

  // Obtener perfiles visibles (optimización de memoria)
  List<UserProfile> get visibleProfiles {
    final start = max(0, currentIndex - 1);
    final end = min(profiles.length, currentIndex + 2);
    return profiles.sublist(start, end);
  }

  // Cargar más perfiles si quedan pocos
  Future<void> loadMoreIfNeeded() async {
    print('DEBUG: loadMoreIfNeeded - profiles.length: ${profiles.length}, currentIndex: $currentIndex, totalProcessedProfiles: $totalProcessedProfiles, hasMoreProfiles: $hasMoreProfiles, isLoading: $isLoading');
    if (profiles.length - currentIndex < 5 && hasMoreProfiles && !isLoading) {
      print('DEBUG: Cargando más perfiles automáticamente...');
      await loadNextBatch(currentEvent!);
    } else {
      print('DEBUG: No se cargan más perfiles automáticamente');
    }
  }

  Event? currentEvent;

  Future<List<UserProfile>> fetchProfilesBatch(Event event, int offset, int limit) async {
    currentEvent = event;
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    if (currentUserId == null) return [];

    try {
      print('DEBUG: === INICIO fetchProfilesBatch ===');
      print('DEBUG: Event ID: ${event.id}');
      print('DEBUG: Current User ID: $currentUserId');
      print('DEBUG: Offset: $offset, Limit: $limit');
      print('DEBUG: Total de perfiles procesados hasta ahora: $totalProcessedProfiles');

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

      print('DEBUG: Usuarios a los que ya di like: ${likedUserIds.toList()}');

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

      print('DEBUG: Usuarios con matches y chats: ${matchedAndChattedUserIds.toList()}');

      // Obtener perfiles del evento
      final attendeesSnapshot = await FirebaseFirestore.instance
          .collection('events')
          .doc(event.id)
          .get();

      if (!attendeesSnapshot.exists) {
        print('DEBUG: Evento no existe en Firestore');
        return [];
      }

      final eventData = attendeesSnapshot.data()!;
      final attendees = List<String>.from(eventData['attendees'] ?? []);

      print('DEBUG: Total de asistentes al evento: ${attendees.length}');
      print('DEBUG: Lista completa de asistentes: $attendees');

      // Filtrar usuarios que no han sido vistos, no han dado like, y no son matches
      final availableUserIds = attendees.where((userId) =>
          userId != currentUserId &&
          !likedUserIds.contains(userId) &&
          !matchedAndChattedUserIds.contains(userId)).toList();

      print('DEBUG: Usuarios disponibles después del filtrado: ${availableUserIds.length}');
      print('DEBUG: Lista de usuarios disponibles: $availableUserIds');

      // Aplicar paginación
      final paginatedUserIds = availableUserIds.skip(offset).take(limit).toList();

      print('DEBUG: Usuarios después de paginación: ${paginatedUserIds.length}');
      print('DEBUG: Lista paginada: $paginatedUserIds');

      if (paginatedUserIds.isEmpty) {
        print('DEBUG: No hay usuarios después de paginación');
        return [];
      }

      // OPTIMIZACIÓN: Consulta batch para verificar hasLikedMe
      final hasLikedMeMap = await _batchCheckHasLikedMe(paginatedUserIds, currentUserId);

      // Cargar perfiles en paralelo
      final profileFutures = paginatedUserIds.map((userId) async {
        // Verificar cache primero
        final cachedProfile = getFromCache(userId);
        if (cachedProfile != null) {
          print('DEBUG: Perfil encontrado en cache - ID: $userId');
          return cachedProfile;
        }

        // Cargar desde Firestore
        print('DEBUG: Cargando perfil desde Firestore - ID: $userId');
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .get();

        if (userDoc.exists) {
          final userData = userDoc.data()!;
          final hasLikedMe = hasLikedMeMap[userId] ?? false;
          final profile = UserProfile.fromMap(userId, userData, hasLikedMe: hasLikedMe);
          
          // Agregar al cache
          addToCache(profile);
          print('DEBUG: Perfil cargado exitosamente desde Firestore - ID: $userId, Nombre: ${profile.name}');
          
          return profile;
        } else {
          print('DEBUG: ❌ ERROR - Documento de usuario no existe en Firestore - ID: $userId');
          return null;
        }
      });

      final profiles = await Future.wait(profileFutures);
      final validProfiles = profiles.where((profile) => profile != null).cast<UserProfile>().toList();
      
      // Identificar usuarios que no se pudieron cargar
      final loadedUserIds = validProfiles.map((p) => p.userId).toSet();
      final failedUserIds = paginatedUserIds.where((id) => !loadedUserIds.contains(id)).toList();
      
      if (failedUserIds.isNotEmpty) {
        print('DEBUG: ❌ USUARIOS QUE NO SE PUDIERON CARGAR: $failedUserIds');
      }
      
      print('DEBUG: Lista de IDs de perfiles cargados: ${validProfiles.map((p) => p.userId).toList()}');
      print('DEBUG: Usuarios faltantes: ${paginatedUserIds.where((id) => !validProfiles.map((p) => p.userId).contains(id)).toList()}');
      
      print('DEBUG: Perfiles cargados exitosamente: ${validProfiles.length}');
      for (final profile in validProfiles) {
        print('DEBUG: Perfil cargado - ID: ${profile.userId}, Nombre: ${profile.name}');
      }
      print('DEBUG: === RESUMEN fetchProfilesBatch ===');
      print('DEBUG: Total asistentes al evento: ${attendees.length}');
      print('DEBUG: Usuarios disponibles después de filtros: ${availableUserIds.length}');
      print('DEBUG: Usuarios cargados en este batch: ${validProfiles.length}');
      print('DEBUG: Diferencia (disponibles - cargados): ${availableUserIds.length - validProfiles.length}');
      print('DEBUG: Offset usado: $offset, Limit usado: $limit');
      print('DEBUG: === FIN fetchProfilesBatch ===');
      
      return validProfiles;

    } catch (e) {
      print('Error fetching profiles batch: $e');
      return [];
    }
  }

  // Método optimizado para verificar hasLikedMe en batch
  Future<Map<String, bool>> _batchCheckHasLikedMe(List<String> userIds, String currentUserId) async {
    final Map<String, bool> hasLikedMeMap = {};
    
    try {
      // Crear consultas batch para verificar si cada usuario ya dio like al usuario actual
      final batchQueries = userIds.map((userId) async {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('likesGiven')
            .doc(currentUserId)
            .get();
        
        return {userId: doc.exists};
      });

      final results = await Future.wait(batchQueries);
      
      for (final result in results) {
        hasLikedMeMap.addAll(result);
      }
      
      print('DEBUG: Batch check hasLikedMe completado para ${userIds.length} usuarios');
      return hasLikedMeMap;
      
    } catch (e) {
      print('Error en batch check hasLikedMe: $e');
      // En caso de error, asumir que no han dado like
      for (final userId in userIds) {
        hasLikedMeMap[userId] = false;
      }
      return hasLikedMeMap;
    }
  }



  // Cargar perfil del usuario actual
  Future<UserProfile?> loadCurrentUserProfile() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return null;

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get();

    if (doc.exists) {
      final data = doc.data()!;
      currentUserProfile = UserProfile.fromMap(uid, data, hasLikedMe: false);
      return currentUserProfile;
    }
    return null;
  }

  // Optimizado: onLike con gestión de estado mejorada
  Future<void> onLike({
    required BuildContext context,
    required List<UserProfile> profiles,
    required Event event,
  }) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    final currentPage = pageController.page!.toInt();
    if (currentUser == null || currentPage >= profiles.length) return;

    final likedUser = profiles[currentPage];
    likedProfiles.add(likedUser.userId);

    // USAR CAMPO PRECARGADO en lugar de consultar Firestore
    final hasLikedMe = likedUser.hasLikedMe;
    print('DEBUG: hasLikedMe para ${likedUser.name}: $hasLikedMe (precargado)');

    // Si ya recibí like, mostrar animación instantánea
    if (hasLikedMe) {
      print('DEBUG: ¡MATCH INSTANTÁNEO! Mostrando animación...');
      
      // Crear matchId y marcarlo como mostrado
      final generatedMatchId = generateMatchId(currentUser.uid, likedUser.userId);
      markMatchAsShown(generatedMatchId);
      
      // Mostrar animación inmediatamente (UX instantánea)
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MatchAnimationScreen(
            userImage: currentUserProfile?.photoUrls.first ?? 'https://via.placeholder.com/150',
            matchImage: likedUser.photoUrls.isNotEmpty ? likedUser.photoUrls.first : 'https://via.placeholder.com/150',
            matchedUserId: likedUser.userId,
            matchedUserName: likedUser.name,
            matchedUserPhotoUrl: likedUser.photoUrls.isNotEmpty ? likedUser.photoUrls.first : 'https://via.placeholder.com/150',
            matchId: generatedMatchId, // ← PASAR matchId DIRECTAMENTE
          ),
        ),
      );
      
      // Ejecutar backend en paralelo (sin bloquear UX)
      _executeBackendMatch(generatedMatchId, currentUser.uid, likedUser.userId, event.id);
      
    } else {
      print('DEBUG: No es match instantáneo, procesando normalmente...');
      await handleLikeAndMatch(
        currentUserId: currentUser.uid,
        likedUserId: likedUser.userId,
        eventId: event.id,
        context: context,
        currentUserPhoto: currentUserProfile?.photoUrls.first ?? 'https://via.placeholder.com/150',
        matchedUserPhoto: likedUser.photoUrls.isNotEmpty ? likedUser.photoUrls.first : 'https://via.placeholder.com/150',
        matchedUserName: likedUser.name,
      );
    }

    // Remover perfil actual y avanzar (estilo Tinder)
    print('DEBUG: === onLike - Removiendo perfil ===');
    print('DEBUG: Página actual: $currentPage');
    print('DEBUG: Perfiles antes de remover: ${profiles.length}');
    print('DEBUG: Perfil a remover: ${profiles[currentPage].name} (ID: ${profiles[currentPage].userId})');
    
    profiles.removeAt(currentPage);
    currentIndex = currentPage;
    totalProcessedProfiles++;
    
    print('DEBUG: Perfiles después de remover: ${profiles.length}');
    print('DEBUG: totalProcessedProfiles: $totalProcessedProfiles');
    print('DEBUG: currentIndex: $currentIndex');
    
    // Cargar más perfiles si quedan pocos
    await loadMoreIfNeeded();
    
    // NO navegar automáticamente - quedarse en la página actual
    // La página actual ahora tiene el siguiente perfil después de remover
    print('DEBUG: No navegando automáticamente - quedándose en página actual');
    print('DEBUG: === FIN onLike ===');
  }

  // Ejecutar backend en paralelo para match instantáneo
  Future<void> _executeBackendMatch(String matchId, String currentUserId, String likedUserId, String eventId) async {
    try {
      // Guardar likes en paralelo
      await Future.wait([
        // Guardar en likesReceived del usuario destino
        FirebaseFirestore.instance
            .collection('users')
            .doc(likedUserId)
            .collection('likesReceived')
            .doc(currentUserId)
            .set({
          'eventId': eventId,
          'timestamp': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true)),

        // Guardar en likesGiven del usuario actual
        FirebaseFirestore.instance
            .collection('users')
            .doc(currentUserId)
            .collection('likesGiven')
            .doc(likedUserId)
            .set({
          'eventId': eventId,
          'timestamp': FieldValue.serverTimestamp(),
        }),
      ]);

      // Crear documento de match
      await FirebaseFirestore.instance
          .collection('matches')
          .doc(matchId)
          .set({
        'users': [currentUserId, likedUserId],
        'eventId': eventId,
        'createdAt': FieldValue.serverTimestamp(),
      });

      print('DEBUG: Backend match completado: $matchId');
      
    } catch (e) {
      print('Error ejecutando backend match: $e');
      // No mostrar error al usuario para mantener UX fluida
    }
  }

  void onDislike(List<UserProfile> profiles) {
    final currentPage = pageController.page!.toInt();
    
    print('DEBUG: === onDislike ===');
    print('DEBUG: Página actual: $currentPage');
    print('DEBUG: Perfiles antes de remover: ${profiles.length}');
    print('DEBUG: Perfil a remover: ${profiles[currentPage].name} (ID: ${profiles[currentPage].userId})');
    
    // Remover perfil actual y avanzar
    profiles.removeAt(currentPage);
    currentIndex = currentPage;
    totalProcessedProfiles++;
    
    print('DEBUG: Perfiles después de remover: ${profiles.length}');
    print('DEBUG: totalProcessedProfiles: $totalProcessedProfiles');
    print('DEBUG: currentIndex: $currentIndex');
    
    // Cargar más perfiles si quedan pocos
    loadMoreIfNeeded();
    
    // NO navegar automáticamente - quedarse en la página actual
    // La página actual ahora tiene el siguiente perfil después de remover
    print('DEBUG: No navegando automáticamente - quedándose en página actual');
    print('DEBUG: === FIN onDislike ===');
  }

  // Stream para matches en tiempo real
  Stream<QuerySnapshot> get matchesStream {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    if (currentUserId == null) return Stream.empty();
    
    return FirebaseFirestore.instance
        .collection('matches')
        .where('users', arrayContains: currentUserId)
        .snapshots();
  }

  // Verificar si es un match nuevo
  bool isNewMatch(String matchId) {
    // Si no está inicializado, no mostrar animaciones
    if (!isInitialized) return false;
    
    // Si ya se mostró, no es nuevo
    if (shownMatches.contains(matchId)) return false;
    
    // Si está pendiente de mostrar, no es nuevo
    if (pendingMatches.contains(matchId)) return false;
    
    // Es un match nuevo
    pendingMatches.add(matchId);
    return true;
  }

  // Marcar match como mostrado
  void markMatchAsShown(String matchId) {
    shownMatches.add(matchId);
    pendingMatches.remove(matchId);
    print('DEBUG: Match marcado como mostrado: $matchId');
  }

  // Mostrar animación de match retroactivo
  void showRetroactiveMatchAnimation(
    BuildContext context,
    String matchId,
    String otherUserId,
    String otherUserName,
    String otherUserPhotoUrl,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MatchAnimationScreen(
          userImage: currentUserProfile?.photoUrls.first ?? 'https://via.placeholder.com/150',
          matchImage: otherUserPhotoUrl,
          matchedUserId: otherUserId,
          matchedUserName: otherUserName,
          matchedUserPhotoUrl: otherUserPhotoUrl,
          matchId: matchId, // ← PASAR matchId DIRECTAMENTE
        ),
      ),
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

  // Método de debug para imprimir estado actual
  void printDebugState() {
    print('=== DEBUG ESTADO ACTUAL ===');
    print('Perfiles en memoria: ${profiles.length}');
    print('Perfiles procesados: $totalProcessedProfiles');
    print('Índice actual: $currentIndex');
    print('Hay más perfiles: $hasMoreProfiles');
    print('Está cargando: $isLoading');
    print('Batch size: $batchSize');
    print('==========================');
  }
}
