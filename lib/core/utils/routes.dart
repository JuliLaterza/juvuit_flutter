// ignore_for_file: unused_import, duplicate_ignore, duplicate_import

import 'package:flutter/material.dart';
import 'package:juvuit_flutter/features/auth/presentation/screens/login_screen.dart';
import 'package:juvuit_flutter/features/auth/presentation/screens/register_screen.dart';
import 'package:juvuit_flutter/features/auth/presentation/screens/splash_screen.dart';
import 'package:juvuit_flutter/features/auth/presentation/screens/complete_profile_screen.dart';
import 'package:juvuit_flutter/features/chats/presentation/screens/chats_screen.dart';
import 'package:juvuit_flutter/features/chats/presentation/screens/chat_screen.dart'; // Importación necesaria
import 'package:juvuit_flutter/features/events/presentation/screens/events_screen.dart';
import 'package:juvuit_flutter/features/matching/presentation/screens/matching_ig_screen.dart';
// ignore: unused_import
import 'package:juvuit_flutter/features/matching/presentation/screens/matching_screen.dart';
import 'package:juvuit_flutter/features/onboarding/presentation/screens/intro_slides_screen.dart';
import 'package:juvuit_flutter/features/profile/presentation/screens/edit_profile_screen.dart';
import 'package:juvuit_flutter/features/profile/presentation/screens/profile_screen.dart';
import 'package:juvuit_flutter/features/profile/presentation/screens/public_profile_screen.dart';
import 'package:juvuit_flutter/features/profile/presentation/screens/matching_preferences_screen.dart';
import 'package:juvuit_flutter/features/profile/presentation/screens/emergency_contact_screen.dart';
import 'package:juvuit_flutter/features/profile/presentation/screens/help_center_screen.dart';
import 'package:juvuit_flutter/features/profile/presentation/screens/feedback_screen.dart';
// ignore: unused_import
import 'package:juvuit_flutter/features/profiles/presentation/screens/profiles_screen.dart'; // Nueva importación
import 'package:juvuit_flutter/features/matching/widgets/matching_loader.dart';
import 'package:juvuit_flutter/features/testing/screens/DebugScreenRestartUsers.dart';
import 'package:juvuit_flutter/features/testing/screens/debug_screen_delete.dart';
//import 'package:juvuit_flutter/features/testing/screens/debug_screen_spotify.dart';
import 'package:juvuit_flutter/features/profile/presentation/screens/public_profile_screen.dart';
import 'package:juvuit_flutter/features/testing/screens/debug_screen_home.dart';
import 'package:juvuit_flutter/features/testing/screens/debug_screen_infomap.dart';
import 'package:juvuit_flutter/features/testing/screens/debug_screen_premium.dart'; // nueva importación


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
  static const String splash = '/splash';
  static const String onboarding = '/onboarding';
  static const String matchingPreferences = '/matching-preferences';
  static const String emergencyContact = '/emergency-contact';
  static const String helpCenter = '/help-center';
  static const String feedback = '/feedback';
  static const String completeSongsDrink = '/complete-songs-drink';


  // Generador de rutas
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case onboarding:
        return MaterialPageRoute(builder: (_) => const IntroSlidesScreen());
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
        return MaterialPageRoute(builder: (_) => const ProfileScreen());// Agregado
      case editProfile:
        return MaterialPageRoute(builder: (_) => const EditProfileScreen());
      case matchingPreferences:
        return MaterialPageRoute(builder: (_) => const MatchingPreferencesScreen());
      case emergencyContact:
        return MaterialPageRoute(builder: (_) => const EmergencyContactScreen());
      case helpCenter:
        return MaterialPageRoute(builder: (_) => const HelpCenterScreen());
      case feedback:
        return MaterialPageRoute(builder: (_) => const FeedbackScreen());
      case completeSongsDrink:
        return MaterialPageRoute(builder: (_) => const CompleteSongsDrinkScreen());
      case userProfile:
      case '/public_profile':
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => PublicProfileScreen(profile: args['profile']),
        );
      case debug:
        return MaterialPageRoute(builder: (_) => const DebugSetPremiumScreen());
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
