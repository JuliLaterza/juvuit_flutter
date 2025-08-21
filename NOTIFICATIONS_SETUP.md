# Configuración de Notificaciones Push

## 🎯 Funcionalidad Implementada

Se ha implementado un sistema completo de notificaciones push que incluye:

1. **Switch funcional** en ProfileScreen para habilitar/deshabilitar notificaciones
2. **Servicio de notificaciones locales** para mostrar notificaciones cuando la app está abierta
3. **Integración con Firebase Cloud Messaging (FCM)** para notificaciones push
4. **Funciones de Firebase** para enviar notificaciones desde el servidor
5. **Botones de prueba** para verificar el funcionamiento
6. **Soporte completo para iOS y Android** - Configurado para ambas plataformas

## 📱 Funcionalidades del Switch

### ✅ Habilitado
- Solicita permisos de notificación al sistema
- Obtiene y guarda el token FCM del dispositivo
- Actualiza el estado en Firebase Firestore
- Permite recibir notificaciones push

### ❌ Deshabilitado
- Elimina el token FCM de Firebase
- Limpia el token local
- Marca las notificaciones como deshabilitadas en Firestore
- No recibe notificaciones push

## 🧪 Botones de Prueba

### "Probar local"
- Envía una notificación local usando `flutter_local_notifications`
- Funciona incluso sin conexión a internet
- Útil para probar la UI de notificaciones

### "Probar push"
- Envía una notificación push desde Firebase Functions
- Requiere conexión a internet
- Simula notificaciones reales del servidor

## 🚀 Configuración Inicial

### 1. Desplegar Firebase Functions

```bash
# Ejecutar el script de despliegue
./deploy_functions.sh
```

### 2. Verificar Configuración

Asegúrate de que los siguientes archivos estén configurados correctamente:

- `android/app/google-services.json` - Configuración de Firebase para Android
- `ios/Runner/GoogleService-Info.plist` - Configuración de Firebase para iOS
- `firebase.json` - Configuración del proyecto Firebase

### 3. Permisos de Android

En `android/app/src/main/AndroidManifest.xml`, asegúrate de tener:

```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.WAKE_LOCK" />
<uses-permission android:name="android.permission.VIBRATE" />
<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED" />
```

### 4. Configuración de iOS

Para iOS, los archivos ya están configurados:

- **`ios/Runner/Info.plist`** - Permisos y modos de background
- **`ios/Runner/AppDelegate.swift`** - Manejo de notificaciones

**Importante**: Para notificaciones push en iOS, necesitas:
1. Habilitar "Push Notifications" en Xcode (Capabilities)
2. Configurar certificados de notificaciones push en Apple Developer Portal
3. Usar un dispositivo físico (las notificaciones push no funcionan en simulador)

## 🧪 Cómo Probar

### 1. Prueba Básica
1. Abre la app y ve al ProfileScreen
2. Activa el switch "Recibir notificaciones"
3. Presiona "Probar local" para ver una notificación inmediata
4. Presiona "Probar push" para recibir una notificación desde Firebase

### 2. Prueba de Deshabilitación
1. Desactiva el switch "Recibir notificaciones"
2. Intenta enviar notificaciones de prueba
3. Verifica que no se reciban notificaciones

### 3. Prueba de Persistencia
1. Cierra la app completamente
2. Vuelve a abrirla
3. Ve al ProfileScreen
4. Verifica que el estado del switch se mantenga

## 🔧 Funciones de Firebase Implementadas

### `send_test_notification`
- **URL**: `https://us-central1-juvuit-flutter.cloudfunctions.net/send_test_notification`
- **Método**: POST
- **Body**: 
```json
{
  "userId": "USER_ID",
  "title": "Título opcional",
  "body": "Mensaje opcional"
}
```

### `send_match_notification`
- **URL**: `https://us-central1-juvuit-flutter.cloudfunctions.net/send_match_notification`
- **Método**: POST
- **Body**:
```json
{
  "userId": "USER_ID",
  "matchUserId": "MATCH_USER_ID",
  "eventName": "Nombre del evento"
}
```

## 📊 Estructura de Datos en Firestore

### Documento de Usuario
```json
{
  "fcmToken": "TOKEN_FCM_DEL_DISPOSITIVO",
  "notificationsEnabled": true,
  "lastTokenUpdate": "TIMESTAMP",
  // ... otros campos del usuario
}
```

## 🐛 Solución de Problemas

### Notificaciones no llegan
1. Verifica que el switch esté activado
2. Comprueba los permisos del sistema
3. Verifica la conexión a internet
4. Revisa los logs de Firebase Functions

### Error en Firebase Functions
1. Verifica que las funciones estén desplegadas
2. Comprueba los logs en Firebase Console
3. Verifica que el usuario tenga un token FCM válido

### Token FCM no se genera
1. Verifica la configuración de Firebase
2. Comprueba que el usuario esté autenticado
3. Revisa los permisos de la app

## 🔄 Flujo de Notificaciones

1. **Usuario activa notificaciones** → Se solicita permiso al sistema
2. **Sistema otorga permiso** → Se obtiene token FCM
3. **Token se guarda** → En SharedPreferences y Firestore
4. **Servidor envía notificación** → Firebase Functions
5. **FCM entrega notificación** → Al dispositivo
6. **App muestra notificación** → Local o push según el estado

## 📝 Notas Importantes

- Las notificaciones locales funcionan inmediatamente
- Las notificaciones push requieren que las funciones estén desplegadas
- El token FCM puede cambiar, por eso se escuchan los cambios
- Las notificaciones se respetan según el estado del switch
- Los datos se sincronizan entre la app y Firebase

## 📱 Compatibilidad por Plataforma

### ✅ Android
- **Notificaciones locales**: Funcionan inmediatamente
- **Notificaciones push**: Funcionan sin configuración adicional
- **Simulador/Dispositivo**: Funcionan en ambos

### ✅ iOS
- **Notificaciones locales**: Funcionan inmediatamente
- **Notificaciones push**: Requieren certificados de Apple Developer Portal
- **Simulador**: Solo notificaciones locales
- **Dispositivo físico**: Notificaciones locales y push

**Para más detalles sobre iOS, consulta `IOS_NOTIFICATIONS_SETUP.md`**
