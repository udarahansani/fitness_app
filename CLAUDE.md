# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Flutter fitness app called "MetaWell+" that provides authentication, user onboarding, and fitness tracking features. The app is designed as a comprehensive fitness companion with AI integration capabilities.

## Common Commands

### Development Commands
```bash
# Get dependencies
flutter pub get

# Run the app in development mode
flutter run

# Build APK for testing
flutter build apk

# Build APK for release
flutter build apk --release

# Run tests
flutter test

# Analyze code for issues
flutter analyze
```

### Linting and Code Quality
The project uses `flutter_lints` package for code analysis. Run `flutter analyze` to check for linting issues.

## Architecture Overview

### Project Structure
```
lib/
├── main.dart                    # App entry point, routes to WelcomeScreen
├── screens/                     # UI screens organized by feature
│   ├── auth/                   # Authentication flow screens
│   │   ├── welcome_screen.dart
│   │   ├── login_screen.dart
│   │   ├── register_screen.dart
│   │   ├── splash_screen.dart
│   │   └── forgot_password_screen.dart
│   ├── home/                   # Main app screens
│   │   └── home_screen.dart
│   └── profile/
│       └── profile_screen.dart
├── widgets/                    # Reusable UI components
│   ├── auth/                   # Auth-specific widgets
│   │   ├── auth_form.dart
│   │   └── social_login_button.dart
│   └── common/                 # General-purpose widgets
│       ├── custom_app_bar.dart
│       ├── custom_button.dart
│       ├── custom_text_field.dart
│       └── loading_widget.dart
├── models/                     # Data models
│   ├── auth_model.dart
│   └── user_model.dart
├── services/                   # Business logic and API calls
│   ├── auth_service.dart
│   ├── firestore_service.dart
│   └── google_sign_in_service.dart
├── providers/                  # State management
│   ├── auth_provider.dart
│   └── user_provider.dart
├── routes/                     # Navigation configuration
│   ├── app_routes.dart
│   └── route_generator.dart
├── core/                       # App-wide utilities and constants
│   ├── constants/              # App constants
│   │   ├── app_assets.dart
│   │   ├── app_colors.dart
│   │   └── app_strings.dart
│   ├── theme/                  # App theming
│   │   └── app_theme.dart
│   └── utils/                  # Helper functions
│       ├── helpers.dart
│       └── validators.dart
├── config/                     # Configuration files
│   ├── app_config.dart
│   └── firebase_config.dart
└── assests/                    # Static assets
    ├── images/
    └── icons/
```

### Key Architecture Patterns
- **Screen-Widget Architecture**: Screens contain business logic, widgets are reusable UI components
- **Service Layer**: Separate services for different concerns (auth, Firestore, etc.)
- **Provider Pattern**: State management using Provider pattern
- **Route-based Navigation**: Centralized route management in `/routes`

### Firebase Integration
The app is configured for Firebase with:
- Authentication (email/password, Google sign-in)
- Firestore database for user data
- Firebase configuration files generated via FlutterFire CLI

### State Management
Uses Provider pattern for state management with dedicated providers for:
- Authentication state (`auth_provider.dart`)
- User data (`user_provider.dart`)

### App Flow
1. App starts with `WelcomeScreen` from `main.dart`
2. Users can navigate to Login/Register screens
3. After authentication, users go to `HomeScreen`
4. Navigation is handled through named routes defined in `main.dart`

## Development Notes

### App Name and Branding
The app is titled "MetaWell+" (defined in `main.dart:17`)

### Theme Configuration
- Primary color: `Color(0xFF1565C0)` (blue)
- Uses Material Design with custom primary swatch

### Asset Management
Assets are organized in `lib/assests/` (note the typo in folder name - should be "assets")
- Images: logos, backgrounds
- Icons: social login icons (Google, Apple, Facebook)

### Testing
The project includes basic widget tests in `test/widget_test.dart`

### Implementation Guide
There's a comprehensive implementation guide in `fitsync_implementation_guide.md` that outlines:
- 8-week development timeline
- Firebase setup instructions
- OpenAI integration for AI features
- Detailed code examples for all major features

## Important Considerations

### Current State
The project appears to be in early development stages with:
- Basic screen structure implemented
- Authentication flow partially set up
- Firebase integration configured but may need completion
- Many service files exist but may be incomplete

### Future Features (from implementation guide)
- Water tracking
- Progress charts
- Workout plans
- Nutrition tracking
- AI chat integration with OpenAI
- Social features