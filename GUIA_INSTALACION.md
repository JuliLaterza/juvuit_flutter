# 🚀 Guía de Instalación y Configuración - WIT Ü Flutter App

## 📋 Tabla de Contenidos

1. [Requisitos Previos](#requisitos-previos)
2. [Instalación](#instalación)
3. [Configuración de Firebase](#configuración-de-firebase)
4. [Configuración por Plataforma](#configuración-por-plataforma)
5. [Variables de Entorno](#variables-de-entorno)
6. [Ejecución](#ejecución)
7. [Solución de Problemas](#solución-de-problemas)
8. [Despliegue](#despliegue)

---

## ⚙️ Requisitos Previos

### Software Necesario

- **Flutter SDK** (versión 3.5.4 o superior)
- **Dart SDK** (incluido con Flutter)
- **Android Studio** o **VS Code**
- **Git**
- **Node.js** (para algunas herramientas de desarrollo)

### Verificar Instalación

```bash
# Verificar Flutter
flutter doctor

# Verificar Dart
dart --version

# Verificar Git
git --version
```

### Configurar Variables de Entorno

```bash
# Agregar Flutter al PATH (Linux/macOS)
export PATH="$PATH:$HOME/flutter/bin"

# Para Windows, agregar a las variables de entorno del sistema
# C:\flutter\bin
```

---

## 📥 Instalación

### 1. Clonar el Repositorio

```bash
# Clonar el proyecto
git clone https://github.com/tu-usuario/juvuit_flutter.git

# Navegar al directorio
cd juvuit_flutter
```

### 2. Instalar Dependencias

```bash
# Obtener dependencias de Flutter
flutter pub get

# Verificar que todo esté correcto
flutter doctor
```

### 3. Verificar Configuración

```bash
# Verificar que el proyecto esté configurado correctamente
flutter analyze

# Ejecutar pruebas (si existen)
flutter test
```

---

## 🔥 Configuración de Firebase

### 1. Crear Proyecto en Firebase Console

1. Ve a [Firebase Console](https://console.firebase.google.com/)
2. Haz clic en "Crear un proyecto"
3. Ingresa el nombre del proyecto: `juvuit-flutter-app`
4. Habilita Google Analytics (opcional)
5. Selecciona tu cuenta de Google Analytics
6. Haz clic en "Crear proyecto"

### 2. Configurar Autenticación

1. En Firebase Console, ve a "Authentication"
2. Haz clic en "Comenzar"
3. En la pestaña "Sign-in method", habilita:
   - **Email/Password**
   - **Google** (opcional)
4. Haz clic en "Guardar"

### 3. Configurar Firestore Database

1. Ve a "Firestore Database"
2. Haz clic en "Crear base de datos"
3. Selecciona "Comenzar en modo de prueba"
4. Elige la ubicación más cercana a tus usuarios
5. Haz clic en "Listo"

### 4. Configurar Storage

1. Ve a "Storage"
2. Haz clic en "Comenzar"
3. Selecciona "Comenzar en modo de prueba"
4. Elige la ubicación más cercana
5. Haz clic en "Listo"

### 5. Configurar Cloud Messaging

1. Ve a "Cloud Messaging"
2. Haz clic en "Comenzar"
3. Sigue las instrucciones para configurar notificaciones push

---

## 📱 Configuración por Plataforma

### Android

#### 1. Configurar Android Studio

```bash
# Verificar que Android Studio esté configurado
flutter doctor --android-licenses
```

#### 2. Descargar google-services.json

1. En Firebase Console, ve a "Configuración del proyecto"
2. En la pestaña "General", haz clic en "Agregar app"
3. Selecciona el ícono de Android
4. Ingresa el package name: `com.example.juvuit_flutter`
5. Descarga el archivo `google-services.json`
6. Colócalo en `android/app/google-services.json`

#### 3. Configurar build.gradle

**android/app/build.gradle:**
```gradle
android {
    compileSdkVersion 34
    
    defaultConfig {
        applicationId "com.example.juvuit_flutter"
        minSdkVersion 21
        targetSdkVersion 34
        versionCode 1
        versionName "1.0"
    }
}

dependencies {
    implementation platform('com.google.firebase:firebase-bom:32.7.0')
    implementation 'com.google.firebase:firebase-analytics'
}
```

**android/build.gradle:**
```gradle
buildscript {
    dependencies {
        classpath 'com.google.gms:google-services:4.4.0'
    }
}
```

**android/app/build.gradle:**
```gradle
apply plugin: 'com.google.gms.google-services'
```

### iOS

#### 1. Configurar Xcode

```bash
# Verificar que Xcode esté configurado
flutter doctor
```

#### 2. Descargar GoogleService-Info.plist

1. En Firebase Console, ve a "Configuración del proyecto"
2. En la pestaña "General", haz clic en "Agregar app"
3. Selecciona el ícono de iOS
4. Ingresa el Bundle ID: `com.example.juvuitFlutter`
5. Descarga el archivo `GoogleService-Info.plist`
6. Colócalo en `ios/Runner/GoogleService-Info.plist`

#### 3. Configurar Info.plist

**ios/Runner/Info.plist:**
```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleURLName</key>
        <string>REVERSED_CLIENT_ID</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>com.googleusercontent.apps.YOUR_REVERSED_CLIENT_ID</string>
        </array>
    </dict>
</array>
```

### Web

#### 1. Configurar Firebase para Web

1. En Firebase Console, ve a "Configuración del proyecto"
2. En la pestaña "General", haz clic en "Agregar app"
3. Selecciona el ícono de Web
4. Registra la app con el nombre "WIT Ü Web"
5. Copia la configuración

#### 2. Configurar index.html

**web/index.html:**
```html
<!DOCTYPE html>
<html>
<head>
  <script src="https://www.gstatic.com/firebasejs/10.7.1/firebase-app.js"></script>
  <script src="https://www.gstatic.com/firebasejs/10.7.1/firebase-auth.js"></script>
  <script src="https://www.gstatic.com/firebasejs/10.7.1/firebase-firestore.js"></script>
  <script src="https://www.gstatic.com/firebasejs/10.7.1/firebase-storage.js"></script>
  <script src="https://www.gstatic.com/firebasejs/10.7.1/firebase-messaging.js"></script>
</head>
<body>
  <script>
    const firebaseConfig = {
      apiKey: "tu-api-key",
      authDomain: "tu-proyecto.firebaseapp.com",
      projectId: "tu-proyecto",
      storageBucket: "tu-proyecto.appspot.com",
      messagingSenderId: "123456789",
      appId: "tu-app-id"
    };
    
    firebase.initializeApp(firebaseConfig);
  </script>
  <script src="main.dart.js" type="application/javascript"></script>
</body>
</html>
```

---

## 🔧 Variables de Entorno

### Crear archivo .env

```bash
# Crear archivo .env en la raíz del proyecto
touch .env
```

### Configurar variables

**.env:**
```env
# Firebase Configuration
FIREBASE_API_KEY=tu-api-key
FIREBASE_AUTH_DOMAIN=tu-proyecto.firebaseapp.com
FIREBASE_PROJECT_ID=tu-proyecto
FIREBASE_STORAGE_BUCKET=tu-proyecto.appspot.com
FIREBASE_MESSAGING_SENDER_ID=123456789
FIREBASE_APP_ID=tu-app-id

# App Configuration
APP_NAME=WIT Ü
APP_VERSION=1.0.0
DEBUG_MODE=true

# API Endpoints
API_BASE_URL=https://api.tu-dominio.com
```

### Configurar firebase_options.dart

```dart
// lib/firebase_options.dart
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'tu-api-key',
    appId: 'tu-app-id',
    messagingSenderId: '123456789',
    projectId: 'tu-proyecto',
    authDomain: 'tu-proyecto.firebaseapp.com',
    storageBucket: 'tu-proyecto.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'tu-api-key',
    appId: 'tu-app-id',
    messagingSenderId: '123456789',
    projectId: 'tu-proyecto',
    storageBucket: 'tu-proyecto.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'tu-api-key',
    appId: 'tu-app-id',
    messagingSenderId: '123456789',
    projectId: 'tu-proyecto',
    storageBucket: 'tu-proyecto.appspot.com',
    iosClientId: 'tu-ios-client-id',
    iosBundleId: 'com.example.juvuitFlutter',
  );
}
```

---

## ▶️ Ejecución

### Desarrollo

```bash
# Ejecutar en modo debug
flutter run

# Ejecutar en modo debug con hot reload
flutter run --hot

# Ejecutar en dispositivo específico
flutter run -d <device-id>

# Listar dispositivos disponibles
flutter devices
```

### Producción

```bash
# Construir APK para Android
flutter build apk --release

# Construir App Bundle para Android
flutter build appbundle --release

# Construir para iOS
flutter build ios --release

# Construir para Web
flutter build web --release
```

### Verificar Funcionamiento

```bash
# Ejecutar análisis estático
flutter analyze

# Ejecutar pruebas
flutter test

# Verificar dependencias
flutter pub deps
```

---

## 🔧 Solución de Problemas

### Problemas Comunes

#### 1. Error de Dependencias

```bash
# Limpiar cache de Flutter
flutter clean

# Obtener dependencias nuevamente
flutter pub get

# Actualizar dependencias
flutter pub upgrade
```

#### 2. Error de Firebase

```bash
# Verificar configuración de Firebase
flutter doctor

# Verificar archivos de configuración
ls android/app/google-services.json
ls ios/Runner/GoogleService-Info.plist
```

#### 3. Error de Compilación

```bash
# Limpiar build
flutter clean

# Reconstruir
flutter build apk --debug
```

#### 4. Error de Permisos (Android)

**android/app/src/main/AndroidManifest.xml:**
```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
```

#### 5. Error de iOS

```bash
# Instalar pods
cd ios
pod install
cd ..

# Limpiar y reconstruir
flutter clean
flutter pub get
flutter build ios
```

### Logs y Debugging

```bash
# Ver logs en tiempo real
flutter logs

# Ejecutar con logs detallados
flutter run --verbose

# Ver logs específicos de Firebase
flutter run --debug
```

---

## 🚀 Despliegue

### Android

#### Google Play Store

1. **Generar App Bundle:**
```bash
flutter build appbundle --release
```

2. **Firmar la aplicación:**
```bash
# Crear keystore
keytool -genkey -v -keystore ~/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload

# Configurar key.properties
echo "storePassword=<password>" > android/key.properties
echo "keyPassword=<password>" >> android/key.properties
echo "keyAlias=upload" >> android/key.properties
echo "storeFile=<path>/upload-keystore.jks" >> android/key.properties
```

3. **Subir a Google Play Console**

#### APK Directo

```bash
# Generar APK firmado
flutter build apk --release

# El APK estará en: build/app/outputs/flutter-apk/app-release.apk
```

### iOS

#### App Store

1. **Generar archivo IPA:**
```bash
flutter build ios --release
```

2. **Abrir en Xcode:**
```bash
open ios/Runner.xcworkspace
```

3. **Configurar certificados y provisioning profiles**

4. **Subir a App Store Connect**

### Web

#### Firebase Hosting

1. **Instalar Firebase CLI:**
```bash
npm install -g firebase-tools
```

2. **Inicializar Firebase:**
```bash
firebase login
firebase init hosting
```

3. **Construir y desplegar:**
```bash
flutter build web
firebase deploy
```

#### Otros Servicios

```bash
# Netlify
flutter build web
netlify deploy --dir=build/web

# Vercel
flutter build web
vercel build/web
```

---

## 📋 Checklist de Instalación

### ✅ Pre-instalación
- [ ] Flutter SDK instalado
- [ ] Dart SDK instalado
- [ ] Android Studio/VS Code configurado
- [ ] Git instalado
- [ ] Variables de entorno configuradas

### ✅ Instalación del Proyecto
- [ ] Repositorio clonado
- [ ] Dependencias instaladas (`flutter pub get`)
- [ ] Análisis estático exitoso (`flutter analyze`)

### ✅ Configuración de Firebase
- [ ] Proyecto creado en Firebase Console
- [ ] Autenticación configurada
- [ ] Firestore Database configurada
- [ ] Storage configurado
- [ ] Cloud Messaging configurado

### ✅ Configuración por Plataforma
- [ ] Android: `google-services.json` configurado
- [ ] iOS: `GoogleService-Info.plist` configurado
- [ ] Web: Firebase configurado en `index.html`
- [ ] Permisos configurados en `AndroidManifest.xml`

### ✅ Variables de Entorno
- [ ] Archivo `.env` creado
- [ ] `firebase_options.dart` configurado
- [ ] Variables de entorno definidas

### ✅ Pruebas
- [ ] Aplicación ejecuta sin errores (`flutter run`)
- [ ] Autenticación funciona
- [ ] Base de datos conecta
- [ ] Storage funciona
- [ ] Notificaciones funcionan

---

## 📞 Soporte

### Recursos Útiles

- [Documentación de Flutter](https://flutter.dev/docs)
- [Documentación de Firebase](https://firebase.google.com/docs)
- [Firebase Console](https://console.firebase.google.com/)
- [Flutter Doctor](https://flutter.dev/docs/get-started/install)

### Contacto

Para soporte técnico:
- Crear un issue en GitHub
- Consultar la documentación completa
- Revisar los logs de error

---

*Esta guía te ayudará a configurar completamente el proyecto WIT Ü Flutter App. Sigue los pasos en orden y verifica cada sección antes de continuar.*