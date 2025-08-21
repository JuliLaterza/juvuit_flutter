import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  
  static const String _notificationEnabledKey = 'notifications_enabled';
  static const String _fcmTokenKey = 'fcm_token';

  // Inicializar el servicio
  Future<void> initialize() async {
    // Configurar notificaciones locales
    await _initializeLocalNotifications();
    
    // Configurar Firebase Messaging
    await _initializeFirebaseMessaging();
    
    // Configurar handlers para notificaciones
    _setupNotificationHandlers();
  }

  // Inicializar notificaciones locales
  Future<void> _initializeLocalNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _localNotifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );
  }

  // Inicializar Firebase Messaging
  Future<void> _initializeFirebaseMessaging() async {
    // Solicitar permisos
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    print('User granted permission: ${settings.authorizationStatus}');

    // Obtener token FCM
    String? token = await _firebaseMessaging.getToken();
    if (token != null) {
      await _saveFCMToken(token);
      await _updateFCMTokenInFirebase(token);
    }

    // Escuchar cambios en el token
    _firebaseMessaging.onTokenRefresh.listen((token) async {
      await _saveFCMToken(token);
      await _updateFCMTokenInFirebase(token);
    });

    // Configuración específica para iOS
    await _firebaseMessaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  // Configurar handlers de notificaciones
  void _setupNotificationHandlers() {
    // Notificaciones cuando la app está en primer plano
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Got a message whilst in the foreground!');
      print('Message data: ${message.data}');
      print('Message notification: ${message.notification}');

      // Mostrar notificación local siempre que haya contenido
      if (message.notification != null || message.data.isNotEmpty) {
        print('Showing local notification for push message');
        _showLocalNotification(message);
      } else {
        print('No notification content found in message');
      }
    });

    // Notificaciones cuando la app está en background y se toca
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('A new onMessageOpenedApp event was published!');
      _handleNotificationTap(message);
    });

    // Notificaciones cuando la app está cerrada y se abre desde la notificación
    _firebaseMessaging.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        print('App opened from terminated state via notification');
        _handleNotificationTap(message);
      }
    });
  }

  // Mostrar notificación local
  Future<void> _showLocalNotification(RemoteMessage message) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'default_channel',
      'Default Channel',
      channelDescription: 'Canal por defecto para notificaciones',
      importance: Importance.max,
      priority: Priority.high,
    );

    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await _localNotifications.show(
      message.hashCode,
      message.notification?.title ?? 'Nueva notificación',
      message.notification?.body ?? '',
      platformChannelSpecifics,
      payload: message.data.toString(),
    );
  }

  // Manejar tap en notificación
  void _onNotificationTapped(NotificationResponse response) {
    print('Notification tapped: ${response.payload}');
    // Aquí puedes agregar navegación específica basada en el payload
  }

  // Manejar tap en notificación de Firebase
  void _handleNotificationTap(RemoteMessage message) {
    print('Notification tapped: ${message.data}');
    // Aquí puedes agregar navegación específica basada en los datos
  }

  // Verificar si las notificaciones están habilitadas
  Future<bool> areNotificationsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_notificationEnabledKey) ?? true;
  }

  // Habilitar/deshabilitar notificaciones
  Future<void> setNotificationsEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_notificationEnabledKey, enabled);

    if (enabled) {
      await _enableNotifications();
    } else {
      await _disableNotifications();
    }
  }

  // Habilitar notificaciones
  Future<void> _enableNotifications() async {
    // Solicitar permisos nuevamente
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      // Obtener y guardar token FCM
      String? token = await _firebaseMessaging.getToken();
      if (token != null) {
        await _saveFCMToken(token);
        await _updateFCMTokenInFirebase(token);
      }
    }
  }

  // Deshabilitar notificaciones
  Future<void> _disableNotifications() async {
    // Eliminar token FCM de Firebase
    await _removeFCMTokenFromFirebase();
    
    // Eliminar token local
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_fcmTokenKey);
  }

  // Guardar token FCM localmente
  Future<void> _saveFCMToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_fcmTokenKey, token);
  }

  // Obtener token FCM guardado
  Future<String?> getFCMToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_fcmTokenKey);
  }

  // Actualizar token FCM en Firebase
  Future<void> _updateFCMTokenInFirebase(String token) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({
          'fcmToken': token,
          'notificationsEnabled': true,
          'lastTokenUpdate': FieldValue.serverTimestamp(),
        });
      } catch (e) {
        print('Error updating FCM token in Firebase: $e');
      }
    }
  }

  // Remover token FCM de Firebase
  Future<void> _removeFCMTokenFromFirebase() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({
          'fcmToken': FieldValue.delete(),
          'notificationsEnabled': false,
        });
      } catch (e) {
        print('Error removing FCM token from Firebase: $e');
      }
    }
  }

  // Enviar notificación de prueba
  Future<void> sendTestNotification() async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'test_channel',
      'Test Channel',
      channelDescription: 'Canal para notificaciones de prueba',
      importance: Importance.max,
      priority: Priority.high,
    );

    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await _localNotifications.show(
      0,
      'Notificación de prueba',
      '¡Las notificaciones están funcionando correctamente!',
      platformChannelSpecifics,
    );
  }

  // Obtener estado de permisos
  Future<AuthorizationStatus> getPermissionStatus() async {
    return await _firebaseMessaging.getNotificationSettings().then((settings) => settings.authorizationStatus);
  }
}
