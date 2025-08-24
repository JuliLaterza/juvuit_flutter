import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NotificationDebugger {
  static Future<void> debugNotifications() async {
    print('🔍 DEBUGGING NOTIFICATIONS');
    print('=' * 50);
    
    // 1. Verificar Firebase Auth
    print('\n1️⃣ Verificando Firebase Auth...');
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      print('✅ Usuario autenticado: ${user.uid}');
    } else {
      print('❌ Usuario no autenticado');
      return;
    }
    
    // 2. Verificar permisos de notificación
    print('\n2️⃣ Verificando permisos de notificación...');
    final messaging = FirebaseMessaging.instance;
    final settings = await messaging.getNotificationSettings();
    print('Estado de permisos: ${settings.authorizationStatus}');
    
    switch (settings.authorizationStatus) {
      case AuthorizationStatus.authorized:
        print('✅ Permisos otorgados');
        break;
      case AuthorizationStatus.denied:
        print('❌ Permisos denegados');
        break;
      case AuthorizationStatus.notDetermined:
        print('⚠️ Permisos no determinados');
        break;
      case AuthorizationStatus.provisional:
        print('⚠️ Permisos provisionales');
        break;
    }
    
    // 3. Verificar token FCM
    print('\n3️⃣ Verificando token FCM...');
    final token = await messaging.getToken();
    if (token != null) {
      print('✅ Token FCM obtenido: ${token.substring(0, 20)}...');
    } else {
      print('❌ No se pudo obtener token FCM');
    }
    
    // 4. Verificar SharedPreferences
    print('\n4️⃣ Verificando SharedPreferences...');
    final prefs = await SharedPreferences.getInstance();
    final notificationsEnabled = prefs.getBool('notifications_enabled');
    final savedToken = prefs.getString('fcm_token');
    
    print('Notificaciones habilitadas: $notificationsEnabled');
    if (savedToken != null) {
      print('Token guardado: ${savedToken.substring(0, 20)}...');
    } else {
      print('❌ No hay token guardado');
    }
    
    // 5. Verificar Firestore
    print('\n5️⃣ Verificando Firestore...');
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      
      if (userDoc.exists) {
        final data = userDoc.data()!;
        final fcmToken = data['fcmToken'];
        final notificationsEnabled = data['notificationsEnabled'];
        
        print('✅ Documento de usuario existe');
        if (fcmToken != null) {
          print('Token FCM en Firestore: ${fcmToken.toString().substring(0, 20)}...');
        } else {
          print('❌ No hay token FCM en Firestore');
        }
        print('Notificaciones habilitadas en Firestore: $notificationsEnabled');
      } else {
        print('❌ Documento de usuario no existe');
      }
    } catch (e) {
      print('❌ Error al verificar Firestore: $e');
    }
    
    // 6. Verificar configuración de la app
    print('\n6️⃣ Verificando configuración de la app...');
    print('Firebase configurado: ${FirebaseAuth.instance.app != null}');
    
    print('\n' + '=' * 50);
    print('🔍 DIAGNÓSTICO COMPLETADO');
  }
  
  static Future<void> testLocalNotification() async {
    print('\n🧪 Probando notificación local...');
    // Aquí puedes agregar código para probar notificaciones locales
  }
  
  static Future<void> testPushNotification() async {
    print('\n🧪 Probando notificación push...');
    // Aquí puedes agregar código para probar notificaciones push
  }
}

// Función para ejecutar desde la consola de Flutter
void main() async {
  await NotificationDebugger.debugNotifications();
}
