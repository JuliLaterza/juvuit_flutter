# Configuración de Google y Apple Sign In para iOS

## ✅ Lo que ya está configurado

- ✅ Dependencias instaladas (`google_sign_in` y `sign_in_with_apple`)
- ✅ Servicio de autenticación implementado
- ✅ Botones de login conectados en la UI
- ✅ URL schemes configurados en Info.plist
- ✅ GoogleService-Info.plist configurado

## 🔧 Configuraciones pendientes

### 1. Firebase Console

1. Ve a [Firebase Console](https://console.firebase.google.com/)
2. Selecciona tu proyecto `juvuit-flutter`
3. Ve a **Authentication** > **Sign-in method**
4. Habilita **Google** como proveedor:
   - Agrega tu email como usuario autorizado
   - Guarda los cambios
5. Habilita **Apple** como proveedor:
   - Agrega tu email como usuario autorizado
   - Guarda los cambios

### 2. Apple Developer Console

1. Ve a [Apple Developer Console](https://developer.apple.com/)
2. En **Certificates, Identifiers & Profiles**
3. Selecciona tu **App ID** (`com.example.juvuitFlutter`)
4. Habilita **Sign In with Apple**
5. Guarda los cambios

### 3. Crear Service ID para Apple Sign In

1. En Apple Developer Console, ve a **Identifiers**
2. Crea un nuevo **Service ID**
3. Bundle ID: `com.example.juvuitFlutter`
4. Habilita **Sign In with Apple**
5. Configura los dominios de redirección:
   - `https://juvuit-flutter.firebaseapp.com/__/auth/handler`

### 4. Configurar Xcode (si es necesario)

1. Abre el proyecto en Xcode: `ios/Runner.xcworkspace`
2. Selecciona el target **Runner**
3. Ve a **Signing & Capabilities**
4. Asegúrate de que **Sign In with Apple** esté habilitado
5. Verifica que el **Bundle Identifier** sea `com.example.juvuitFlutter`

## 🧪 Probar la implementación

### Para Google Sign In:
1. Ejecuta la app en un dispositivo iOS físico
2. Ve a la pantalla de login
3. Toca "Continuar con Google"
4. Debería abrirse el selector de cuentas de Google

### Para Apple Sign In:
1. Ejecuta la app en un dispositivo iOS físico
2. Ve a la pantalla de login
3. Toca "Continuar con Apple"
4. Debería aparecer el diálogo de Apple Sign In

## 🚨 Solución de problemas comunes

### Error: "Google Sign-In no está disponible"
- Verifica que estés probando en un dispositivo físico (no simulador)
- Asegúrate de que Google Sign In esté habilitado en Firebase Console

### Error: "Apple Sign In no está disponible"
- Verifica que estés probando en un dispositivo físico con iOS 13+
- Asegúrate de que Sign In with Apple esté habilitado en Apple Developer Console

### Error de URL schemes
- Verifica que el `REVERSED_CLIENT_ID` en Info.plist coincida con el de GoogleService-Info.plist
- Asegúrate de que el Bundle ID sea consistente en todos los lugares

## 📱 Datos que necesitas para completar la configuración

1. **Apple Developer Account** (ya tienes)
2. **Bundle ID de tu app** (actualmente `com.example.juvuitFlutter`)
3. **Firebase Project ID** (ya configurado: `juvuit-flutter`)
4. **Google OAuth Client ID** (ya configurado en GoogleService-Info.plist)

## 🔄 Próximos pasos

Una vez que hayas completado las configuraciones de Firebase Console y Apple Developer Console:

1. Prueba la funcionalidad en un dispositivo físico
2. Verifica que los usuarios se creen correctamente en Firebase Auth
3. Asegúrate de que los datos del usuario se guarden en Firestore después del login

## 📞 Soporte

Si encuentras problemas:
1. Verifica los logs de la consola para errores específicos
2. Asegúrate de que todas las configuraciones estén completas
3. Prueba en un dispositivo físico, no en simulador 