import 'package:flutter/material.dart';
import 'package:juvuit_flutter/features/auth/presentation/screens/login_screen.dart';
import 'package:juvuit_flutter/features/auth/presentation/screens/register_screen.dart';
import 'package:juvuit_flutter/features/chats/presentation/screens/chats_screen.dart';
import 'package:juvuit_flutter/features/events/presentation/screens/events_screen.dart';
import 'package:juvuit_flutter/features/matching/presentation/screens/matching_screen.dart';
import 'package:juvuit_flutter/features/profile/presentation/screens/profile_screen.dart';


class AppRoutes {
  // Nombres de las rutas
  static const String login = '/login';
  static const String register = '/register';
  static const String events = '/events';
  static const String matching = '/matching';
  static const String chats = '/chats';
  static const String profile = '/profile';

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
      case profile:
        return MaterialPageRoute(builder: (_) => const ProfileScreen());
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
