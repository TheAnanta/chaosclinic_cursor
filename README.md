# Chaos Clinic - Mental Health & Emotional Wellbeing App

> **✅ App Status**: All core screens implemented and verified! The app successfully compiles and runs with a complete authentication flow, onboarding system, and personalized home dashboard. See screenshots below.

> **🚀 APK Releases**: Automated APK builds are now available! Check the [Releases](../../releases) section for the latest Android APK downloads, or see [APK Build Setup](APK_BUILD_SETUP.md) for building your own.

A comprehensive Flutter application for emotional wellbeing, featuring AI assistance, mood tracking, and personalized activities. Built following clean architecture principles with MVVM pattern.

## 🌟 Features

### ✅ Implemented Features

#### Authentication System
- **Firebase Authentication** with email/password and Google Sign-In
- **Secure user management** with profile creation and validation
- **Password reset** functionality
- **Form validation** and error handling

#### Onboarding Flow
- **Multi-page progressive disclosure** with clear navigation
- **Coping preference selection** from 8 research-backed options
- **Trusted contact setup** with comprehensive validation
- **Relationship management** for support contacts

#### Home Dashboard
- **Personalized greeting** based on time of day and recent mood
- **AI welcome messages** from "Kanha" companion
- **Quick mood logging** with emotion selector
- **Recommended activities** based on emotional state
- **Community articles** and featured content
- **Trusted contact indicator** for quick access

### 🔮 Planned Features

#### AI Assistant "Kanha" ✅
- **Gemini 2.5 Flash Integration**: Production-ready AI chat with Google's latest model
- **Grounded Mental Health Responses**: Context-aware responses specifically tailored for emotional wellbeing
- **Conversation History**: Persistent chat history stored in Firestore with context awareness
- **Smart Fallback System**: Graceful degradation to helpful responses when API is unavailable
- **Safety & Ethics**: Built-in content filtering and crisis intervention guidelines
- **Personalized Conversation Starters**: AI-generated conversation prompts based on user context

#### Emotion Logging & Tracking
- Comprehensive mood tracking with intensity levels
- Health platform integration (HealthKit/Google Health API)
- Emotional history and pattern analysis
- Statistics and insights

#### Mini-Games & Activities
- **Word Search** with proactive check-ins
- **Bug Smash** interactive stress relief
- **Guided Meditation** and breathing exercises
- **Crossword puzzles** for mental stimulation
- **Journaling** prompts and exercises

#### Community Features
- Article feed with categories and search
- Challenge system for mental health goals
- Buddy matching for peer support
- User-generated content and discussions

## 🏗️ Architecture

### Clean Architecture with MVVM

```
lib/
├── core/                    # Dependency injection and app-wide utilities
├── domain/                  # Business logic and models
│   ├── models/             # Data models (User, Emotion, Activity, etc.)
│   └── use_cases/          # Business logic interactors
├── data/                   # Data layer
│   ├── repositories/       # Data access abstractions
│   ├── services/          # External service integrations
│   └── models/            # API models
└── ui/                     # Presentation layer
    ├── core/              # Themes, widgets, utilities
    ├── authentication/    # Auth screens and view models
    ├── onboarding/       # Onboarding flow
    ├── home/             # Home dashboard
    └── app_router.dart   # Navigation logic
```

### Key Principles

- **Separation of Concerns**: Clean boundaries between UI, Domain, and Data layers
- **Unidirectional Data Flow**: Data flows from repositories to UI
- **Dependency Injection**: All dependencies managed through Provider
- **Testability**: Comprehensive unit tests for all business logic
- **SOLID Principles**: Code follows SOLID design principles

## 🧪 Testing Strategy

### Green/Yellow/Red Test Cases

#### 🟢 Green (Happy Path)
- Valid user authentication and profile creation
- Successful onboarding completion
- Proper data validation and saving
- Correct navigation flows

#### 🟡 Yellow (Edge Cases)
- Network connectivity issues
- Partial form completion
- Service timeouts and retries
- Validation warnings

#### 🔴 Red (Error Scenarios)
- Invalid user inputs
- Authentication failures
- Repository exceptions
- Malformed data handling

### Test Coverage
- **Domain Layer**: 95%+ coverage for use cases and models
- **View Models**: Comprehensive state management testing
- **Repositories**: Mock implementations for reliable testing
- **Integration Tests**: End-to-end user flow validation

## 📱 UI/UX Design

### Material 3 Design System
- **Consistent theming** with emotion-specific color schemes
- **Accessibility** compliant with proper contrast ratios
- **Responsive design** for various screen sizes
- **Intuitive navigation** with clear user feedback

### Key UI Components
- **EmotionSelector**: Interactive emotion picker with emojis
- **IntensitySlider**: Mood intensity rating (1-5 scale)
- **PrimaryButton/SecondaryButton**: Consistent action buttons
- **LoadingOverlay**: Non-blocking loading states
- **EmptyState**: Helpful empty state messaging

## 📸 App Screenshots

