# WIT Ü Flutter App - Comprehensive Documentation

## Table of Contents
1. [Project Overview](#project-overview)
2. [Project Structure](#project-structure)
3. [Core APIs and Services](#core-apis-and-services)
4. [Authentication System](#authentication-system)
5. [UI Components and Widgets](#ui-components-and-widgets)
6. [Navigation and Routing](#navigation-and-routing)
7. [Theme System](#theme-system)
8. [Feature Modules](#feature-modules)
9. [External Services Integration](#external-services-integration)
10. [Usage Examples](#usage-examples)

## Project Overview

WIT Ü is a Flutter-based social networking application focused on event-based matching and user interactions. The app features authentication, profile management, event discovery, matching algorithms, chat functionality, and theme customization.

### Key Features
- **Authentication**: Firebase-based user authentication with email/password
- **Profile Management**: Complete user profile creation and editing
- **Event Discovery**: Browse and interact with events
- **Matching System**: Swipe-based matching interface
- **Chat System**: Real-time messaging between matched users
- **Theme Support**: Light and dark theme with dynamic switching
- **Spotify Integration**: Music preferences and song search

## Project Structure

```
juvuit_flutter/
├── lib/
│   ├── core/
│   │   ├── services/
│   │   │   ├── firebase_helpers.dart
│   │   │   ├── spotify_service.dart
│   │   │   └── theme_provider.dart
│   │   ├── utils/
│   │   │   ├── app_themes.dart
│   │   │   ├── colors.dart
│   │   │   └── routes.dart
│   │   └── widgets/
│   │       ├── app_logo_header.dart
│   │       ├── custom_bottom_nav_bar.dart
│   │       ├── email_input_field.dart
│   │       ├── password_input_field.dart
│   │       ├── social_login_button.dart
│   │       ├── theme_aware_logo.dart
│   │       └── theme_toggle_button.dart
│   ├── features/
│   │   ├── auth/
│   │   │   ├── domain/
│   │   │   └── presentation/
│   │   │       ├── screens/
│   │   │       │   ├── complete_profile_screen.dart
│   │   │       │   ├── login_screen.dart
│   │   │       │   ├── register_screen.dart
│   │   │       │   └── splash_screen.dart
│   │   │       └── widgets/
│   │   ├── chats/
│   │   │   └── presentation/
│   │   │       └── screens/
│   │   │           ├── chat_screen.dart
│   │   │           └── chats_screen.dart
│   │   ├── events/
│   │   │   └── presentation/
│   │   │       └── screens/
│   │   │           └── events_screen.dart
│   │   ├── likes_received/
│   │   │   └── presentation/
│   │   │       └── screens/
│   │   │           └── likes_received_screen.dart
│   │   ├── matching/
│   │   │   ├── controllers/
│   │   │   ├── data/
│   │   │   ├── domain/
│   │   │   ├── presentation/
│   │   │   │   └── screens/
│   │   │   │       ├── match_animation_screen.dart
│   │   │   │       ├── matching_ig_screen.dart
│   │   │   │       ├── matching_screen.dart
│   │   │   │       └── matchingprofilescreen.dart
│   │   │   └── widgets/
│   │   │       └── matching_loader.dart
│   │   ├── onboarding/
│   │   │   └── presentation/
│   │   │       └── screens/
│   │   │           └── intro_slides_screen.dart
│   │   ├── profile/
│   │   │   ├── data/
│   │   │   ├── domain/
│   │   │   └── presentation/
│   │   │       └── screens/
│   │   │           ├── edit_profile_screen.dart
│   │   │           ├── emergency_contact_screen.dart
│   │   │           ├── feedback_screen.dart
│   │   │           ├── help_center_screen.dart
│   │   │           ├── matching_preferences_screen.dart
│   │   │           ├── profile_screen.dart
│   │   │           └── public_profile_screen.dart
│   │   ├── profiles/
│   │   │   └── presentation/
│   │   │       └── screens/
│   │   │           └── profiles_screen.dart
│   │   ├── settings/
│   │   ├── testing/
│   │   │   └── screens/
│   │   │       ├── debug_screen_delete.dart
│   │   │       ├── debug_screen_home.dart
│   │   │       ├── debug_screen_infomap.dart
│   │   │       ├── debug_screen_premium.dart
│   │   │       └── debug_screen_spotify.dart
│   │   ├── upload_imag/
│   │   └── user_actions/
│   ├── firebase_options.dart
│   └── main.dart
├── assets/
│   └── images/
│       ├── homescreen/
│       │   ├── witu_logo_dark.png
│       │   ├── logo_witu.png
│       │   ├── witu_logo_light.png
│       │   ├── home.png
│       │   ├── degrade-19.png
│       │   └── degrade-20.png
│       └── placeholder.jpg
├── android/
├── ios/
├── web/
├── windows/
├── linux/
├── macos/
├── test/
├── pubspec.yaml
├── pubspec.lock
└── README.md
```

## Core APIs and Services

### ThemeProvider
**Location**: `lib/core/services/theme_provider.dart`

A state management service for handling theme preferences using Provider pattern.

#### Public API

```dart
class ThemeProvider extends ChangeNotifier {
  // Properties
  bool get isDarkMode;
  ThemeColors get currentTheme;
  
  // Methods
  Future<void> toggleTheme();
  Future<void> setTheme(bool isDark);
}
```

#### Usage Example
```dart
// Access theme provider
final themeProvider = Provider.of<ThemeProvider>(context, listen: false);

// Toggle theme
await themeProvider.toggleTheme();

// Set specific theme
await themeProvider.setTheme(true); // Dark mode
await themeProvider.setTheme(false); // Light mode

// Check current theme
if (themeProvider.isDarkMode) {
  // Dark mode is active
}
```

### SpotifyService
**Location**: `lib/core/services/spotify_service.dart`

Service for integrating with Spotify API to search for songs and manage music preferences.

#### Public API

```dart
class SpotifyService {
  // Methods
  static Future<List<Map<String, String>>> searchSongs(String query);
  static void resetToken();
}
```

#### Usage Example
```dart
// Search for songs
try {
  final songs = await SpotifyService.searchSongs('Bohemian Rhapsody');
  for (final song in songs) {
    print('${song['title']} by ${song['artist']}');
  }
} catch (e) {
  print('Error searching songs: $e');
}

// Reset token if needed
SpotifyService.resetToken();
```

### Firebase Helpers
**Location**: `lib/core/services/firebase_helpers.dart`

Utility functions for Firebase operations.

## Authentication System

### LoginScreen
**Location**: `lib/features/auth/presentation/screens/login_screen.dart`

Handles user authentication with Firebase Auth.

#### Features
- Email and password authentication
- Error handling for invalid credentials
- Loading states
- Navigation to registration
- Social login integration

#### Usage
```dart
// Navigate to login screen
Navigator.pushNamed(context, AppRoutes.login);
```

### RegisterScreen
**Location**: `lib/features/auth/presentation/screens/register_screen.dart`

User registration with email and password.

### CompleteProfileScreen
**Location**: `lib/features/auth/presentation/screens/complete_profile_screen.dart`

Profile completion after registration.

## UI Components and Widgets

### CustomBottomNavBar
**Location**: `lib/core/widgets/custom_bottom_nav_bar.dart`

Custom bottom navigation bar with 5 main sections.

#### Properties
- `currentIndex`: Current selected tab index

#### Navigation Items
1. Events (index 0)
2. Matching (index 1)
3. Likes Received (index 2)
4. Chats (index 3)
5. Profile (index 4)

#### Usage Example
```dart
CustomBottomNavBar(
  currentIndex: 0,
)
```

### PasswordInputField
**Location**: `lib/core/widgets/password_input_field.dart`

Reusable password input field with show/hide functionality.

#### Properties
- `controller`: TextEditingController for the field
- `labelText`: Label text for the field
- `onChanged`: Callback for text changes

#### Usage Example
```dart
PasswordInputField(
  controller: _passwordController,
  labelText: 'Contraseña',
  onChanged: (value) {
    // Handle password change
  },
)
```

### EmailInputField
**Location**: `lib/core/widgets/email_input_field.dart`

Reusable email input field with validation.

### SocialLoginButton
**Location**: `lib/core/widgets/social_login_button.dart`

Button for social media login integration.

### ThemeToggleButton
**Location**: `lib/core/widgets/theme_toggle_button.dart`

Button to toggle between light and dark themes.

### ThemeAwareLogo
**Location**: `lib/core/widgets/theme_aware_logo.dart`

Logo component that adapts to current theme.

## Navigation and Routing

### AppRoutes
**Location**: `lib/core/utils/routes.dart`

Centralized routing system for the application.

#### Available Routes
```dart
class AppRoutes {
  static const String login = '/login';
  static const String register = '/register';
  static const String events = '/events';
  static const String matching = '/matching';
  static const String chats = '/chats';
  static const String chat = '/chat';
  static const String profile = '/profile';
  static const String profiles = '/profiles';
  static const String editProfile = '/edit-profile';
  static const String userProfile = '/user-profile';
  static const String splash = '/splash';
  static const String onboarding = '/onboarding';
  static const String matchingPreferences = '/matching-preferences';
  static const String emergencyContact = '/emergency-contact';
  static const String helpCenter = '/help-center';
  static const String feedback = '/feedback';
}
```

#### Usage Example
```dart
// Navigate to a route
Navigator.pushNamed(context, AppRoutes.profile);

// Navigate with arguments
Navigator.pushNamed(
  context, 
  AppRoutes.chat,
  arguments: {
    'matchId': 'match123',
    'personName': 'John Doe',
    'personPhotoUrl': 'https://example.com/photo.jpg',
  },
);
```

## Theme System

### AppThemes
**Location**: `lib/core/utils/app_themes.dart`

Defines light and dark themes for the application.

#### Features
- Material 3 design system
- Custom color schemes
- Consistent component styling
- Dark and light mode support

### ThemeColors
**Location**: `lib/core/utils/colors.dart`

Color definitions for both light and dark themes.

#### Usage Example
```dart
// Access theme colors
final colors = ThemeColors.light; // or ThemeColors.dark
final primaryColor = colors.primary;
final backgroundColor = colors.background;
```

## Feature Modules

### Authentication Module
**Location**: `lib/features/auth/`

Handles user authentication, registration, and profile completion.

#### Screens
- `LoginScreen`: User login
- `RegisterScreen`: User registration
- `CompleteProfileScreen`: Profile setup
- `SplashScreen`: App initialization

### Profile Module
**Location**: `lib/features/profile/`

User profile management and settings.

#### Screens
- `ProfileScreen`: Main profile view
- `EditProfileScreen`: Profile editing
- `PublicProfileScreen`: Public profile view
- `MatchingPreferencesScreen`: Matching settings
- `EmergencyContactScreen`: Emergency contact setup
- `HelpCenterScreen`: Help and support
- `FeedbackScreen`: User feedback

### Matching Module
**Location**: `lib/features/matching/`

User matching and discovery functionality.

#### Screens
- `MatchingScreen`: Main matching interface
- `MatchingIgScreen`: Instagram-style matching
- `MatchAnimationScreen`: Match celebration
- `MatchingProfileScreen`: Profile viewing during matching

### Events Module
**Location**: `lib/features/events/`

Event discovery and management.

#### Screens
- `EventsScreen`: Event browsing and discovery

### Chats Module
**Location**: `lib/features/chats/`

Real-time messaging between matched users.

#### Screens
- `ChatsScreen`: Chat list
- `ChatScreen`: Individual chat conversation

### Onboarding Module
**Location**: `lib/features/onboarding/`

User onboarding and tutorial.

#### Screens
- `IntroSlidesScreen`: Introduction slides

## External Services Integration

### Firebase Integration
The app uses Firebase for:
- Authentication (Firebase Auth)
- Database (Cloud Firestore)
- Storage (Firebase Storage)
- Messaging (Firebase Messaging)

### Spotify Integration
- Song search functionality
- Music preference management
- Artist and album information

## Usage Examples

### Setting up the App
```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}
```

### Theme Management
```dart
// In your widget
Consumer<ThemeProvider>(
  builder: (context, themeProvider, child) {
    return MaterialApp(
      theme: AppThemes.lightTheme,
      darkTheme: AppThemes.darkTheme,
      themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
    );
  },
)
```

### Navigation with Bottom Bar
```dart
Scaffold(
  body: YourScreen(),
  bottomNavigationBar: CustomBottomNavBar(
    currentIndex: 0,
  ),
)
```

### Authentication Flow
```dart
// Login
await FirebaseAuth.instance.signInWithEmailAndPassword(
  email: email,
  password: password,
);

// Navigate to main app
Navigator.pushAndRemoveUntil(
  context,
  MaterialPageRoute(builder: (context) => const EventsScreen()),
  (route) => false,
);
```

### Spotify Integration
```dart
// Search for songs
final songs = await SpotifyService.searchSongs('search query');
for (final song in songs) {
  print('${song['title']} by ${song['artist']}');
}
```

## Dependencies

### Core Dependencies
- `flutter`: Flutter SDK
- `firebase_core`: Firebase initialization
- `firebase_auth`: Authentication
- `cloud_firestore`: Database
- `provider`: State management
- `shared_preferences`: Local storage

### UI Dependencies
- `font_awesome_flutter`: Icons
- `flutter_card_swiper`: Card swiping
- `carousel_slider`: Image carousels
- `cached_network_image`: Image caching

### Utility Dependencies
- `dio`: HTTP client
- `http`: HTTP requests
- `intl`: Internationalization
- `uuid`: Unique identifiers
- `image_picker`: Image selection
- `flutter_image_compress`: Image compression

## Development Guidelines

### Code Organization
- Follow feature-based architecture
- Separate presentation, domain, and data layers
- Use consistent naming conventions
- Implement proper error handling

### State Management
- Use Provider for theme management
- Implement proper loading states
- Handle authentication state globally

### UI/UX Guidelines
- Support both light and dark themes
- Use Material 3 design principles
- Implement proper loading indicators
- Provide user feedback for actions

### Testing
- Write unit tests for services
- Implement widget tests for UI components
- Test authentication flows
- Verify theme switching functionality