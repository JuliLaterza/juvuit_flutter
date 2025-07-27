# WIT Ü Flutter App - Project Structure Map

## Overview
This document provides a comprehensive map of the WIT Ü Flutter application's folder and file structure, including descriptions of each component's purpose and functionality.

## Root Directory Structure

```
juvuit_flutter/
├── 📁 .git/                          # Git version control
├── 📁 .vscode/                       # VS Code workspace settings
├── 📁 android/                       # Android platform-specific code
├── 📁 assets/                        # Static assets (images, fonts, etc.)
├── 📁 control_archivos/              # File control utilities
├── 📁 ios/                          # iOS platform-specific code
├── 📁 lib/                          # Main Dart source code
├── 📁 linux/                        # Linux platform-specific code
├── 📁 macos/                        # macOS platform-specific code
├── 📁 test/                         # Test files
├── 📁 web/                          # Web platform-specific code
├── 📁 windows/                      # Windows platform-specific code
├── 📄 .gitignore                    # Git ignore rules
├── 📄 .metadata                     # Flutter project metadata
├── 📄 analysis_options.yaml         # Dart analyzer configuration
├── 📄 devtools_options.yaml         # Flutter DevTools configuration
├── 📄 firebase.json                 # Firebase configuration
├── 📄 main2.py                      # Python utility script
├── 📄 pubspec.lock                  # Locked dependency versions
├── 📄 pubspec.yaml                  # Project dependencies and configuration
└── 📄 README.md                     # Project readme
```

## Core Application Structure (`lib/`)

### Main Entry Point
```
lib/
├── 📄 main.dart                     # Application entry point
└── 📄 firebase_options.dart         # Firebase configuration options
```

### Core Module (`lib/core/`)
```
lib/core/
├── 📁 services/                     # Core services and utilities
│   ├── 📄 firebase_helpers.dart     # Firebase utility functions
│   ├── 📄 spotify_service.dart      # Spotify API integration
│   └── 📄 theme_provider.dart       # Theme state management
├── 📁 utils/                        # Utility classes and constants
│   ├── 📄 app_themes.dart           # Theme definitions (light/dark)
│   ├── 📄 colors.dart               # Color scheme definitions
│   └── 📄 routes.dart               # Navigation routes configuration
└── 📁 widgets/                      # Reusable UI components
    ├── 📄 app_logo_header.dart      # App logo header component
    ├── 📄 custom_bottom_nav_bar.dart # Custom bottom navigation
    ├── 📄 email_input_field.dart    # Email input component
    ├── 📄 password_input_field.dart # Password input component
    ├── 📄 social_login_button.dart  # Social login button
    ├── 📄 theme_aware_logo.dart     # Theme-aware logo component
    └── 📄 theme_toggle_button.dart  # Theme toggle button
```

### Feature Modules (`lib/features/`)

#### Authentication Module (`lib/features/auth/`)
```
lib/features/auth/
├── 📁 domain/                       # Business logic and entities
└── 📁 presentation/                 # UI layer
    ├── 📁 screens/                  # Authentication screens
    │   ├── 📄 complete_profile_screen.dart      # Profile completion
    │   ├── 📄 complete_profile_screen_backup.dart # Backup version
    │   ├── 📄 login_screen.dart                 # Login screen
    │   ├── 📄 login_screen_background.dart      # Login with background
    │   ├── 📄 register_screen.dart              # Registration screen
    │   └── 📄 splash_screen.dart                # App splash screen
    └── 📁 widgets/                  # Auth-specific widgets
```

#### Chats Module (`lib/features/chats/`)
```
lib/features/chats/
└── 📁 presentation/
    └── 📁 screens/
        ├── 📄 chat_screen.dart                  # Individual chat
        ├── 📄 chats_screen.dart                 # Chat list
        ├── 📄 chats_screen_original.dart        # Original version
        └── 📄 chats_screen_v1.dart             # Version 1
```

#### Events Module (`lib/features/events/`)
```
lib/features/events/
└── 📁 presentation/
    └── 📁 screens/
        └── 📄 events_screen.dart               # Events discovery
```

#### Likes Received Module (`lib/features/likes_received/`)
```
lib/features/likes_received/
└── 📁 presentation/
    └── 📁 screens/
        └── 📄 likes_received_screen.dart       # Received likes
```

