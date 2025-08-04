# Configuración de Google y Apple Sign-In

## ✅ Lo que ya está implementado

1. **Dependencias agregadas** al `pubspec.yaml`:
   - `google_sign_in: ^6.2.1`
   - `sign_in_with_apple: ^6.0.0`

2. **Servicio de autenticación** creado en `lib/core/services/auth_service.dart` con métodos para:
   - Login con email/password
   - Registro con email/password
   - Login con Google
   - Login con Apple
   - Cerrar sesión

3. **Pantallas actualizadas**:
   - `login_screen.dart` - Botones de Google y Apple funcionales
   - `register_screen.dart` - Botones de Google y Apple funcionales

## 🔧 Configuración necesaria

### Para Google Sign-In (Android)

1. **Obtener SHA-1 fingerprint** (ya tienes el tuyo):
   ```
   SHA1: A2:36:66:CE:96:95:21:10:97:FB:29:DA:A5:B6:3C:44:9F:EE:BA:34
   ```

2. **Ir a Firebase Console**:
   - Ve a https://console.firebase.google.com
   - Selecciona tu proyecto `juvuit-flutter`
   - Ve a Project Settings (⚙️)
   - En la pestaña "General", busca la sección "Your apps"
   - Selecciona tu app de Android
   - Haz clic en "Add fingerprint"
   - Agrega el SHA-1: `A2:36:66:CE:96:95:21:10:97:FB:29:DA:A5:B6:3C:44:9F:EE:BA:34`

3. **Descargar el archivo google-services.json actualizado** y reemplazar el existente en `android/app/google-services.json`

### Para Google Sign-In (iOS)

1. **En Firebase Console**:
   - Ve a Project Settings
   - En la pestaña "General", selecciona tu app de iOS
   - Copia el "Bundle ID": `com.example.juvuitFlutter`

2. **En Xcode**:
   - Abre `ios/Runner.xcworkspace`
   - Selecciona el target "Runner"
   - Ve a "Signing & Capabilities"
   - Asegúrate de que el Bundle Identifier coincida con el de Firebase

### Para Apple Sign-In (iOS)

1. **En Xcode**:
   - Abre `ios/Runner.xcworkspace`
   - Selecciona el target "Runner"
   - Ve a "Signing & Capabilities"
   - Haz clic en "+ Capability"
   - Agrega "Sign in with Apple"

2. **En Firebase Console**:
   - Ve a Authentication > Sign-in method
   - Habilita "Apple"
   - Configura el Service ID (opcional)

## 🧪 Probar la implementación

1. **Ejecutar la app**:
   ```bash
   flutter run
   ```

2. **Probar en Android**:
   - Los botones de Google deberían abrir el selector de cuentas de Google
   - El botón de Apple solo funcionará en dispositivos iOS

3. **Probar en iOS**:
   - Los botones de Google y Apple deberían funcionar correctamente

## 🔍 Solución de problemas comunes

### Error: "Google Sign In not available"
- Verifica que el SHA-1 esté correctamente configurado en Firebase
- Asegúrate de que el archivo `google-services.json` esté actualizado

### Error: "Apple Sign In not available"
- Verifica que la capacidad "Sign in with Apple" esté agregada en Xcode
- Solo funciona en dispositivos iOS reales (no en simulador)

### Error: "Network error"
- Verifica tu conexión a internet
- Asegúrate de que las APIs de Google estén habilitadas en Google Cloud Console

## 📱 Flujo de usuario

1. **Usuario hace clic en "Continuar con Google"**:
   - Se abre el selector de cuentas de Google
   - Usuario selecciona su cuenta
   - Se autentica con Firebase
   - Se redirige a EventsScreen

2. **Usuario hace clic en "Continuar con Apple"**:
   - Se abre el diálogo de Apple Sign In
   - Usuario se autentica con Face ID/Touch ID
   - Se autentica con Firebase
   - Se redirige a EventsScreen

## 🎯 Próximos pasos

1. **Configurar el SHA-1 en Firebase Console**
2. **Agregar la capacidad de Apple Sign In en Xcode**
3. **Probar en dispositivos reales**
4. **Manejar casos de error específicos**
5. **Implementar logout funcional**

## 📝 Notas importantes

- **Google Sign-In**: Funciona en Android e iOS
- **Apple Sign-In**: Solo funciona en iOS (requerido por Apple)
- **Firebase Auth**: Ya está configurado y funcionando
- **Navegación**: Los usuarios son redirigidos a EventsScreen después del login exitoso
- **Manejo de errores**: Se muestran mensajes de error apropiados al usuario 