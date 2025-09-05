# WIT Ü Flutter App - Widget Documentation

## Table of Contents
1. [Core Widgets](#core-widgets)
2. [Authentication Widgets](#authentication-widgets)
3. [Navigation Widgets](#navigation-widgets)
4. [Input Widgets](#input-widgets)
5. [Theme Widgets](#theme-widgets)
6. [Feature-Specific Widgets](#feature-specific-widgets)
7. [Custom Widgets](#custom-widgets)
8. [Widget Best Practices](#widget-best-practices)

## Core Widgets

### CustomBottomNavBar
**File**: `lib/core/widgets/custom_bottom_nav_bar.dart`

A custom bottom navigation bar with 5 main sections for the app's primary navigation.

#### Widget Properties
| Property | Type | Required | Default | Description |
|----------|------|----------|---------|-------------|
| `currentIndex` | `int` | Yes | - | Current selected tab index |
| `key` | `Key?` | No | null | Widget key |

#### Navigation Structure
| Index | Icon | Label | Destination Screen |
|-------|------|-------|-------------------|
| 0 | `Icons.event` | 'Eventos' | `EventsScreen` |
| 1 | `Icons.connect_without_contact` | 'Anotados' | `MatchingScreen` |
| 2 | `Icons.thumb_up` | 'Likes recibidos' | `LikesReceivedScreen` |
| 3 | `Icons.chat` | 'Chats' | `ChatsScreen` |
| 4 | `Icons.person` | 'Perfil' | `ProfileScreen` |

#### Features
- **Theme Integration**: Automatically adapts to current theme
- **Smooth Navigation**: Uses `PageRouteBuilder` for seamless transitions
- **State Management**: Prevents navigation to current screen
- **Custom Styling**: Consistent with app design system

#### Usage Example
```dart
class MainScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: EventsScreen(), // Current screen content
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: 0, // Events tab is selected
      ),
    );
  }
}
```

#### Implementation Details
```dart
class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
  });

  void _onItemTapped(BuildContext context, int index) {
    if (index == currentIndex) return; // Prevent same screen navigation

    Widget nextScreen;
    switch (index) {
      case 0:
        nextScreen = const EventsScreen();
        break;
      case 1:
        nextScreen = const MatchingScreen();
        break;
      case 2:
        nextScreen = const LikesReceivedScreen();
        break;
      case 3:
        nextScreen = const ChatsScreen();
        break;
      case 4:
        nextScreen = const ProfileScreen();
        break;
      default:
        return;
    }

    // Navigate and clear stack
    Navigator.pushAndRemoveUntil(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => nextScreen,
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: (index) => _onItemTapped(context, index),
      backgroundColor: theme.bottomNavigationBarTheme.backgroundColor,
      selectedItemColor: theme.bottomNavigationBarTheme.selectedItemColor,
      unselectedItemColor: theme.bottomNavigationBarTheme.unselectedItemColor,
      selectedIconTheme: const IconThemeData(size: 30),
      unselectedIconTheme: const IconThemeData(size: 30),
      showSelectedLabels: false,
      showUnselectedLabels: false,
      type: BottomNavigationBarType.fixed,
      elevation: theme.bottomNavigationBarTheme.elevation ?? 8,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.event),
          label: 'Eventos',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.connect_without_contact),
          label: 'Anotados',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.thumb_up),
          label: 'Likes recibidos',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.chat),
          label: 'Chats',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Perfil',
        ),
      ],
    );
  }
}
```

## Authentication Widgets

### PasswordInputField
**File**: `lib/core/widgets/password_input_field.dart`

A reusable password input field with show/hide functionality and theme integration.

#### Widget Properties
| Property | Type | Required | Default | Description |
|----------|------|----------|---------|-------------|
| `controller` | `TextEditingController` | Yes | - | Text controller for the field |
| `labelText` | `String` | No | 'Contraseña' | Label text for the field |
| `onChanged` | `Function(String)?` | No | null | Callback for text changes |
| `key` | `Key?` | No | null | Widget key |

#### Features
- **Password Visibility Toggle**: Eye icon to show/hide password
- **Theme Integration**: Automatically adapts to light/dark themes
- **Validation Support**: Ready for form validation
- **Customizable Label**: Configurable label text
- **Accessibility**: Proper semantic labels

#### Usage Example
```dart
class LoginForm extends StatefulWidget {
  @override
  _LoginFormState createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        PasswordInputField(
          controller: _passwordController,
          labelText: 'Enter your password',
          onChanged: (value) {
            // Handle password change
            print('Password length: ${value.length}');
          },
        ),
      ],
    );
  }

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }
}
```

#### Implementation Details
```dart
class PasswordInputField extends StatefulWidget {
  final TextEditingController controller;
  final String labelText;
  final Function(String)? onChanged;

  const PasswordInputField({
    super.key,
    required this.controller,
    this.labelText = 'Contraseña',
    this.onChanged,
  });

  @override
  State<PasswordInputField> createState() => _PasswordInputFieldState();
}

class _PasswordInputFieldState extends State<PasswordInputField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return TextField(
      controller: widget.controller,
      obscureText: _obscureText,
      onChanged: widget.onChanged,
      decoration: InputDecoration(
        labelText: widget.labelText,
        labelStyle: TextStyle(color: theme.colorScheme.onSurface),
        prefixIcon: Icon(Icons.lock, color: theme.colorScheme.onSurface),
        suffixIcon: IconButton(
          icon: Icon(
            _obscureText ? Icons.visibility : Icons.visibility_off,
            color: theme.colorScheme.onSurface,
          ),
          onPressed: () {
            setState(() {
              _obscureText = !_obscureText;
            });
          },
        ),
        filled: true,
        fillColor: theme.colorScheme.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: theme.colorScheme.onSurface.withOpacity(0.3),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: theme.colorScheme.onSurface.withOpacity(0.3),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: theme.colorScheme.primary),
        ),
      ),
    );
  }
}
```

### EmailInputField
**File**: `lib/core/widgets/email_input_field.dart`

A reusable email input field with validation and theme integration.

#### Widget Properties
| Property | Type | Required | Default | Description |
|----------|------|----------|---------|-------------|
| `controller` | `TextEditingController` | Yes | - | Text controller for the field |
| `labelText` | `String` | No | 'Correo electrónico' | Label text for the field |
| `onChanged` | `Function(String)?` | No | null | Callback for text changes |
| `key` | `Key?` | No | null | Widget key |

#### Features
- **Email Validation**: Built-in email format validation
- **Theme Integration**: Adapts to current theme
- **Error State Handling**: Visual feedback for invalid input
- **Customizable Label**: Configurable label text
- **Accessibility**: Proper semantic labels

#### Usage Example
```dart
EmailInputField(
  controller: _emailController,
  labelText: 'Email address',
  onChanged: (value) {
    // Handle email change
    setState(() {
      _isEmailValid = _validateEmail(value);
    });
  },
)
```

### SocialLoginButton
**File**: `lib/core/widgets/social_login_button.dart`

A customizable button for social media login integration.

#### Widget Properties
| Property | Type | Required | Default | Description |
|----------|------|----------|---------|-------------|
| `onPressed` | `VoidCallback` | Yes | - | Button press callback |
| `icon` | `IconData` | Yes | - | Social media icon |
| `label` | `String` | Yes | - | Button label text |
| `backgroundColor` | `Color` | No | Theme primary color | Button background color |
| `key` | `Key?` | No | null | Widget key |

#### Usage Example
```dart
SocialLoginButton(
  onPressed: () async {
    // Handle Google login
    try {
      // Google sign-in logic
    } catch (e) {
      print('Google login error: $e');
    }
  },
  icon: FontAwesomeIcons.google,
  label: 'Continue with Google',
  backgroundColor: Colors.red,
)
```

## Navigation Widgets

### AppLogoHeader
**File**: `lib/core/widgets/app_logo_header.dart`

A header component displaying the app logo with consistent styling.

#### Widget Properties
| Property | Type | Required | Default | Description |
|----------|------|----------|---------|-------------|
| `key` | `Key?` | No | null | Widget key |

#### Usage Example
```dart
AppBar(
  title: AppLogoHeader(),
  centerTitle: true,
)
```

## Theme Widgets

### ThemeToggleButton
**File**: `lib/core/widgets/theme_toggle_button.dart`

A button to toggle between light and dark themes with animated icon transition.

#### Widget Properties
| Property | Type | Required | Default | Description |
|----------|------|----------|---------|-------------|
| `key` | `Key?` | No | null | Widget key |

#### Features
- **Automatic Theme Detection**: Shows current theme state
- **Animated Icon Transition**: Smooth icon changes
- **Provider Integration**: Uses ThemeProvider for state management
- **Persistent Storage**: Remembers theme preference
- **Accessibility**: Proper semantic labels

#### Usage Example
```dart
AppBar(
  title: Text('Settings'),
  actions: [
    ThemeToggleButton(),
  ],
)
```

#### Implementation Details
```dart
class ThemeToggleButton extends StatelessWidget {
  const ThemeToggleButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return IconButton(
          icon: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: Icon(
              themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode,
              key: ValueKey(themeProvider.isDarkMode),
            ),
          ),
          onPressed: () async {
            await themeProvider.toggleTheme();
          },
          tooltip: themeProvider.isDarkMode ? 'Switch to light mode' : 'Switch to dark mode',
        );
      },
    );
  }
}
```

### ThemeAwareLogo
**File**: `lib/core/widgets/theme_aware_logo.dart`

A logo component that automatically adapts to the current theme.

#### Widget Properties
| Property | Type | Required | Default | Description |
|----------|------|----------|---------|-------------|
| `size` | `double` | No | 100.0 | Logo size in pixels |
| `key` | `Key?` | No | null | Widget key |

#### Features
- **Automatic Theme Switching**: Shows appropriate logo variant
- **Multiple Logo Variants**: Light and dark theme versions
- **Responsive Sizing**: Configurable size
- **High-Quality Assets**: Optimized image files
- **Smooth Transitions**: Animated theme changes

#### Usage Example
```dart
Column(
  children: [
    ThemeAwareLogo(size: 150.0),
    SizedBox(height: 20),
    Text('Welcome to WIT Ü'),
  ],
)
```

#### Implementation Details
```dart
class ThemeAwareLogo extends StatelessWidget {
  final double size;

  const ThemeAwareLogo({
    super.key,
    this.size = 100.0,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final isDark = themeProvider.isDarkMode;
        final logoAsset = isDark 
            ? 'assets/images/homescreen/witu_logo_dark.png'
            : 'assets/images/homescreen/witu_logo_light.png';
        
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: Image.asset(
            logoAsset,
            key: ValueKey(isDark),
            width: size,
            height: size,
            fit: BoxFit.contain,
          ),
        );
      },
    );
  }
}
```

## Feature-Specific Widgets

### MatchingLoader
**File**: `lib/features/matching/widgets/matching_loader.dart`

A loading component specifically designed for the matching feature.

#### Usage Example
```dart
if (isLoading) {
  return MatchingLoader();
}
```

## Custom Widgets

### LargeLogo
**File**: `lib/core/widgets/theme_aware_logo.dart`

A larger version of the theme-aware logo used in authentication screens.

#### Usage Example
```dart
Center(
  child: Column(
    children: [
      LargeLogo(),
      SizedBox(height: 10),
      Text('Welcome back!'),
    ],
  ),
)
```

## Widget Best Practices

### 1. Theme Integration
Always use theme-aware colors and styles:

```dart
// Good
Container(
  color: theme.colorScheme.background,
  child: Text(
    'Hello',
    style: TextStyle(color: theme.colorScheme.onBackground),
  ),
)

// Avoid hardcoded colors
Container(
  color: Colors.white, // Don't do this
  child: Text('Hello', style: TextStyle(color: Colors.black)), // Don't do this
)
```

### 2. Responsive Design
Make widgets responsive to different screen sizes:

```dart
Widget build(BuildContext context) {
  final screenSize = MediaQuery.of(context).size;
  final isSmallScreen = screenSize.width < 600;
  
  return Container(
    width: isSmallScreen ? screenSize.width * 0.9 : 400,
    child: YourWidget(),
  );
}
```

### 3. Accessibility
Include proper accessibility features:

```dart
IconButton(
  icon: Icon(Icons.settings),
  onPressed: () {},
  tooltip: 'Settings', // Add tooltip
  semanticsLabel: 'Open settings', // Add semantic label
)
```

### 4. Performance Optimization
Use const constructors and optimize rebuilds:

```dart
// Good - const constructor
const CustomWidget({Key? key}) : super(key: key);

// Good - use const for static widgets
const SizedBox(height: 20),

// Good - use Consumer only when needed
Consumer<ThemeProvider>(
  builder: (context, themeProvider, child) {
    return Text(themeProvider.isDarkMode ? 'Dark' : 'Light');
  },
)
```

### 5. Error Handling
Include proper error handling in widgets:

```dart
Widget build(BuildContext context) {
  return FutureBuilder<String>(
    future: _loadData(),
    builder: (context, snapshot) {
      if (snapshot.hasError) {
        return ErrorWidget(
          message: 'Failed to load data',
          onRetry: () => setState(() {}),
        );
      }
      
      if (snapshot.connectionState == ConnectionState.waiting) {
        return CircularProgressIndicator();
      }
      
      return Text(snapshot.data ?? 'No data');
    },
  );
}
```

### 6. State Management
Use appropriate state management patterns:

```dart
// For local state
class _MyWidgetState extends State<MyWidget> {
  bool _isLoading = false;
  
  void _handleAction() async {
    setState(() => _isLoading = true);
    try {
      await _performAction();
    } finally {
      setState(() => _isLoading = false);
    }
  }
}

// For global state
Consumer<ThemeProvider>(
  builder: (context, themeProvider, child) {
    return Switch(
      value: themeProvider.isDarkMode,
      onChanged: (value) => themeProvider.setTheme(value),
    );
  },
)
```

### 7. Widget Composition
Compose widgets from smaller, reusable components:

```dart
class ProfileCard extends StatelessWidget {
  final User user;
  
  const ProfileCard({required this.user, Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ProfileAvatar(user: user),
            SizedBox(height: 8),
            ProfileName(user: user),
            SizedBox(height: 4),
            ProfileBio(user: user),
          ],
        ),
      ),
    );
  }
}
```

### 8. Testing
Make widgets testable by providing proper keys and callbacks:

```dart
class CustomButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String label;
  final Key? key;
  
  const CustomButton({
    required this.onPressed,
    required this.label,
    this.key,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      key: key,
      onPressed: onPressed,
      child: Text(label),
    );
  }
}

// In tests
testWidgets('CustomButton calls onPressed when tapped', (tester) async {
  bool wasPressed = false;
  
  await tester.pumpWidget(
    MaterialApp(
      home: CustomButton(
        key: Key('test-button'),
        onPressed: () => wasPressed = true,
        label: 'Test',
      ),
    ),
  );
  
  await tester.tap(find.byKey(Key('test-button')));
  expect(wasPressed, true);
});
```

This comprehensive widget documentation provides developers with detailed information about all UI components in the WIT Ü Flutter app, including usage examples, implementation details, and best practices for creating maintainable and performant widgets.