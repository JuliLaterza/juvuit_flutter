# Solución para Sesión Persistente de Google Sign-In

## Problema
Cuando un usuario se registra con Google y luego sale de la aplicación, la sesión de Google queda "en memoria" y no se muestra el selector de cuentas al intentar iniciar sesión nuevamente.

## Causa
Google Sign-In mantiene la sesión en caché del dispositivo, lo que hace que no se muestre el selector de cuentas cuando el usuario intenta iniciar sesión nuevamente.

## Solución Implementada

### 1. Nuevos Métodos en AuthService

#### `clearGoogleSession()`
- Método agresivo que limpia completamente la sesión de Google
- Maneja errores de forma individual para cada operación
- Incluye `disconnect()`, `signOut()` y limpieza de Firebase Auth

#### `forceGoogleAccountSelector()`
- Método específico para forzar el selector de cuentas
- Crea una nueva instancia de GoogleSignIn para forzar la limpieza
- Se ejecuta antes de cada intento de login con Google

#### `signOutForAccountDeletion()`
- Método específico para eliminación de cuenta
- No desconecta de Google porque el usuario se elimina completamente

### 2. Modificaciones en ProfileScreen
- Se importó `AuthService`
- Se reemplazó `FirebaseAuth.instance.signOut()` por `_authService.clearGoogleSession()`
- Se usa `signOutForAccountDeletion()` para eliminación de cuenta

### 3. Flujo de Login Mejorado
1. Al intentar login con Google, se ejecuta `forceGoogleAccountSelector()`
2. Se limpia completamente la sesión anterior
3. Se fuerza la creación de una nueva instancia de GoogleSignIn
4. Se muestra el selector de cuentas al usuario

## Archivos Modificados

### `lib/core/services/auth_service.dart`
- Agregados nuevos métodos para manejo de sesión
- Mejorado el método `signInWithGoogle()`
- Implementada limpieza agresiva de caché

### `lib/features/profile/presentation/screens/profile_screen.dart`
- Importado `AuthService`
- Reemplazados métodos de logout directos
- Implementado logout específico para eliminación de cuenta

## Beneficios
- ✅ El usuario siempre ve el selector de cuentas de Google
- ✅ Se puede cambiar entre diferentes cuentas de Google
- ✅ La sesión se limpia completamente al hacer logout
- ✅ Manejo robusto de errores
- ✅ Compatible con eliminación de cuenta

## Notas Técnicas
- El método `disconnect()` revoca los tokens de acceso
- `signOut()` limpia la sesión local
- La creación de nueva instancia fuerza la limpieza de caché
- Se mantiene compatibilidad con iOS y Android
