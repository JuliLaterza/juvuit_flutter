# 📚 Documentación Completa - WIT Ü Flutter App

## 📋 Tabla de Contenidos

1. [Descripción General](#descripción-general)
2. [Arquitectura del Proyecto](#arquitectura-del-proyecto)
3. [Mapa de Carpetas y Archivos](#mapa-de-carpetas-y-archivos)
4. [APIs y Servicios](#apis-y-servicios)
5. [Modelos de Datos](#modelos-de-datos)
6. [Pantallas y Widgets](#pantallas-y-widgets)
7. [Utilidades y Helpers](#utilidades-y-helpers)
8. [Configuración y Dependencias](#configuración-y-dependencias)
9. [Guías de Uso](#guías-de-uso)

---

## 🎯 Descripción General

**WIT Ü** es una aplicación móvil desarrollada en Flutter que facilita el matching y conexión entre usuarios en eventos. La aplicación incluye funcionalidades de autenticación, matching, chat, gestión de eventos y perfiles de usuario.

### Características Principales:
- 🔐 Autenticación con Firebase
- 💕 Sistema de matching con swipe
- 💬 Chat en tiempo real
- 📅 Gestión de eventos
- 👤 Perfiles de usuario personalizables
- 🌙 Soporte para tema claro/oscuro
- 📱 Notificaciones push

---

## 🏗️ Arquitectura del Proyecto

El proyecto sigue una arquitectura **Clean Architecture** con separación de responsabilidades:

```
lib/
├── core/           # Funcionalidades centrales
├── features/       # Características específicas
└── main.dart       # Punto de entrada
```

### Patrón de Arquitectura por Feature:
```
features/[feature_name]/
├── data/           # Fuentes de datos y repositorios
├── domain/         # Lógica de negocio y modelos
└── presentation/   # UI y controladores
```

---

## 📁 Mapa de Carpetas y Archivos

### 📂 Estructura Principal

```
📦 juvuit_flutter/
├── 📂 lib/
│   ├── 📄 main.dart                                    # Punto de entrada de la aplicación
│   ├── 📄 firebase_options.dart                        # Configuración de Firebase
│   │
│   ├── 📂 core/                                        # Funcionalidades centrales
│   │   ├── 📂 services/
│   │   │   └── 📄 theme_provider.dart                  # Gestor de temas (claro/oscuro)
│   │   ├── 📂 utils/
│   │   │   ├── 📄 routes.dart                          # Configuración de rutas de navegación
│   │   │   ├── 📄 app_themes.dart                      # Definición de temas de la app
│   │   │   └── 📄 colors.dart                          # Paleta de colores
│   │   └── 📂 widgets/                                 # Widgets reutilizables
│   │
│   ├── 📂 features/                                    # Características específicas
│   │   ├── 📂 auth/                                    # Autenticación de usuarios
│   │   │   ├── 📂 domain/
│   │   │   │   └── 📂 models/
│   │   │   │       └── 📄 user.dart                    # Modelo de usuario
│   │   │   └── 📂 presentation/
│   │   │       ├── 📂 screens/
│   │   │       │   ├── 📄 login_screen.dart            # Pantalla de inicio de sesión
│   │   │       │   ├── 📄 register_screen.dart         # Pantalla de registro
│   │   │       │   ├── 📄 splash_screen.dart           # Pantalla de carga inicial
│   │   │       │   └── 📄 complete_profile_screen.dart # Completar perfil
│   │   │       └── 📂 widgets/
│   │   │           ├── 📄 complete_profile_form.dart   # Formulario de perfil
│   │   │           ├── 📄 DatePicker.dart              # Selector de fecha
│   │   │           └── 📄 image_picker_grid.dart       # Selector de imágenes
│   │   │
│   │   ├── 📂 chats/                                   # Sistema de mensajería
│   │   │   └── 📂 presentation/
│   │   │       └── 📂 screens/
│   │   │           ├── 📄 chats_screen.dart            # Lista de chats
│   │   │           └── 📄 chat_screen.dart             # Pantalla de chat individual
│   │   │
│   │   ├── 📂 events/                                  # Gestión de eventos
│   │   │   ├── 📂 application/                         # Casos de uso
│   │   │   ├── 📂 data/                                # Fuentes de datos
│   │   │   ├── 📂 domain/
│   │   │   │   ├── 📂 models/
│   │   │   │   │   └── 📄 event.dart                   # Modelo de evento
│   │   │   │   └── 📂 utils/                           # Utilidades de eventos
│   │   │   └── 📂 presentation/
│   │   │       ├── 📂 screens/
│   │   │       │   └── 📄 events_screen.dart           # Pantalla de eventos
│   │   │       └── 📂 widgets/                         # Widgets de eventos
│   │   │
│   │   ├── 📂 matching/                                # Sistema de matching
│   │   │   ├── 📂 controllers/
│   │   │   │   └── 📄 matching_profiles_controller.dart # Controlador de perfiles
│   │   │   ├── 📂 data/
│   │   │   │   └── 📄 fetch_attendee_profiles.dart     # Obtener perfiles de asistentes
│   │   │   ├── 📂 domain/
│   │   │   │   └── 📄 match_helper.dart                # Lógica de matching
│   │   │   ├── 📂 presentation/
│   │   │   │   └── 📂 screens/
│   │   │   │       ├── 📄 matching_screen.dart         # Pantalla principal de matching
│   │   │   │       ├── 📄 matching_ig_screen.dart      # Pantalla de matching estilo Instagram
│   │   │   │       └── 📄 match_animation_screen.dart  # Animación de match
│   │   │   └── 📂 widgets/
│   │   │       ├── 📄 profile_card.dart                # Tarjeta de perfil
│   │   │       ├── 📄 match_popup.dart                 # Popup de match exitoso
│   │   │       ├── 📄 ImageCarousel.dart               # Carrusel de imágenes
│   │   │       ├── 📄 NoMoreProfilesCard.dart          # Sin más perfiles
│   │   │       ├── 📄 reencounter_profile_card.dart    # Tarjeta de reencuentro
│   │   │       └── 📄 matching_loader.dart             # Cargador de matching
│   │   │
│   │   ├── 📂 likes_received/                          # Likes recibidos
│   │   │   ├── 📂 data/                                # Datos de likes
│   │   │   └── 📂 presentation/
│   │   │       ├── 📂 screens/                         # Pantallas de likes
│   │   │       └── 📂 widgets/
│   │   │           └── 📄 swipe_card.dart              # Tarjeta deslizable
│   │   │
│   │   ├── 📂 onboarding/                              # Tutorial inicial
│   │   │   └── 📂 presentation/
│   │   │       └── 📂 screens/
│   │   │           └── 📄 intro_slides_screen.dart     # Pantallas introductorias
│   │   │
│   │   ├── 📂 profile/                                 # Gestión de perfiles
│   │   │   ├── 📂 data/
│   │   │   │   └── 📂 services/                        # Servicios de perfil
│   │   │   ├── 📂 domain/
│   │   │   │   └── 📂 models/                          # Modelos de perfil
│   │   │   └── 📂 presentation/
│   │   │       └── 📂 screens/
│   │   │           ├── 📄 profile_screen.dart          # Perfil principal
│   │   │           ├── 📄 edit_profile_screen.dart     # Editar perfil
│   │   │           ├── 📄 public_profile_screen.dart   # Perfil público
│   │   │           ├── 📄 matching_preferences_screen.dart # Preferencias de matching
│   │   │           ├── 📄 emergency_contact_screen.dart # Contacto de emergencia
│   │   │           ├── 📄 help_center_screen.dart      # Centro de ayuda
│   │   │           └── 📄 feedback_screen.dart         # Envío de feedback
│   │   │
│   │   ├── 📂 profiles/                                # Exploración de perfiles
│   │   │   └── 📂 presentation/
│   │   │       └── 📂 screens/
│   │   │           └── 📄 profiles_screen.dart         # Pantalla de perfiles
│   │   │
│   │   ├── 📂 settings/                                # Configuraciones
│   │   │   └── 📂 presentation/
│   │   │       └── 📂 screens/                         # Pantallas de configuración
│   │   │
│   │   ├── 📂 testing/                                 # Pantallas de desarrollo
│   │   │   └── 📂 screens/
│   │   │       ├── 📄 debug_screen_spotify.dart        # Debug de Spotify
│   │   │       ├── 📄 DebugScreenRestartUsers.dart     # Reiniciar usuarios
│   │   │       ├── 📄 debug_screen_delete.dart         # Eliminar datos
│   │   │       ├── 📄 debug_screen_home.dart           # Debug de inicio
│   │   │       ├── 📄 debug_screen_infomap.dart        # Debug de mapa
│   │   │       └── 📄 debug_screen_premium.dart        # Debug premium
│   │   │
│   │   ├── 📂 upload_imag/                             # Subida de imágenes
│   │   │
│   │   └── 📂 user_actions/                            # Acciones de usuario
│   │       ├── 📂 data/
│   │       │   ├── 📂 datasources/                     # Fuentes de datos
│   │       │   └── 📂 repositories/                    # Repositorios
│   │       ├── 📂 domain/
│   │       │   ├── 📂 entities/                        # Entidades
│   │       │   ├── 📂 repositories/                    # Interfaces de repositorios
│   │       │   └── 📂 usecases/                        # Casos de uso
│   │       └── 📂 presentation/
│   │           ├── 📂 screens/                         # Pantallas de acciones
│   │           └── 📂 widgets/                         # Widgets de acciones
│   │
│   └── 📂 test/                                        # Pruebas unitarias
│
├── 📂 assets/                                          # Recursos estáticos
│   └── 📂 images/
│       └── 📂 homescreen/
│           ├── 📄 witu_logo_dark.png                   # Logo oscuro
│           ├── 📄 logo_witu.png                        # Logo principal
│           ├── 📄 witu_logo_light.png                  # Logo claro
│           ├── 📄 home.png                             # Imagen de inicio
│           ├── 📄 degrade-19.png                       # Degradado 19
│           └── 📄 degrade-20.png                       # Degradado 20
│
├── 📂 android/                                         # Configuración Android
├── 📂 ios/                                             # Configuración iOS
├── 📂 web/                                             # Configuración Web
├── 📂 windows/                                         # Configuración Windows
├── 📂 linux/                                           # Configuración Linux
├── 📂 macos/                                           # Configuración macOS
│
├── 📄 pubspec.yaml                                     # Dependencias del proyecto
├── 📄 pubspec.lock                                     # Versiones bloqueadas
├── 📄 firebase.json                                    # Configuración Firebase
├── 📄 analysis_options.yaml                            # Reglas de análisis
├── 📄 devtools_options.yaml                            # Configuración DevTools
├── 📄 README.md                                        # Documentación básica
└── 📄 THEME_IMPLEMENTATION.md                          # Implementación de temas
```

---

## 🔌 APIs y Servicios

### Firebase Services

#### 🔥 Firebase Core
```dart
// Inicialización en main.dart
await Firebase.initializeApp();
```

#### 🔐 Firebase Auth
```dart
// Autenticación de usuarios
import 'package:firebase_auth/firebase_auth.dart';

// Ejemplo de uso:
final user = FirebaseAuth.instance.currentUser;
```

#### 📊 Cloud Firestore
```dart
// Base de datos en tiempo real
import 'package:cloud_firestore/cloud_firestore.dart';

// Ejemplo de uso:
final usersRef = FirebaseFirestore.instance.collection('users');
```

#### 📱 Firebase Messaging
```dart
// Notificaciones push
import 'package:firebase_messaging/firebase_messaging.dart';

// Ejemplo de uso:
final messaging = FirebaseMessaging.instance;
```

#### 💾 Firebase Storage
```dart
// Almacenamiento de archivos
import 'package:firebase_storage/firebase_storage.dart';

// Ejemplo de uso:
final storageRef = FirebaseStorage.instance.ref();
```

### Servicios Locales

#### 🎨 ThemeProvider
```dart
// Gestión de temas
class ThemeProvider extends ChangeNotifier {
  bool get isDarkMode => _isDarkMode;
  ThemeColors get currentTheme => _isDarkMode ? ThemeColors.dark : ThemeColors.light;
  
  // Cambiar tema
  Future<void> toggleTheme() async;
  
  // Establecer tema específico
  Future<void> setTheme(bool isDark) async;
}
```

#### 🛣️ AppRoutes
```dart
// Gestión de rutas
class AppRoutes {
  // Rutas disponibles
  static const String login = '/login';
  static const String register = '/register';
  static const String events = '/events';
  static const String matching = '/matching';
  static const String chats = '/chats';
  static const String profile = '/profile';
  
  // Generador de rutas
  static Route<dynamic> generateRoute(RouteSettings settings);
}
```

---

## 📊 Modelos de Datos

### 👤 User Model
```dart
class User {
  final String id;
  final String email;
  final List<String>? top3canciones;
  final String? tragoFavorito;
  final List<String> photoUrls;

  // Constructor
  const User({
    required this.id,
    required this.email,
    this.top3canciones,
    this.tragoFavorito,
    required this.photoUrls,
  });

  // Conversión desde JSON
  factory User.fromJson(Map<String, dynamic> json);
  
  // Conversión a JSON
  Map<String, dynamic> toJson();
}
```

### 📅 Event Model
```dart
class Event {
  final String id;
  final String title;
  final String subtitle;
  final DateTime date;
  final String imageUrl;
  final int attendeesCount;
  final String description;
  final String type;
  final List<String> attendees;

  // Constructor
  const Event({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.date,
    required this.imageUrl,
    required this.attendeesCount,
    required this.description,
    required this.type,
    required this.attendees,
  });

  // Conversión desde Firestore
  factory Event.fromFirestore(DocumentSnapshot doc);
  
  // Conversión a JSON
  Map<String, dynamic> toJson();
}
```

---

## 🖥️ Pantallas y Widgets

### 🔐 Autenticación

#### LoginScreen
```dart
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}
```
**Funcionalidad:** Pantalla de inicio de sesión con Firebase Auth.

#### RegisterScreen
```dart
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}
```
**Funcionalidad:** Pantalla de registro de nuevos usuarios.

#### CompleteProfileScreen
```dart
class CompleteProfileScreen extends StatefulWidget {
  const CompleteProfileScreen({super.key});
  
  @override
  State<CompleteProfileScreen> createState() => _CompleteProfileScreenState();
}
```
**Funcionalidad:** Completar información del perfil después del registro.

### 💕 Matching

#### MatchingScreen
```dart
class MatchingScreen extends StatefulWidget {
  const MatchingScreen({super.key});
  
  @override
  State<MatchingScreen> createState() => _MatchingScreenState();
}
```
**Funcionalidad:** Pantalla principal de matching con sistema de swipe.

#### MatchingIgScreen
```dart
class MatchingIgScreen extends StatefulWidget {
  const MatchingIgScreen({super.key});
  
  @override
  State<MatchingIgScreen> createState() => _MatchingIgScreenState();
}
```
**Funcionalidad:** Pantalla de matching con estilo Instagram.

### 💬 Chat

#### ChatsScreen
```dart
class ChatsScreen extends StatefulWidget {
  const ChatsScreen({super.key});
  
  @override
  State<ChatsScreen> createState() => _ChatsScreenState();
}
```
**Funcionalidad:** Lista de conversaciones activas.

#### ChatScreen
```dart
class ChatScreen extends StatefulWidget {
  final String matchId;
  final String personName;
  final String personPhotoUrl;
  
  const ChatScreen({
    super.key,
    required this.matchId,
    required this.personName,
    required this.personPhotoUrl,
  });
}
```
**Funcionalidad:** Pantalla de chat individual con mensajes en tiempo real.

### 📅 Eventos

#### EventsScreen
```dart
class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key});
  
  @override
  State<EventsScreen> createState() => _EventsScreenState();
}
```
**Funcionalidad:** Lista de eventos disponibles.

### 👤 Perfil

#### ProfileScreen
```dart
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}
```
**Funcionalidad:** Perfil principal del usuario.

#### EditProfileScreen
```dart
class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});
  
  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}
```
**Funcionalidad:** Edición de información del perfil.

### 🎨 Widgets Reutilizables

#### ProfileCard
```dart
class ProfileCard extends StatelessWidget {
  final String name;
  final String age;
  final List<String> photos;
  final String bio;
  final VoidCallback onLike;
  final VoidCallback onDislike;
  
  const ProfileCard({
    super.key,
    required this.name,
    required this.age,
    required this.photos,
    required this.bio,
    required this.onLike,
    required this.onDislike,
  });
}
```

#### MatchPopup
```dart
class MatchPopup extends StatelessWidget {
  final String currentUserPhoto;
  final String matchedUserPhoto;
  final String matchedUserName;
  final VoidCallback onMessagePressed;
  
  const MatchPopup({
    super.key,
    required this.currentUserPhoto,
    required this.matchedUserPhoto,
    required this.matchedUserName,
    required this.onMessagePressed,
  });
}
```

#### ImageCarousel
```dart
class ImageCarousel extends StatefulWidget {
  final List<String> images;
  
  const ImageCarousel({
    super.key,
    required this.images,
  });
}
```

---

## 🛠️ Utilidades y Helpers

### MatchHelper
```dart
Future<bool> handleLikeAndMatch({
  required String currentUserId,
  required String likedUserId,
  required String eventId,
  required BuildContext context,
  required String currentUserPhoto,
  required String matchedUserPhoto,
  required String matchedUserName,
}) async
```
**Funcionalidad:** Maneja la lógica de dar like y crear matches.

### MatchingProfilesController
```dart
class MatchingProfilesController extends ChangeNotifier {
  List<dynamic> get profiles => _profiles;
  bool get isLoading => _isLoading;
  
  Future<void> loadProfiles(String eventId);
  void likeProfile(String profileId);
  void dislikeProfile(String profileId);
}
```

---

## ⚙️ Configuración y Dependencias

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

### Configuración Firebase
```json
{
  "firestore": {
    "rules": "firestore.rules",
    "indexes": "firestore.indexes.json"
  },
  "storage": {
    "rules": "storage.rules"
  }
}
```

---

## 📖 Guías de Uso

### 🚀 Iniciar el Proyecto

1. **Clonar el repositorio:**
```bash
git clone [url-del-repositorio]
cd juvuit_flutter
```

2. **Instalar dependencias:**
```bash
flutter pub get
```

3. **Configurar Firebase:**
   - Crear proyecto en Firebase Console
   - Descargar `google-services.json` (Android) y `GoogleService-Info.plist` (iOS)
   - Colocar en las carpetas correspondientes

4. **Ejecutar la aplicación:**
```bash
flutter run
```

### 🔧 Configuración de Desarrollo

#### Variables de Entorno
```dart
// Configurar en lib/firebase_options.dart
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    // Configuración específica por plataforma
  }
}
```

#### Temas de la Aplicación
```dart
// Configurar en lib/core/utils/app_themes.dart
class AppThemes {
  static ThemeData get lightTheme {
    // Tema claro
  }
  
  static ThemeData get darkTheme {
    // Tema oscuro
  }
}
```

### 📱 Navegación

#### Navegar entre pantallas:
```dart
// Navegación simple
Navigator.pushNamed(context, AppRoutes.profile);

// Navegación con argumentos
Navigator.pushNamed(
  context, 
  AppRoutes.chat,
  arguments: {
    'matchId': matchId,
    'personName': personName,
    'personPhotoUrl': personPhotoUrl,
  },
);
```

### 🔐 Autenticación

#### Flujo de autenticación:
1. **Splash Screen** → Pantalla de carga inicial
2. **Onboarding** → Tutorial para nuevos usuarios
3. **Login/Register** → Autenticación
4. **Complete Profile** → Completar información
5. **Main App** → Aplicación principal

### 💕 Sistema de Matching

#### Flujo de matching:
1. **Seleccionar Evento** → Elegir evento para matching
2. **Ver Perfiles** → Swipe de perfiles disponibles
3. **Dar Like/Dislike** → Interactuar con perfiles
4. **Match Exitoso** → Popup de match
5. **Iniciar Chat** → Comenzar conversación

### 💬 Sistema de Chat

#### Funcionalidades del chat:
- Mensajes en tiempo real
- Indicador de escritura
- Notificaciones push
- Historial de conversaciones

### 📅 Gestión de Eventos

#### Funcionalidades de eventos:
- Lista de eventos disponibles
- Información detallada
- Contador de asistentes
- Registro en eventos

### 👤 Gestión de Perfiles

#### Funcionalidades de perfil:
- Información personal
- Fotos de perfil
- Preferencias de matching
- Configuraciones de privacidad

---

## 🐛 Debugging y Testing

### Pantallas de Debug
- `DebugScreenSpotify` → Debug de integración Spotify
- `DebugScreenRestartUsers` → Reiniciar usuarios
- `DebugScreenDelete` → Eliminar datos
- `DebugScreenHome` → Debug de pantalla principal
- `DebugScreenInfomap` → Debug de mapa
- `DebugScreenPremium` → Debug de funcionalidades premium

### Logs y Monitoreo
```dart
// Ejemplo de logging
print("Se dio like correctamente");
print("Match creado: $matchId");
```

---

## 📞 Soporte y Contacto

Para soporte técnico o preguntas sobre la implementación:

1. **Issues de GitHub** → Reportar bugs o solicitar features
2. **Documentación** → Consultar esta documentación
3. **Código fuente** → Revisar implementaciones en el código

---

## 📄 Licencia

Este proyecto está bajo la licencia especificada en el archivo LICENSE del repositorio.

---

*Documentación generada automáticamente para WIT Ü Flutter App*
*Última actualización: Julio 2024*