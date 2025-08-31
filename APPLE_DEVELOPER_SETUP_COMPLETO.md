# 🍎 Configuración Completa de Apple Developer para WitU Flutter

## ✅ Estado Actual del Proyecto

Tu proyecto ya tiene configurado:
- **Development Team ID**: `79994Z5NX5`
- **Bundle ID**: `com.witu.app`
- **Entitlements**: Actualizados con Sign In with Apple
- **URL Scheme**: `com.witu.app.signin`

## 🔧 Pasos para Completar la Configuración

### Paso 1: Configurar App ID en Apple Developer Console

1. Ve a [developer.apple.com](https://developer.apple.com/)
2. Inicia sesión con tu cuenta de Apple Developer
3. Ve a **Certificates, Identifiers & Profiles**
4. En el menú lateral, haz clic en **Identifiers**
5. Busca el App ID: `com.witu.app`
   - **Si no existe**, créalo:
     - Haz clic en **+**
     - Selecciona **App IDs**
     - **Description**: `WitU App`
     - **Bundle ID**: `com.witu.app`
     - **Capabilities**: Marca **Sign In with Apple**
     - Haz clic en **Continue** y luego **Register**
   - **Si ya existe**, edítalo:
     - Selecciona tu App ID
     - Haz clic en **Edit**
     - En **Capabilities**, marca **Sign In with Apple**
     - Haz clic en **Save**

### Paso 2: Crear Service ID

1. En **Identifiers**, haz clic en **+**
2. Selecciona **Services IDs**
3. **Description**: `Witu Apple Sign-In`
4. **Identifier**: `com.witu.app.signin`
5. Marca **Sign In with Apple**
6. Haz clic en **Configure** junto a Sign In with Apple
7. **Primary App ID**: Selecciona `com.witu.app`
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
   - **Service ID**: `com.witu.app.signin`
   - **Apple Team ID**: `79994Z5NX5`
   - **Key ID**: (dejar vacío por ahora)
   - **Private Key**: (dejar vacío por ahora)

### Paso 4: Verificar en Xcode

1. Abre tu proyecto en Xcode:
   ```bash
   open ios/Runner.xcworkspace
   ```

2. Selecciona el target **Runner**
3. Ve a **Signing & Capabilities**
4. Verifica:
   - **Bundle Identifier**: `com.witu.app`
   - **Team**: `79994Z5NX5`
   - **Sign In with Apple**: Debe estar habilitado

### Paso 5: Probar la Configuración

1. Ejecuta la app en un dispositivo iOS físico:
   ```bash
   flutter run
   ```

2. Ve a la pantalla de login
3. Toca "Continuar con Apple"
4. Debería aparecer el diálogo de Apple Sign In

## 🚨 Solución de Problemas Comunes

### Error: "Sign In with Apple is not available"
- ✅ Verifica que estés probando en un dispositivo físico con iOS 13+
- ✅ Asegúrate de que Sign In with Apple esté habilitado en el App ID
- ✅ Verifica que el Service ID esté configurado correctamente

### Error: "Invalid Service ID"
- ✅ Verifica que el Service ID en Firebase Console sea: `com.witu.app.signin`
- ✅ Asegúrate de que los dominios y URLs de redirección estén configurados correctamente

### Error: "Bundle ID mismatch"
- ✅ Tu Bundle ID es: `com.witu.app`
- ✅ Verifica que coincida en Apple Developer Console y Firebase Console

## 📋 Checklist de Verificación

- [x] App ID creado en Apple Developer Console: `com.witu.app`
- [x] Sign In with Apple habilitado en el App ID
- [x] Service ID creado: `com.witu.app.signin`
- [x] Firebase Console configurado con Apple como proveedor
- [x] Team ID configurado: `79994Z5NX5`
- [x] Proyecto compila sin errores
- [ ] Apple Sign In funciona en dispositivo físico

## 🔗 Enlaces Útiles

- [Apple Developer Console](https://developer.apple.com/account/)
- [Firebase Console](https://console.firebase.google.com/)
- [Documentación de Sign In with Apple](https://developer.apple.com/sign-in-with-apple/)

## 📞 Datos de Contacto

Si necesitas ayuda adicional:
- Verifica los logs de la consola para errores específicos
- Asegúrate de que todas las configuraciones estén completas
- Prueba en un dispositivo físico, no en simulador

## 🎯 Configuración Actual

**Valores de configuración actuales:**
- **Bundle ID**: `com.witu.app`
- **Team ID**: `79994Z5NX5`
- **Service ID**: `com.witu.app.signin`
- **Firebase App ID**: `1:852726617261:ios:131fcc6be2c780ad68e224`
- **Callback URL**: `https://juvuit-flutter.firebaseapp.com/__/auth/handler`
