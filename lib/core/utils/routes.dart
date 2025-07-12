// lib/core/utils/routes.dart

// ignore_for_file: unused_import, duplicate_import
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:juvuit_flutter/features/auth/presentation/screens/login_screen.dart';
import 'package:juvuit_flutter/features/auth/presentation/screens/register_screen.dart';
import 'package:juvuit_flutter/features/auth/presentation/screens/splash_screen.dart';
import 'package:juvuit_flutter/features/chats/presentation/screens/chats_screen.dart';
import 'package:juvuit_flutter/features/chats/presentation/screens/chat_screen.dart';
import 'package:juvuit_flutter/features/events/presentation/screens/events_screen.dart';
import 'package:juvuit_flutter/features/likes_received/presentation/screens/profile_action_screen.dart';
import 'package:juvuit_flutter/features/matching/presentation/screens/matching_ig_screen.dart';
import 'package:juvuit_flutter/features/matching/presentation/screens/matching_screen.dart';
import 'package:juvuit_flutter/features/profile/domain/models/user_profile.dart';
import 'package:juvuit_flutter/features/profile/presentation/screens/edit_profile_screen.dart';
import 'package:juvuit_flutter/features/profile/presentation/screens/profile_screen.dart';
import 'package:juvuit_flutter/features/profile/presentation/screens/public_profile_screen.dart';
import 'package:juvuit_flutter/features/testing/screens/debug_screen_home.dart';

class AppRoutes {
  static const String splash         = '/splash';
  static const String login          = '/login';
  static const String register       = '/register';
  static const String events         = '/events';
  static const String matching       = '/matching';
  static const String chats          = '/chats';
  static const String chat           = '/chat';
  static const String profile        = '/profile';
  static const String profiles       = '/profiles';
  static const String userProfile    = '/public_profile';
  static const String profile_action = '/profile_action';
  static const String editProfile    = '/edit-profile';
  static const String debug          = '/debug';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());

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
            matchId:        args['matchId'],
            personName:     args['personName'],
            personPhotoUrl: args['personPhotoUrl'],
          ),
        );

      case profile:
        return MaterialPageRoute(builder: (_) => const ProfileScreen());

      case profiles:
        return MaterialPageRoute(builder: (_) => const MatchingIgScreen());

      case editProfile:
        return MaterialPageRoute(builder: (_) => const EditProfileScreen());

      case userProfile:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => PublicProfileScreen(
            profile: args['profile'] as UserProfile,
          ),
        );

      case profile_action:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => ProfileActionScreen(
            profile:    args['profile']    as UserProfile,
            eventTitle: args['eventTitle'] as String,
            eventId:    args['eventId']    as String,
            myId:       args['myId']       as String,
          ),
        );

      case debug:
        return MaterialPageRoute(builder: (_) => const DebugHomeScreen());

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('Ruta no encontrada: ${settings.name}')),
          ),
        );
    }
  }
}
