import 'package:flutter/material.dart';
import 'package:juvuit_flutter/features/auth/presentation/screens/login_screen.dart';
import 'package:juvuit_flutter/features/auth/presentation/screens/register_screen.dart';
import 'package:juvuit_flutter/features/chats/presentation/screens/chats_screen.dart';
import 'package:juvuit_flutter/features/chats/presentation/screens/chat_screen.dart'; // Importación necesaria
import 'package:juvuit_flutter/features/events/presentation/screens/events_screen.dart';
import 'package:juvuit_flutter/features/matching/presentation/screens/matching_ig_screen.dart';
// ignore: unused_import
import 'package:juvuit_flutter/features/matching/presentation/screens/matching_screen.dart';
import 'package:juvuit_flutter/features/profile/presentation/screens/edit_profile_screen.dart';
import 'package:juvuit_flutter/features/profile/presentation/screens/profile_screen.dart';
import 'package:juvuit_flutter/features/profile/presentation/screens/public_profile_screen.dart';
// ignore: unused_import
import 'package:juvuit_flutter/features/profiles/presentation/screens/profiles_screen.dart'; // Nueva importación
import 'package:juvuit_flutter/features/matching/widgets/matching_loader.dart';
import 'package:juvuit_flutter/features/testing/screens/DebugScreenRestartUsers.dart';
import 'package:juvuit_flutter/features/testing/screens/debug_screen_delete.dart';
//import 'package:juvuit_flutter/features/testing/screens/debug_screen_spotify.dart';
import 'package:juvuit_flutter/features/profile/presentation/screens/public_profile_screen.dart'; // nueva importación



class AppRoutes {
  // Nombres de las rutas
  static const String login = '/login';
  static const String register = '/register';
  static const String events = '/events';
  static const String matching = '/matching';
  static const String chats = '/chats';
  static const String chat = '/chat'; // Ruta existente
  static const String profile = '/profile';
  static const String profiles = '/profiles';
  static const String debug = '/debug'; // Nueva ruta
  static const String editProfile = '/edit-profile';
  static const String userProfile = '/user-profile';


  // Generador de rutas
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case register:
        return MaterialPageRoute(builder: (_) => const RegisterScreen());
      case events:
        return MaterialPageRoute(builder: (_) => const EventsScreen());
      case matching:
        return MaterialPageRoute(builder: (_) => const MatchingScreen());
      case chats:
        return MaterialPageRoute(builder: (_) => const ChatsScreen());
      case chat:
      final args = settings.arguments as Map<String, dynamic>;
      return MaterialPageRoute(
        builder: (_) => ChatScreen(
          matchId: args['matchId'], // <- agregamos esto
          personName: args['personName'],
          personPhotoUrl: args['personPhotoUrl'],
        ),
      );
      case profile:
        return MaterialPageRoute(builder: (_) => const ProfileScreen());
      case profiles:
        return MaterialPageRoute(builder: (_) => const MatchingIgScreen()); // Agregado
      case editProfile:
        return MaterialPageRoute(builder: (_) => const EditProfileScreen());
      case userProfile:
      case '/public_profile':
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => PublicProfileScreen(profile: args['profile']),
        );
      case debug:
        return MaterialPageRoute(builder: (_) => const DebugScreenRestartUsers());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('Ruta no encontrada: ${settings.name}'),
            ),
          ),
        );
    }
  }
}
