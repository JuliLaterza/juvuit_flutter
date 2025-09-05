# WIT Ü Flutter App - API Documentation

## Table of Contents
1. [Core Services APIs](#core-services-apis)
2. [Authentication APIs](#authentication-apis)
3. [UI Component APIs](#ui-component-apis)
4. [Navigation APIs](#navigation-apis)
5. [Theme System APIs](#theme-system-apis)
6. [External Service APIs](#external-service-apis)
7. [Utility Functions](#utility-functions)

## Core Services APIs

### ThemeProvider
**File**: `lib/core/services/theme_provider.dart`

State management service for theme preferences using Provider pattern.

#### Class Definition
```dart
class ThemeProvider extends ChangeNotifier
```

#### Properties
| Property | Type | Description |
|----------|------|-------------|
| `isDarkMode` | `bool` | Returns true if dark mode is active |
| `currentTheme` | `ThemeColors` | Returns current theme colors |

#### Methods

##### `toggleTheme()`
Toggles between light and dark themes.

**Signature**: `Future<void> toggleTheme()`

**Returns**: `Future<void>`

**Example**:
```dart
final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
await themeProvider.toggleTheme();
```

##### `setTheme(bool isDark)`
Sets the theme to a specific mode.

**Signature**: `Future<void> setTheme(bool isDark)`

**Parameters**:
- `isDark` (bool): true for dark mode, false for light mode

**Returns**: `Future<void>`

**Example**:
```dart
final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
await themeProvider.setTheme(true); // Enable dark mode
await themeProvider.setTheme(false); // Enable light mode
```

#### Usage in Widgets
```dart
// Listen to theme changes
Consumer<ThemeProvider>(
  builder: (context, themeProvider, child) {
    return Container(
      color: themeProvider.currentTheme.background,
      child: Text(
        'Current theme: ${themeProvider.isDarkMode ? "Dark" : "Light"}',
      ),
    );
  },
)

// Access without listening
final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
```

### SpotifyService
**File**: `lib/core/services/spotify_service.dart`

Service for Spotify API integration and song search functionality.

#### Class Definition
```dart
class SpotifyService
```

#### Methods

##### `searchSongs(String query)`
Searches for songs on Spotify.

**Signature**: `static Future<List<Map<String, String>>> searchSongs(String query)`

**Parameters**:
- `query` (String): Search term for songs

**Returns**: `Future<List<Map<String, String>>>` - List of songs with title, artist, and imageUrl

**Throws**: `Exception` when API request fails

**Example**:
```dart
try {
  final songs = await SpotifyService.searchSongs('Bohemian Rhapsody');
  for (final song in songs) {
    print('${song['title']} by ${song['artist']}');
    print('Image: ${song['imageUrl']}');
  }
} catch (e) {
  print('Error searching songs: $e');
}
```

**Response Format**:
```dart
[
  {
    'title': 'Bohemian Rhapsody',
    'artist': 'Queen',
    'imageUrl': 'https://example.com/album-cover.jpg'
  },
  // ... more songs
]
```

##### `resetToken()`
Resets the Spotify access token.

**Signature**: `static void resetToken()`

**Returns**: `void`

**Example**:
```dart
SpotifyService.resetToken(); // Clear cached token
```

## Authentication APIs

### LoginScreen
**File**: `lib/features/auth/presentation/screens/login_screen.dart`

Handles user authentication with Firebase Auth.

#### Class Definition
```dart
class LoginScreen extends StatefulWidget
```

#### Properties
| Property | Type | Description |
|----------|------|-------------|
| `key` | `Key?` | Widget key |

#### Methods

##### `createState()`
Creates the state for the login screen.

**Signature**: `State<LoginScreen> createState()`

**Returns**: `_LoginScreenState`

#### State Class: `_LoginScreenState`

##### Properties
| Property | Type | Description |
|----------|------|-------------|
| `_emailController` | `TextEditingController` | Email input controller |
| `_passwordController` | `TextEditingController` | Password input controller |
| `_isLoading` | `bool` | Loading state indicator |

##### Methods

###### `_login()`
Performs user authentication.

**Signature**: `Future<void> _login()`

**Returns**: `Future<void>`

**Authentication Flow**:
1. Validates input fields
2. Shows loading state
3. Attempts Firebase authentication
4. Handles success/error states
5. Navigates to main app on success

**Example Usage**:
```dart
// Navigate to login screen
Navigator.pushNamed(context, AppRoutes.login);

// The screen handles authentication automatically
// On success, navigates to EventsScreen
// On error, shows error message
```

###### `_showMessage(String message)`
Displays a snackbar message.

**Signature**: `void _showMessage(String message)`

**Parameters**:
- `message` (String): Message to display

**Returns**: `void`

### RegisterScreen
**File**: `lib/features/auth/presentation/screens/register_screen.dart`

Handles user registration with Firebase Auth.

#### Class Definition
```dart
class RegisterScreen extends StatefulWidget
```

#### Registration Flow
1. Email and password validation
2. Firebase user creation
3. Profile completion navigation
4. Error handling

### CompleteProfileScreen
**File**: `lib/features/auth/presentation/screens/complete_profile_screen.dart`

Profile completion after registration.

#### Features
- Profile information collection
- Photo upload
- Preferences setup
- Emergency contact setup

## UI Component APIs

### CustomBottomNavBar
**File**: `lib/core/widgets/custom_bottom_nav_bar.dart`

Custom bottom navigation bar with 5 main sections.

#### Class Definition
```dart
class CustomBottomNavBar extends StatelessWidget
```

#### Properties
| Property | Type | Required | Description |
|----------|------|----------|-------------|
| `currentIndex` | `int` | Yes | Current selected tab index |
| `key` | `Key?` | No | Widget key |

#### Navigation Items
| Index | Icon | Label | Screen |
|-------|------|-------|--------|
| 0 | `Icons.event` | 'Eventos' | `EventsScreen` |
| 1 | `Icons.connect_without_contact` | 'Anotados' | `MatchingScreen` |
| 2 | `Icons.thumb_up` | 'Likes recibidos' | `LikesReceivedScreen` |
| 3 | `Icons.chat` | 'Chats' | `ChatsScreen` |
| 4 | `Icons.person` | 'Perfil' | `ProfileScreen` |

#### Methods

##### `_onItemTapped(BuildContext context, int index)`
Handles navigation when a tab is tapped.

**Signature**: `void _onItemTapped(BuildContext context, int index)`

**Parameters**:
- `context` (BuildContext): Build context
- `index` (int): Tab index

**Returns**: `void`

#### Usage Example
```dart
Scaffold(
  body: YourScreen(),
  bottomNavigationBar: CustomBottomNavBar(
    currentIndex: 0, // Events tab selected
  ),
)
```

### PasswordInputField
**File**: `lib/core/widgets/password_input_field.dart`

Reusable password input field with show/hide functionality.

#### Class Definition
```dart
class PasswordInputField extends StatefulWidget
```

#### Properties
| Property | Type | Required | Description |
|----------|------|----------|-------------|
| `controller` | `TextEditingController` | Yes | Text controller |
| `labelText` | `String` | No | Label text (default: 'Contraseña') |
| `onChanged` | `Function(String)?` | No | Text change callback |
| `key` | `Key?` | No | Widget key |

#### Features
- Password visibility toggle
- Theme-aware styling
- Validation support
- Customizable label

#### Usage Example
```dart
PasswordInputField(
  controller: _passwordController,
  labelText: 'Enter Password',
  onChanged: (value) {
    // Handle password change
    print('Password: $value');
  },
)
```

### EmailInputField
**File**: `lib/core/widgets/email_input_field.dart`

Reusable email input field with validation.

#### Class Definition
```dart
class EmailInputField extends StatelessWidget
```

#### Properties
| Property | Type | Required | Description |
|----------|------|----------|-------------|
| `controller` | `TextEditingController` | Yes | Text controller |
| `labelText` | `String` | No | Label text (default: 'Correo electrónico') |
| `onChanged` | `Function(String)?` | No | Text change callback |
| `key` | `Key?` | No | Widget key |

#### Features
- Email validation
- Theme-aware styling
- Customizable label
- Error state handling

### SocialLoginButton
**File**: `lib/core/widgets/social_login_button.dart`

Button for social media login integration.

#### Class Definition
```dart
class SocialLoginButton extends StatelessWidget
```

#### Properties
| Property | Type | Required | Description |
|----------|------|----------|-------------|
| `onPressed` | `VoidCallback` | Yes | Button press callback |
| `icon` | `IconData` | Yes | Social media icon |
| `label` | `String` | Yes | Button label |
| `backgroundColor` | `Color` | No | Button background color |
| `key` | `Key?` | No | Widget key |

#### Usage Example
```dart
SocialLoginButton(
  onPressed: () {
    // Handle Google login
  },
  icon: FontAwesomeIcons.google,
  label: 'Continuar con Google',
  backgroundColor: Colors.red,
)
```

### ThemeToggleButton
**File**: `lib/core/widgets/theme_toggle_button.dart`

Button to toggle between light and dark themes.

#### Class Definition
```dart
class ThemeToggleButton extends StatelessWidget
```

#### Properties
| Property | Type | Required | Description |
|----------|------|----------|-------------|
| `key` | `Key?` | No | Widget key |

#### Features
- Automatic theme detection
- Animated icon transition
- Provider integration
- Persistent theme storage

#### Usage Example
```dart
// In AppBar actions
AppBar(
  actions: [
    ThemeToggleButton(),
  ],
)
```

### ThemeAwareLogo
**File**: `lib/core/widgets/theme_aware_logo.dart`

Logo component that adapts to current theme.

#### Class Definition
```dart
class ThemeAwareLogo extends StatelessWidget
```

#### Properties
| Property | Type | Required | Description |
|----------|------|----------|-------------|
| `size` | `double` | No | Logo size (default: 100.0) |
| `key` | `Key?` | No | Widget key |

#### Features
- Automatic theme switching
- Multiple logo variants
- Responsive sizing
- High-quality assets

#### Usage Example
```dart
ThemeAwareLogo(
  size: 150.0,
)
```

## Navigation APIs

### AppRoutes
**File**: `lib/core/utils/routes.dart`

Centralized routing system for the application.

#### Class Definition
```dart
class AppRoutes
```

#### Route Constants
| Constant | Value | Description |
|----------|-------|-------------|
| `login` | '/login' | Login screen |
| `register` | '/register' | Registration screen |
| `events` | '/events' | Events screen |
| `matching` | '/matching' | Matching screen |
| `chats` | '/chats' | Chats list screen |
| `chat` | '/chat' | Individual chat screen |
| `profile` | '/profile' | User profile screen |
| `profiles` | '/profiles' | Profiles discovery screen |
| `editProfile` | '/edit-profile' | Profile editing screen |
| `userProfile` | '/user-profile' | Public user profile |
| `splash` | '/splash' | Splash screen |
| `onboarding` | '/onboarding' | Onboarding screen |
| `matchingPreferences` | '/matching-preferences' | Matching preferences |
| `emergencyContact` | '/emergency-contact' | Emergency contact setup |
| `helpCenter` | '/help-center' | Help center |
| `feedback` | '/feedback' | Feedback screen |

#### Methods

##### `generateRoute(RouteSettings settings)`
Generates routes based on route settings.

**Signature**: `static Route<dynamic> generateRoute(RouteSettings settings)`

**Parameters**:
- `settings` (RouteSettings): Route settings with name and arguments

**Returns**: `Route<dynamic>`

**Route Arguments**:
```dart
// Chat route with arguments
{
  'matchId': 'match123',
  'personName': 'John Doe',
  'personPhotoUrl': 'https://example.com/photo.jpg',
}

// User profile route with arguments
{
  'profile': userProfileObject,
}
```

#### Usage Examples
```dart
// Basic navigation
Navigator.pushNamed(context, AppRoutes.profile);

// Navigation with arguments
Navigator.pushNamed(
  context,
  AppRoutes.chat,
  arguments: {
    'matchId': 'match123',
    'personName': 'John Doe',
    'personPhotoUrl': 'https://example.com/photo.jpg',
  },
);

// Replace all routes
Navigator.pushAndRemoveUntil(
  context,
  MaterialPageRoute(builder: (_) => const EventsScreen()),
  (route) => false,
);
```

## Theme System APIs

### AppThemes
**File**: `lib/core/utils/app_themes.dart`

Defines light and dark themes for the application.

#### Class Definition
```dart
class AppThemes
```

#### Properties
| Property | Type | Description |
|----------|------|-------------|
| `lightTheme` | `ThemeData` | Light theme configuration |
| `darkTheme` | `ThemeData` | Dark theme configuration |

#### Theme Features
- Material 3 design system
- Custom color schemes
- Consistent component styling
- Responsive typography
- Custom input decorations
- Bottom navigation theming

#### Usage Example
```dart
MaterialApp(
  theme: AppThemes.lightTheme,
  darkTheme: AppThemes.darkTheme,
  themeMode: ThemeMode.system, // or .light, .dark
)
```

### ThemeColors
**File**: `lib/core/utils/colors.dart`

Color definitions for both light and dark themes.

#### Class Definition
```dart
class ThemeColors
```

#### Properties
| Property | Type | Description |
|----------|------|-------------|
| `light` | `ColorScheme` | Light theme colors |
| `dark` | `ColorScheme` | Dark theme colors |

#### Color Properties
Each theme includes:
- `background`: App background color
- `surface`: Surface color for cards and inputs
- `primary`: Primary brand color
- `secondary`: Secondary accent color
- `onBackground`: Text color on background
- `onSurface`: Text color on surface
- `onPrimary`: Text color on primary
- `onSecondary`: Text color on secondary
- `error`: Error color
- `onError`: Text color on error

#### Usage Example
```dart
// Access theme colors
final colors = ThemeColors.light; // or ThemeColors.dark
final primaryColor = colors.primary;
final backgroundColor = colors.background;

// In widgets
Container(
  color: ThemeColors.light.primary,
  child: Text(
    'Hello World',
    style: TextStyle(color: ThemeColors.light.onPrimary),
  ),
)
```

## External Service APIs

### Firebase Integration

#### Authentication
```dart
// Sign in
await FirebaseAuth.instance.signInWithEmailAndPassword(
  email: email,
  password: password,
);

// Sign up
await FirebaseAuth.instance.createUserWithEmailAndPassword(
  email: email,
  password: password,
);

// Sign out
await FirebaseAuth.instance.signOut();

// Get current user
final user = FirebaseAuth.instance.currentUser;
```

#### Firestore
```dart
// Get Firestore instance
final firestore = FirebaseFirestore.instance;

// Add document
await firestore.collection('users').add({
  'name': 'John Doe',
  'email': 'john@example.com',
});

// Get document
final doc = await firestore.collection('users').doc('userId').get();

// Update document
await firestore.collection('users').doc('userId').update({
  'name': 'Jane Doe',
});
```

#### Storage
```dart
// Get Storage instance
final storage = FirebaseStorage.instance;

// Upload file
final ref = storage.ref().child('images/profile.jpg');
await ref.putFile(imageFile);

// Get download URL
final url = await ref.getDownloadURL();
```

### Spotify API Integration

#### Search Songs
```dart
try {
  final songs = await SpotifyService.searchSongs('search query');
  for (final song in songs) {
    print('${song['title']} by ${song['artist']}');
    print('Album cover: ${song['imageUrl']}');
  }
} catch (e) {
  print('Error: $e');
}
```

#### Reset Token
```dart
SpotifyService.resetToken(); // Clear cached token
```

## Utility Functions

### Firebase Helpers
**File**: `lib/core/services/firebase_helpers.dart`

Utility functions for Firebase operations.

#### Available Functions
- Firebase initialization helpers
- Error handling utilities
- Common Firebase operations

### Image Processing
```dart
// Image compression
import 'package:flutter_image_compress/flutter_image_compress.dart';

final compressedImage = await FlutterImageCompress.compressWithFile(
  imageFile.path,
  quality: 70,
);
```

### Local Storage
```dart
// SharedPreferences
import 'package:shared_preferences/shared_preferences.dart';

final prefs = await SharedPreferences.getInstance();
await prefs.setString('key', 'value');
final value = prefs.getString('key');
```

### HTTP Requests
```dart
// Dio HTTP client
import 'package:dio/dio.dart';

final dio = Dio();
final response = await dio.get('https://api.example.com/data');
```

## Error Handling

### Authentication Errors
```dart
try {
  await FirebaseAuth.instance.signInWithEmailAndPassword(
    email: email,
    password: password,
  );
} on FirebaseAuthException catch (e) {
  switch (e.code) {
    case 'user-not-found':
      // Handle user not found
      break;
    case 'wrong-password':
      // Handle wrong password
      break;
    case 'invalid-email':
      // Handle invalid email
      break;
    default:
      // Handle other errors
      break;
  }
}
```

### Network Errors
```dart
try {
  final songs = await SpotifyService.searchSongs('query');
} catch (e) {
  if (e.toString().contains('network')) {
    // Handle network error
  } else {
    // Handle other errors
  }
}
```

## Best Practices

### State Management
- Use Provider for theme management
- Implement proper loading states
- Handle authentication state globally
- Use appropriate widget lifecycle methods

### Error Handling
- Always wrap async operations in try-catch
- Provide meaningful error messages
- Implement fallback UI for errors
- Log errors for debugging

### Performance
- Use const constructors where possible
- Implement proper image caching
- Optimize widget rebuilds
- Use appropriate list widgets

### Security
- Never expose API keys in client code
- Validate user input
- Implement proper authentication flows
- Use secure storage for sensitive data