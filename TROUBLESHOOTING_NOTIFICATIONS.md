# 🔧 Solución de Problemas - Notificaciones Push

## 🚨 Problema: Notificaciones Push Fallando en Android

### ✅ Solución Implementada

**Problema identificado**: Las funciones de Firebase no estaban desplegadas (error 404).

**Solución aplicada**: 
1. ✅ Desplegadas las funciones de Firebase exitosamente
2. ✅ Verificadas las funciones funcionando correctamente
3. ✅ Agregado botón de diagnóstico al ProfileScreen

## 🔍 Pasos de Diagnóstico

### 1. Usar el Botón de Diagnóstico
1. Ve al ProfileScreen
2. Activa el switch "Recibir notificaciones"
3. Presiona "Diagnosticar Notificaciones"
4. Revisa los logs en la consola de Flutter

### 2. Verificar Manualmente

#### A. Verificar Firebase Functions
```bash
curl -X POST https://us-central1-juvuit-flutter.cloudfunctions.net/send_test_notification \
  -H "Content-Type: application/json" \
  -d '{"userId": "TU_USER_ID", "title": "Test", "body": "Test message"}'
```

#### B. Verificar Logs de Flutter
```bash
flutter logs
```

#### C. Verificar Estado de la App
- Usuario autenticado
- Permisos de notificación otorgados
- Token FCM generado
- Datos sincronizados en Firestore

## 🐛 Problemas Comunes y Soluciones

### ❌ Error: "Usuario no encontrado"
**Causa**: El usuario no existe en Firestore o no está autenticado
**Solución**: 
1. Asegúrate de estar logueado en la app
2. Verifica que el perfil esté creado
3. Usa el botón de diagnóstico para verificar

### ❌ Error: "No se pudo obtener token FCM"
**Causa**: Problemas con Google Play Services o configuración
**Solución**:
1. Verifica que Google Play Services esté actualizado
2. Reinicia el emulador/dispositivo
3. Verifica la configuración de Firebase

### ❌ Error: "Permisos denegados"
**Causa**: El usuario no otorgó permisos de notificación
**Solución**:
1. Ve a Configuración > Apps > Tu App > Notificaciones
2. Habilita las notificaciones
3. O desactiva y reactiva el switch en la app

### ❌ Error: "Funciones de Firebase no disponibles"
**Causa**: Las funciones no están desplegadas
**Solución**:
```bash
./deploy_functions.sh
```

## 🧪 Cómo Probar Correctamente

### 1. Prueba Básica
1. **Abre la app** en el emulador/dispositivo
2. **Logueate** con una cuenta válida
3. **Ve al ProfileScreen** (última pestaña)
4. **Activa el switch** "Recibir notificaciones"
5. **Acepta los permisos** cuando se soliciten

### 2. Prueba Notificaciones Locales
1. Presiona **"Probar local"**
2. Deberías ver una notificación inmediata
3. Si no funciona, revisa los logs

### 3. Prueba Notificaciones Push
1. Presiona **"Probar push"**
2. Deberías recibir una notificación desde Firebase
3. Si falla, usa el botón de diagnóstico

### 4. Diagnóstico Completo
1. Presiona **"Diagnosticar Notificaciones"**
2. Revisa los logs en la consola
3. Verifica cada paso del diagnóstico

## 📊 Estados Esperados

### ✅ Estado Correcto
```
🔍 DEBUGGING NOTIFICATIONS
==================================================

1️⃣ Verificando Firebase Auth...
✅ Usuario autenticado: [USER_ID]

2️⃣ Verificando permisos de notificación...
Estado de permisos: AuthorizationStatus.authorized
✅ Permisos otorgados

3️⃣ Verificando token FCM...
✅ Token FCM obtenido: [TOKEN_PARTIAL]...

4️⃣ Verificando SharedPreferences...
Notificaciones habilitadas: true
Token guardado: [TOKEN_PARTIAL]...

5️⃣ Verificando Firestore...
✅ Documento de usuario existe
Token FCM en Firestore: [TOKEN_PARTIAL]...
Notificaciones habilitadas en Firestore: true

6️⃣ Verificando configuración de la app...
Firebase configurado: true

==================================================
🔍 DIAGNÓSTICO COMPLETADO
```

### ❌ Estados Problemáticos

#### Usuario no autenticado
```
❌ Usuario no autenticado
```
**Solución**: Logueate en la app

#### Permisos denegados
```
Estado de permisos: AuthorizationStatus.denied
❌ Permisos denegados
```
**Solución**: Ve a Configuración y habilita notificaciones

#### Token FCM no generado
```
❌ No se pudo obtener token FCM
```
**Solución**: Reinicia la app y verifica Google Play Services

## 🔧 Comandos Útiles

### Verificar Funciones de Firebase
```bash
# Probar función de notificación
curl -X POST https://us-central1-juvuit-flutter.cloudfunctions.net/send_test_notification \
  -H "Content-Type: application/json" \
  -d '{"userId": "USER_ID", "title": "Test", "body": "Test message"}'

# Ver logs de Firebase Functions
firebase functions:log
```

### Verificar Configuración
```bash
# Verificar configuración de Flutter
flutter doctor

# Verificar dependencias
flutter pub get

# Limpiar y reconstruir
flutter clean
flutter pub get
flutter run
```

### Verificar Emulador
```bash
# Listar dispositivos
flutter devices

# Ver logs del emulador
adb logcat
```

## 📱 Configuración Específica por Plataforma

### Android
- ✅ Google Play Services actualizado
- ✅ Permisos de notificación habilitados
- ✅ Firebase configurado correctamente
- ✅ Funciones de Firebase desplegadas

### iOS
- ✅ Certificados de notificación configurados
- ✅ Permisos otorgados
- ✅ Dispositivo físico (no simulador para push)

## 🎯 Resultado Esperado

Después de seguir estos pasos, deberías poder:

1. ✅ **Activar/desactivar** notificaciones con el switch
2. ✅ **Recibir notificaciones locales** inmediatamente
3. ✅ **Recibir notificaciones push** desde Firebase
4. ✅ **Ver el diagnóstico completo** sin errores
5. ✅ **Persistir el estado** entre sesiones

## 🆘 Si el Problema Persiste

1. **Revisa los logs** del diagnóstico
2. **Verifica la configuración** de Firebase
3. **Prueba en un dispositivo físico** si usas emulador
4. **Revisa la documentación** de Firebase Messaging
5. **Contacta soporte** con los logs del diagnóstico

**¡Con estos pasos deberías poder resolver cualquier problema con las notificaciones!** 🚀
