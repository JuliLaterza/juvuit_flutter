# Configuración de Apple Developer Console para Sign In with Apple

## 📋 Datos necesarios

### Tu información actual:
- **Bundle ID**: `com.example.juvuitFlutter`
- **App Name**: Juvuit Flutter
- **Firebase Project**: `juvuit-flutter`

### Información que necesitas obtener:
- **Apple Team ID**: (se encuentra en la parte superior de Apple Developer Console)
- **Apple Developer Account**: (ya tienes)

## 🔧 Pasos detallados

### Paso 1: Configurar App ID

1. Ve a [developer.apple.com](https://developer.apple.com/)
2. Inicia sesión con tu cuenta de Apple Developer
3. Ve a **Certificates, Identifiers & Profiles**
4. En el menú lateral, haz clic en **Identifiers**
5. Busca tu App ID: `com.example.juvuitFlutter`
   - Si no existe, crea uno nuevo:
     - Haz clic en **+**
     - Selecciona **App IDs**
     - **Description**: `Juvuit Flutter App`
     - **Bundle ID**: `com.example.juvuitFlutter`
     - **Capabilities**: Marca **Sign In with Apple**
     - Haz clic en **Continue** y luego **Register**

6. Si ya existe, edítalo:
   - Selecciona tu App ID
   - Haz clic en **Edit**
   - En **Capabilities**, marca **Sign In with Apple**
   - Haz clic en **Save**

### Paso 2: Crear Service ID

1. En **Identifiers**, haz clic en **+**
2. Selecciona **Services IDs**
3. **Description**: `Juvuit Flutter Sign In Service`
4. **Identifier**: `com.example.juvuitFlutter.signin`
5. Marca **Sign In with Apple**
6. Haz clic en **Configure** junto a Sign In with Apple
7. **Primary App ID**: Selecciona `com.example.juvuitFlutter`
8. **Domains and Subdomains**: Agrega:
   - `juvuit-flutter.firebaseapp.com`
9. **Return URLs**: Agrega:
   - `https://juvuit-flutter.firebaseapp.com/__/auth/handler`
10. Haz clic en **Save**

### Paso 3: Configurar Firebase Console

1. Ve a [Firebase Console](https://console.firebase.google.com/)
2. Selecciona tu proyecto `juvuit-flutter`
3. Ve a **Authentication** > **Sign-in method**
4. Habilita **Apple** como proveedor
5. Configura:
   - **Service ID**: `com.example.juvuitFlutter.signin`
   - **Apple Team ID**: (tu Team ID de Apple Developer)
   - **Key ID**: (dejar vacío por ahora)
   - **Private Key**: (dejar vacío por ahora)

### Paso 4: Verificar configuración en Xcode

1. Abre tu proyecto en Xcode:
   ```bash
   open ios/Runner.xcworkspace
   ```

2. Selecciona el target **Runner**
3. Ve a **Signing & Capabilities**
4. Verifica:
   - **Bundle Identifier**: `com.example.juvuitFlutter`
   - **Team**: Tu equipo de desarrollo
   - **Sign In with Apple**: Debe estar habilitado

### Paso 5: Probar la configuración

1. Ejecuta la app en un dispositivo iOS físico:
   ```bash
   flutter run
   ```

2. Ve a la pantalla de login
3. Toca "Continuar con Apple"
4. Debería aparecer el diálogo de Apple Sign In

## 🚨 Solución de problemas

### Error: "Sign In with Apple is not available"
- Verifica que estés probando en un dispositivo físico con iOS 13+
- Asegúrate de que Sign In with Apple esté habilitado en el App ID
- Verifica que el Service ID esté configurado correctamente

### Error: "Invalid Service ID"
- Verifica que el Service ID en Firebase Console coincida con el creado en Apple Developer Console
- Asegúrate de que los dominios y URLs de redirección estén configurados correctamente

### Error: "Bundle ID mismatch"
- Verifica que el Bundle ID en Xcode coincida con el App ID en Apple Developer Console
- Asegúrate de que el Bundle ID en Firebase Console sea correcto

## 📞 Datos de contacto para soporte

Si necesitas ayuda adicional:
1. Verifica los logs de la consola para errores específicos
2. Asegúrate de que todas las configuraciones estén completas
3. Prueba en un dispositivo físico, no en simulador