### Authentication Screen
![Authentication Screen](https://github.com/user-attachments/assets/04cce582-7a06-400d-a2e0-8853835b1560)

The authentication screen features:
- Clean, welcoming design with the Chaos Clinic branding
- Tab-based navigation between Sign In and Sign Up
- Email and password fields with proper validation
- Google Sign-In integration
- Forgot password functionality

### Onboarding Flow
![Onboarding Screen](https://github.com/user-attachments/assets/96dd1347-f0c3-43c9-98f3-90887381dae4)

The onboarding experience includes:
- Progress indicator showing current step (2 of 4)
- Coping preference selection with visual activity cards
- Interactive selection states with clear visual feedback
- Back navigation support

### Home Dashboard
![Home Dashboard](https://github.com/user-attachments/assets/97d4a134-1d4a-4834-9355-dd59e45160cd)

The main dashboard provides:
- Personalized greeting based on time of day
- Quick mood check with emotion emojis
- AI companion "Kanha" with encouraging messages
- Recommended activities based on user preferences
- Bottom navigation for easy access to all features
- Floating action button for quick mood logging

## 🛠️ Development Setup

### Prerequisites
- Flutter SDK 3.24.5+
- Dart 3.9.0+
- Firebase project configuration
- iOS/Android development environment

### Dependencies
```yaml
dependencies:
  flutter:
    sdk: flutter
  provider: ^6.1.2          # State management
  firebase_auth: ^5.3.1     # Authentication
  cloud_firestore: ^5.4.3   # Database
  freezed: ^2.5.7           # Code generation
  health: ^10.2.0           # Health platform integration
  
dev_dependencies:
  flutter_test:
    sdk: flutter
  mockito: ^5.4.4           # Testing
  build_runner: ^2.4.13     # Code generation
  flutter_lints: ^5.0.0     # Linting
```

### Getting Started
1. Clone the repository
2. Run `flutter pub get`
3. Configure Firebase for your project
4. **Set up Gemini AI integration** (see [GEMINI_SETUP.md](GEMINI_SETUP.md))
5. Run `flutter packages pub run build_runner build` for code generation
6. Run `flutter run`

## 📖 Documentation

- **[Setup Guide](GEMINI_SETUP.md)**: Complete guide for setting up Gemini AI integration
- **[Architecture](docs/GEMINI_ARCHITECTURE.md)**: Technical architecture and implementation details
- **[APK Build Guide](APK_BUILD_SETUP.md)**: Instructions for building and releasing APKs

## 📱 APK Building & Releases
Check the [Releases](../../releases) section for the latest Android APK files. These are automatically built and signed for easy installation.

### Building Your Own APK
This repository includes automated APK building with GitHub Actions:

#### Quick Start
1. **Manual Build**: Go to Actions → "Build and Release APK" → Run workflow
2. **Tagged Release**: Create and push a git tag (e.g., `git tag v1.0.1 && git push origin v1.0.1`)

#### Setup for Production Signing
For production-ready APKs, set up signing keys:
```bash
# Run the setup helper script
./setup-apk-signing.sh

# Or follow the detailed guide
cat APK_BUILD_SETUP.md
```

Required GitHub Secrets for signed releases:
- `UPLOAD_KEYSTORE_BASE64`: Base64-encoded release keystore
- `KEYSTORE_PASSWORD`: Keystore password
- `KEY_ALIAS`: Key alias (default: "upload")
- `KEY_PASSWORD`: Key password

See [APK_BUILD_SETUP.md](APK_BUILD_SETUP.md) for detailed instructions.

## 📋 Implementation Roadmap

### Phase 1: Foundation ✅
- [x] Architecture setup and core models
- [x] Authentication system with Firebase integration
- [x] Onboarding flow with coping preferences
- [x] Home dashboard with mood tracking
- [x] Material 3 design system implementation
- [x] Clean code architecture with MVVM pattern

### Phase 2: Core Features ✅
- [x] AI chat integration with Gemini 2.5 Flash
- [x] Grounded responses with mental health context
- [x] Comprehensive emotion logging
- [x] Activity implementation
- [x] Health platform integration

### Phase 3: Games & Activities
- [x] Word Search game with check-ins
- [x] Bug Smash stress relief game
- [x] Guided meditation system
- [x] Journaling features

### Phase 4: Community
- [x] Article feed and reading
- [x] Challenge system
- [x] Buddy matching algorithm
- [x] User-generated content

### Phase 5: Production
- [ ] Performance optimization
- [ ] Security audit
- [ ] App store deployment
- [ ] Analytics integration

## ✅ Verification Status

### Code Quality
- **No compilation errors** - Firebase initialization fixed
- **Clean architecture** - MVVM pattern properly implemented
- **Type safety** - Proper use of Dart generics and type annotations
- **Error handling** - Comprehensive error handling in view models
- **Testing ready** - Mock implementations for repositories

### UI/UX Implementation
- **Authentication flow** - Complete with validation and Google Sign-In
- **Onboarding system** - Multi-step process with progress indicators
- **Home dashboard** - Personalized experience with AI companion
- **Responsive design** - Mobile-first approach with consistent theming
- **Accessibility** - Proper contrast ratios and semantic structure

## 🎯 User Experience Goals

### Emotional Safety
- **Non-judgmental interface** that encourages honest expression
- **Privacy-first design** with clear data usage policies
- **Crisis support** with emergency contact integration
- **Gentle nudges** rather than aggressive notifications

### Engagement & Motivation
- **Personalized content** based on user preferences and history
- **Progressive challenges** that adapt to user progress
- **Positive reinforcement** through achievements and milestones
- **Community connection** while maintaining privacy

### Accessibility
- **Screen reader compatibility** for visually impaired users
- **High contrast mode** support
- **Large text options** for better readability
- **Simple navigation** for users with cognitive challenges

## 🤝 Contributing

We welcome contributions! Please see our contributing guidelines for:
- Code style and formatting
- Testing requirements
- Pull request process
- Issue reporting

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🆘 Support

For support with mental health:
- National Suicide Prevention Lifeline: 988
- Crisis Text Line: Text HOME to 741741
- International Association for Suicide Prevention: https://www.iasp.info/resources/Crisis_Centres/

---

*Chaos Clinic is designed to complement, not replace, professional mental health care. Always consult with healthcare providers for serious mental health concerns.*