#### Matching Module (`lib/features/matching/`)
```
lib/features/matching/
├── 📁 controllers/                  # Matching logic controllers
├── 📁 data/                        # Data layer (models, repositories)
├── 📁 domain/                      # Business logic
├── 📁 presentation/                # UI layer
│   └── 📁 screens/
│       ├── 📄 match_animation_screen.dart      # Match celebration
│       ├── 📄 matching_ig_screen.dart          # Instagram-style matching
│       ├── 📄 matching_screen.dart             # Main matching interface
│       ├── 📄 matchingprofilescreen.dart       # Profile viewing
│       └── 📄 matchingprofilescreen_backup.dart # Backup version
└── 📁 widgets/                     # Matching-specific widgets
    └── 📄 matching_loader.dart     # Loading component
```

#### Onboarding Module (`lib/features/onboarding/`)
```
lib/features/onboarding/
└── 📁 presentation/
    └── 📁 screens/
        └── 📄 intro_slides_screen.dart         # Introduction slides
```

#### Profile Module (`lib/features/profile/`)
```
lib/features/profile/
├── 📁 data/                        # Data layer
├── 📁 domain/                      # Business logic
└── 📁 presentation/
    └── 📁 screens/
        ├── 📄 edit_profile_screen.dart         # Profile editing
        ├── 📄 emergency_contact_screen.dart    # Emergency contacts
        ├── 📄 feedback_screen.dart             # User feedback
        ├── 📄 help_center_screen.dart          # Help and support
        ├── 📄 matching_preferences_screen.dart # Matching settings
        ├── 📄 profile_screen.dart              # Main profile
        └── 📄 public_profile_screen.dart       # Public profile view
```

#### Profiles Module (`lib/features/profiles/`)
```
lib/features/profiles/
└── 📁 presentation/
    └── 📁 screens/
        └── 📄 profiles_screen.dart             # Profile discovery
```

#### Settings Module (`lib/features/settings/`)
```
lib/features/settings/
# Settings-related functionality
```

#### Testing Module (`lib/features/testing/`)
```
lib/features/testing/
└── 📁 screens/
    ├── 📄 debug_screen_delete.dart             # Debug delete functionality
    ├── 📄 debug_screen_home.dart               # Debug home screen
    ├── 📄 debug_screen_infomap.dart            # Debug info map
    ├── 📄 debug_screen_premium.dart            # Debug premium features
    └── 📄 debug_screen_spotify.dart            # Debug Spotify integration
```

#### Upload Image Module (`lib/features/upload_imag/`)
```
lib/features/upload_imag/
# Image upload functionality
```

#### User Actions Module (`lib/features/user_actions/`)
```
lib/features/user_actions/
# User action handling
```

## Assets Structure (`assets/`)

```
assets/
├── 📁 images/                       # Image assets
│   ├── 📁 homescreen/               # Home screen images
│   │   ├── 📄 witu_logo_dark.png    # Dark theme logo
│   │   ├── 📄 logo_witu.png         # Main logo
│   │   ├── 📄 witu_logo_light.png   # Light theme logo
│   │   ├── 📄 home.png              # Home screen image
│   │   ├── 📄 degrade-19.png        # Gradient image 19
│   │   └── 📄 degrade-20.png        # Gradient image 20
│   └── 📄 placeholder.jpg           # Placeholder image
```

## Platform-Specific Directories

### Android (`android/`)
```
android/
├── 📁 app/                          # Android app module
│   ├── 📁 src/                      # Source code
│   │   ├── 📁 main/                 # Main source
│   │   │   ├── 📁 java/             # Java source files
│   │   │   ├── 📁 kotlin/           # Kotlin source files
│   │   │   └── 📁 res/              # Android resources
│   │   └── 📁 test/                 # Android tests
│   ├── 📄 build.gradle              # App build configuration
│   └── 📄 proguard-rules.pro        # ProGuard rules
├── 📁 gradle/                       # Gradle wrapper
├── 📄 build.gradle                  # Project build configuration
├── 📄 gradle.properties             # Gradle properties
├── 📄 gradlew                       # Gradle wrapper script (Unix)
├── 📄 gradlew.bat                   # Gradle wrapper script (Windows)
└── 📄 settings.gradle               # Gradle settings
```

### iOS (`ios/`)
```
ios/
├── 📁 Runner/                       # iOS app target
│   ├── 📁 Assets.xcassets/          # iOS assets
│   ├── 📁 Base.lproj/               # Base localization
│   ├── 📁 Info.plist                # iOS app info
│   └── 📄 AppDelegate.swift         # iOS app delegate
├── 📁 Runner.xcodeproj/             # Xcode project
├── 📄 Podfile                       # CocoaPods dependencies
└── 📄 Podfile.lock                  # CocoaPods lock file
```

### Web (`web/`)
```
web/
├── 📄 favicon.png                   # Web favicon
├── 📄 index.html                    # Web entry point
├── 📄 manifest.json                 # Web app manifest
└── 📄 styles.css                    # Web styles
```

