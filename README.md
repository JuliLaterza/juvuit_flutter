# 🚀 WIT Ü - Flutter App

[![Flutter](https://img.shields.io/badge/Flutter-3.5.4+-blue.svg)](https://flutter.dev/)
[![Dart](https://img.shields.io/badge/Dart-3.0+-blue.svg)](https://dart.dev/)
[![Firebase](https://img.shields.io/badge/Firebase-10.7.1+-orange.svg)](https://firebase.google.com/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

**WIT Ü** es una aplicación móvil desarrollada en Flutter que facilita el matching y conexión entre usuarios en eventos. La aplicación incluye funcionalidades de autenticación, matching, chat, gestión de eventos y perfiles de usuario.

## 📱 Características Principales

- 🔐 **Autenticación Segura** - Firebase Auth con email/password
- 💕 **Sistema de Matching** - Swipe de perfiles con algoritmo inteligente
- 💬 **Chat en Tiempo Real** - Mensajería instantánea entre matches
- 📅 **Gestión de Eventos** - Explorar y participar en eventos
- 👤 **Perfiles Personalizables** - Información detallada de usuarios
- 🌙 **Tema Claro/Oscuro** - Soporte para ambos temas
- 📱 **Notificaciones Push** - Alertas en tiempo real
- 🖼️ **Gestión de Imágenes** - Subida y compresión de fotos
- 📍 **Integración de Mapas** - Localización de eventos

## 🏗️ Arquitectura

El proyecto sigue una **Clean Architecture** con separación clara de responsabilidades:

```
lib/
├── core/           # Funcionalidades centrales
│   ├── services/   # Servicios (ThemeProvider, etc.)
│   ├── utils/      # Utilidades (rutas, temas, colores)
│   └── widgets/    # Widgets reutilizables
├── features/       # Características específicas
│   ├── auth/       # Autenticación
│   ├── matching/   # Sistema de matching
│   ├── chats/      # Mensajería
│   ├── events/     # Gestión de eventos
│   ├── profile/    # Perfiles de usuario
│   └── ...
└── main.dart       # Punto de entrada
```

## 🚀 Inicio Rápido

### Prerrequisitos

- Flutter SDK 3.5.4+
- Dart SDK 3.0+
- Android Studio / VS Code
- Firebase Project

### Instalación

1. **Clonar el repositorio:**
```bash
git clone https://github.com/tu-usuario/juvuit_flutter.git
cd juvuit_flutter
```

2. **Instalar dependencias:**
```bash
flutter pub get
```

3. **Configurar Firebase:**
   - Crear proyecto en [Firebase Console](https://console.firebase.google.com/)
   - Descargar archivos de configuración
   - Seguir la [Guía de Instalación](GUIA_INSTALACION.md)

4. **Ejecutar la aplicación:**
```bash
flutter run
```

## 📚 Documentación

### 📖 Documentación Completa
- **[Documentación Completa](DOCUMENTACION_COMPLETA.md)** - Guía completa de APIs, funciones y componentes
- **[Ejemplos de Código](EJEMPLOS_CODIGO.md)** - Ejemplos prácticos de implementación
- **[Guía de Instalación](GUIA_INSTALACION.md)** - Configuración paso a paso

### 🗂️ Estructura del Proyecto

```
📦 juvuit_flutter/
├── 📂 lib/
│   ├── 📄 main.dart                                    # Punto de entrada
│   ├── 📄 firebase_options.dart                        # Configuración Firebase
│   ├── 📂 core/                                        # Funcionalidades centrales
│   │   ├── 📂 services/
│   │   │   └── 📄 theme_provider.dart                  # Gestor de temas
│   │   ├── 📂 utils/
│   │   │   ├── 📄 routes.dart                          # Configuración de rutas
│   │   │   ├── 📄 app_themes.dart                      # Definición de temas
│   │   │   └── 📄 colors.dart                          # Paleta de colores
│   │   └── 📂 widgets/                                 # Widgets reutilizables
│   ├── 📂 features/                                    # Características específicas
│   │   ├── 📂 auth/                                    # Autenticación
│   │   ├── 📂 matching/                                # Sistema de matching
│   │   ├── 📂 chats/                                   # Mensajería
│   │   ├── 📂 events/                                  # Gestión de eventos
│   │   ├── 📂 profile/                                 # Perfiles de usuario
│   │   ├── 📂 onboarding/                              # Tutorial inicial
│   │   ├── 📂 likes_received/                          # Likes recibidos
│   │   ├── 📂 settings/                                # Configuraciones
│   │   ├── 📂 testing/                                 # Pantallas de desarrollo
│   │   └── 📂 user_actions/                            # Acciones de usuario
│   └── 📂 test/                                        # Pruebas unitarias
├── 📂 assets/                                          # Recursos estáticos
│   └── 📂 images/
│       └── 📂 homescreen/                              # Imágenes de la app
├── 📂 android/                                         # Configuración Android
├── 📂 ios/                                             # Configuración iOS
├── 📂 web/                                             # Configuración Web
├── 📂 windows/                                         # Configuración Windows
├── 📂 linux/                                           # Configuración Linux
├── 📂 macos/                                           # Configuración macOS
├── 📄 pubspec.yaml                                     # Dependencias
├── 📄 firebase.json                                    # Configuración Firebase
├── 📄 README.md                                        # Este archivo
├── 📄 DOCUMENTACION_COMPLETA.md                        # Documentación completa
├── 📄 EJEMPLOS_CODIGO.md                               # Ejemplos de código
└── 📄 GUIA_INSTALACION.md                              # Guía de instalación
```

## 🔧 Tecnologías Utilizadas

### Frontend
- **Flutter** - Framework de desarrollo móvil
- **Dart** - Lenguaje de programación
- **Provider** - Gestión de estado

### Backend & Servicios
- **Firebase Auth** - Autenticación de usuarios
- **Cloud Firestore** - Base de datos en tiempo real
- **Firebase Storage** - Almacenamiento de archivos
- **Firebase Messaging** - Notificaciones push

### Dependencias Principales
```yaml
dependencies:
  flutter:
    sdk: flutter
  firebase_core: ^3.9.0
  firebase_auth: ^5.3.4
  cloud_firestore: ^5.6.0
  provider: ^6.1.2
  dio: ^5.7.0
  flutter_local_notifications: ^18.0.1
  firebase_messaging: ^15.1.6
  font_awesome_flutter: ^10.8.0
  image_picker: ^1.1.2
  flutter_card_swiper: ^7.0.2
  card_swiper: ^3.0.1
  intl: ^0.20.2
  carousel_slider: ^5.0.0
  cached_network_image: ^3.3.1
  http: ^0.13.6
  apple_maps_flutter: ^1.0.2
  url_launcher: ^6.2.5
  shared_preferences: ^2.2.2
  firebase_storage: ^12.4.0
  uuid: ^4.3.3
  flutter_image_compress: ^2.2.0
```

## 🎯 Funcionalidades Principales

### 🔐 Autenticación
- Registro con email y contraseña
- Inicio de sesión seguro
- Recuperación de contraseña
- Completar perfil después del registro

### 💕 Sistema de Matching
- Swipe de perfiles (like/dislike)
- Algoritmo de matching inteligente
- Popup de match exitoso
- Filtros por preferencias

### 💬 Chat
- Mensajería en tiempo real
- Lista de conversaciones
- Indicador de escritura
- Notificaciones de mensajes

### 📅 Eventos
- Lista de eventos disponibles
- Información detallada
- Registro en eventos
- Contador de asistentes

### 👤 Perfiles
- Información personal
- Fotos de perfil
- Preferencias de matching
- Configuraciones de privacidad

## 🚀 Despliegue

### Android
```bash
# Generar APK
flutter build apk --release

# Generar App Bundle
flutter build appbundle --release
```

### iOS
```bash
# Generar para iOS
flutter build ios --release
```

### Web
```bash
# Generar para Web
flutter build web --release
```

## 🧪 Testing

```bash
# Ejecutar pruebas unitarias
flutter test

# Ejecutar análisis estático
flutter analyze

# Verificar cobertura de código
flutter test --coverage
```

## 🤝 Contribuir

1. Fork el proyecto
2. Crea una rama para tu feature (`git checkout -b feature/AmazingFeature`)
3. Commit tus cambios (`git commit -m 'Add some AmazingFeature'`)
4. Push a la rama (`git push origin feature/AmazingFeature`)
5. Abre un Pull Request

## 📋 Roadmap

- [ ] Integración con Spotify
- [ ] Sistema de verificación de perfiles
- [ ] Chat de voz
- [ ] Video llamadas
- [ ] Integración con redes sociales
- [ ] Sistema de reportes
- [ ] Modo premium
- [ ] Análisis avanzado de compatibilidad

## 🐛 Reportar Bugs

Si encuentras algún bug, por favor:

1. Revisa los [issues existentes](https://github.com/tu-usuario/juvuit_flutter/issues)
2. Crea un nuevo issue con:
   - Descripción detallada del problema
   - Pasos para reproducir
   - Comportamiento esperado vs actual
   - Capturas de pantalla (si aplica)
   - Información del dispositivo y sistema operativo

## 📄 Licencia

Este proyecto está bajo la Licencia MIT. Ver el archivo [LICENSE](LICENSE) para más detalles.

## 👥 Equipo

- **Desarrollador Principal** - [Tu Nombre](https://github.com/tu-usuario)
- **Diseñador UI/UX** - [Nombre del Diseñador](https://github.com/designer)
- **QA Tester** - [Nombre del Tester](https://github.com/tester)

## 🙏 Agradecimientos

- [Flutter Team](https://flutter.dev/) por el increíble framework
- [Firebase Team](https://firebase.google.com/) por los servicios backend
- [Flutter Community](https://flutter.dev/community) por el soporte continuo

## 📞 Contacto

- **Email**: tu-email@example.com
- **Website**: https://witu-app.com
- **Twitter**: [@witu_app](https://twitter.com/witu_app)
- **Instagram**: [@witu_app](https://instagram.com/witu_app)

---

<div align="center">
  <p>Hecho con ❤️ por el equipo de WIT Ü</p>
  <p>¿Te gusta el proyecto? ¡Dale una ⭐!</p>
</div>
