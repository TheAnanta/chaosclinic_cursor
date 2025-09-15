# Chaos Clinic - Mental Health & Emotional Wellbeing App

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

#### AI Assistant "Kanha"
- Personalized emotional support chat
- Context-aware responses based on user history
- Proactive check-ins during stressful activities

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
4. Run `flutter packages pub run build_runner build` for code generation
5. Run `flutter run`

## 📋 Implementation Roadmap

### Phase 1: Foundation ✅
- [x] Architecture setup and core models
- [x] Authentication system
- [x] Onboarding flow
- [x] Home dashboard

### Phase 2: Core Features
- [ ] AI chat integration with Gemini
- [ ] Comprehensive emotion logging
- [ ] Activity implementation
- [ ] Health platform integration

### Phase 3: Games & Activities
- [ ] Word Search game with check-ins
- [ ] Bug Smash stress relief game
- [ ] Guided meditation system
- [ ] Journaling features

### Phase 4: Community
- [ ] Article feed and reading
- [ ] Challenge system
- [ ] Buddy matching algorithm
- [ ] User-generated content

### Phase 5: Production
- [ ] Performance optimization
- [ ] Security audit
- [ ] App store deployment
- [ ] Analytics integration

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