### Desktop Platforms

#### Windows (`windows/`)
```
windows/
├── 📁 runner/                       # Windows runner
│   ├── 📄 main.cpp                  # Windows main entry
│   ├── 📄 resource.h                # Windows resources
│   ├── 📄 runner.exe.manifest       # Windows manifest
│   ├── 📄 Runner.rc                 # Windows resource script
│   └── 📄 win32_window.cpp          # Windows window implementation
├── 📄 CMakeLists.txt                # CMake configuration
└── 📄 flutter/                      # Flutter Windows configuration
```

#### Linux (`linux/`)
```
linux/
├── 📁 my_application/               # Linux application
│   ├── 📄 CMakeLists.txt            # CMake configuration
│   ├── 📄 main.cc                   # Linux main entry
│   └── 📄 my_application.h          # Linux app header
└── 📄 CMakeLists.txt                # Root CMake configuration
```

#### macOS (`macos/`)
```
macos/
├── 📁 Runner/                       # macOS app target
│   ├── 📁 Assets.xcassets/          # macOS assets
│   ├── 📁 Base.lproj/               # Base localization
│   ├── 📁 DebugProfile.entitlements # Debug entitlements
│   ├── 📁 Release.entitlements      # Release entitlements
│   ├── 📄 AppDelegate.swift         # macOS app delegate
│   ├── 📄 Info.plist                # macOS app info
│   └── 📄 MainFlutterWindow.swift   # Main window implementation
├── 📁 Runner.xcodeproj/             # Xcode project
├── 📄 Podfile                       # CocoaPods dependencies
└── 📄 Podfile.lock                  # CocoaPods lock file
```

## Test Structure (`test/`)

```
test/
├── 📄 widget_test.dart              # Widget tests
└── 📄 integration_test/             # Integration tests
    └── 📄 app_test.dart             # App integration tests
```

## Configuration Files

### Project Configuration
- **`pubspec.yaml`**: Main project configuration, dependencies, and assets
- **`pubspec.lock`**: Locked dependency versions for reproducible builds
- **`analysis_options.yaml`**: Dart analyzer configuration and linting rules

### Development Tools
- **`.vscode/`**: VS Code workspace settings and launch configurations
- **`devtools_options.yaml`**: Flutter DevTools configuration
- **`.gitignore`**: Git ignore patterns for version control

### External Services
- **`firebase.json`**: Firebase project configuration
- **`firebase_options.dart`**: Firebase SDK configuration options

### Utilities
- **`main2.py`**: Python utility script for development tasks
- **`control_archivos/`**: File control and management utilities

## Architecture Overview

### Feature-Based Architecture
The app follows a feature-based architecture where each feature is self-contained with its own:
- **Presentation Layer**: UI components, screens, and widgets
- **Domain Layer**: Business logic and entities
- **Data Layer**: Data models, repositories, and external service integrations

### Core Module
The core module contains:
- **Services**: Reusable business logic and external integrations
- **Utils**: Constants, helpers, and configuration
- **Widgets**: Reusable UI components used across features

### State Management
- **Provider**: Used for theme management and global state
- **Firebase Auth**: Handles authentication state
- **Local Storage**: SharedPreferences for persistent data

### Navigation
- **Named Routes**: Centralized routing system in `AppRoutes`
- **Bottom Navigation**: Custom bottom navigation bar for main sections
- **Screen Navigation**: Standard Flutter navigation patterns

## File Naming Conventions

### Dart Files
- **Screens**: `*_screen.dart`
- **Widgets**: `*_widget.dart` or descriptive names
- **Services**: `*_service.dart`
- **Models**: `*_model.dart`
- **Utils**: `*_utils.dart` or descriptive names

### Asset Files
- **Images**: Descriptive names with appropriate extensions
- **Icons**: SVG or PNG format
- **Logos**: Multiple variants for different themes

### Configuration Files
- **YAML**: Configuration and dependency files
- **JSON**: External service configurations
- **XML**: Platform-specific configurations

## Development Workflow

### Adding New Features
1. Create feature directory in `lib/features/`
2. Implement presentation, domain, and data layers
3. Add routes to `AppRoutes`
4. Update navigation if needed
5. Add tests in `test/` directory

### Adding New Core Components
1. Add to appropriate `lib/core/` subdirectory
2. Follow existing naming conventions
3. Update documentation
4. Add tests

### Asset Management
1. Place assets in `assets/` directory
2. Update `pubspec.yaml` with asset declarations
3. Use appropriate asset variants for different themes/platforms

This structure provides a scalable and maintainable foundation for the WIT Ü Flutter application, following Flutter best practices and modern app architecture patterns.