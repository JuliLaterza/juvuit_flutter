import 'package:flutter/material.dart';
import 'package:juvuit_flutter/features/auth/presentation/screens/login_screen.dart';
import 'package:juvuit_flutter/features/auth/presentation/screens/register_screen.dart';
import 'package:juvuit_flutter/features/chats/presentation/screens/chats_screen.dart';
import 'package:juvuit_flutter/features/chats/presentation/screens/chat_screen.dart'; // Importación necesaria
import 'package:juvuit_flutter/features/events/presentation/screens/events_screen.dart';
import 'package:juvuit_flutter/features/matching/presentation/screens/matching_ig_screen.dart';
import 'package:juvuit_flutter/features/matching/presentation/screens/matching_screen.dart';
import 'package:juvuit_flutter/features/profile/presentation/screens/profile_screen.dart';
import 'package:juvuit_flutter/features/profiles/presentation/screens/profiles_screen.dart'; // Nueva importación

class AppRoutes {
  // Nombres de las rutas
  static const String login = '/login';
  static const String register = '/register';
  static const String events = '/events';
  static const String matching = '/matching';
  static const String chats = '/chats';
  static const String chat = '/chat'; // Ruta existente
  static const String profile = '/profile';
  static const String profiles = '/profiles'; // Nueva ruta

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
        return MaterialPageRoute(builder: (_) => const MatchingIgScreen());
      case chats:
        return MaterialPageRoute(builder: (_) => const ChatsScreen());
      case chat:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => ChatScreen(
            personName: args['personName'], // Parámetro requerido
            personPhotoUrl: args['personPhotoUrl'], // Parámetro requerido
          ),
        );
      case profile:
        return MaterialPageRoute(builder: (_) => const ProfileScreen());
      case profiles:
        return MaterialPageRoute(builder: (_) => const MatchingIgScreen()); // Agregado
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
