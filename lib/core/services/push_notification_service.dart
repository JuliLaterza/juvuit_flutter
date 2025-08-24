import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

class PushNotificationService {
  static final PushNotificationService _instance = PushNotificationService._internal();
  factory PushNotificationService() => _instance;
  PushNotificationService._internal();

  // URL base de las funciones de Firebase (se debe obtener después del deploy)
  static const String _baseUrl = 'https://us-central1-juvuit-flutter.cloudfunctions.net';

  /// Envía una notificación de prueba al usuario actual
  Future<bool> sendTestNotification({
    String title = 'Notificación de prueba',
    String body = 'Esta es una notificación de prueba desde Firebase Functions',
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('Usuario no autenticado');
    }

    print('Enviando notificación push para usuario: ${user.uid}');
    print('Título: $title');
    print('Cuerpo: $body');

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/send_test_notification'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'userId': user.uid,
          'title': title,
          'body': body,
        }),
      );

      print('Respuesta del servidor: ${response.statusCode}');
      print('Cuerpo de respuesta: ${response.body}');

      if (response.statusCode == 200) {
        print('✅ Notificación de prueba enviada exitosamente');
        return true;
      } else {
        print('❌ Error enviando notificación: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      print('❌ Error en sendTestNotification: $e');
      return false;
    }
  }

  /// Envía una notificación de match
  Future<bool> sendMatchNotification({
    required String matchUserId,
    required String eventName,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('Usuario no autenticado');
    }

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/send_match_notification'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'userId': user.uid,
          'matchUserId': matchUserId,
          'eventName': eventName,
        }),
      );

      if (response.statusCode == 200) {
        print('Notificación de match enviada exitosamente');
        return true;
      } else {
        print('Error enviando notificación de match: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error en sendMatchNotification: $e');
      return false;
    }
  }

  /// Obtiene la URL base de las funciones de Firebase
  /// Esta función se puede usar para verificar si las funciones están desplegadas
  Future<String> getFunctionsBaseUrl() async {
    return _baseUrl;
  }
}
