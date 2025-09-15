### **A Comprehensive Architectural Blueprint for the Chaos Clinic Application**

#### **1. Foreword: The Philosophy of an Intentional Architecture**

The development of Chaos Clinic, an application dedicated to emotional wellbeing, demands a deliberate, well-considered architectural foundation. The sensitive nature of its purpose—to provide a supportive and stable experience for users managing stress and anxiety—makes architectural integrity paramount. In the context of Flutter and Firebase, our architecture is defined as the process of structuring, organizing, and designing the application to make it scalable, reliable, and maintainable as features and user trust grow.

This blueprint is the foundational guide for creating an application that is easy to modify, update, and debug. It is built upon a trilogy of foundational principles that collectively ensure the application's long-term health and scalability:

- **Separation of Concerns**: This is the single most important principle. The application will be divided into distinct UI, Domain, and Data layers, each with a narrow, well-defined responsibility. This separation simplifies the codebase and allows features like the AI assistant "Kanha" and platform-specific health integrations to evolve independently.
- **Unidirectional Data Flow**: This principle establishes a predictable flow of information. Data updates originate from the Data Layer (Firestore, HealthKit) and flow exclusively toward the UI Layer. User interactions, such as logging an emotion or completing a mini-game, are sent from the UI to the Data Layer for processing. This one-way street for data prevents state inconsistencies and makes debugging significantly more straightforward.
- **Testability as a Causal Driver**: A sound architecture is inherently easy to test. The design choices presented here are made explicitly to facilitate simple unit and widget testing. By decoupling dependencies, we can test the logic of an emotion-logging view model without needing the actual Firebase backend or test a data repository without a live connection, ensuring reliability and stability for our users.

---

#### **2. The Layered Architectural Blueprint: A Multidimensional Framework**

The architectural model for Chaos Clinic is a multi-layered framework that organizes the application into three primary layers.

- **The UI Layer**: Responsible for presenting data to the user and handling interactions. It is built upon the Model-View-ViewModel (MVVM) pattern and serves as the visual interface for features like mood logging, mini-games, and the "Kanha" chat interface.
- **The Data Layer**: The "source of truth" for all application data. It is responsible for fetching, storing, and synchronizing data from Firebase services, platform health APIs (HealthKit, Google Health API), and other external sources. The UI layer has no direct knowledge of where its data originates.
- **The Domain Layer**: This layer is placed between the UI and Data layers. Its components, known as use-cases or interactors, contain reusable business logic. For Chaos Clinic, this includes logic for personalized activity suggestions, buddy matching algorithms, and processing emotional history. This layer also houses the core data models (`EmotionLog`, `UserProfile`) shared across the application.

---

#### **3. Component-Level Implementation: A Gemini CLI Vibe Prompt Guide**

This section translates the architectural theory into concrete, prompt-ready implementation guidance for a generative coding workflow.

##### **3.1. Domain Layer: The Business Logic Engine**

The domain layer contains the core, immutable data models and business logic of the application.

- **Domain Models**: These are pure, immutable Dart classes, preferably generated using `freezed`.

  - **_Prompt:_** _"Generate an immutable `UserProfile` domain model using freezed. It should contain `uid`, `displayName`, `email`, a list of trusted `SupportContact` objects, and a link to their `EmotionalHistory`."_

  - **_Prompt:_** _"Generate an immutable `EmotionLog` domain model using freezed. Include a unique `id`, `timestamp`, a `mood` string, an `intensity` value from 1 to 5, and an optional `note`."_
  - **_Prompt:_** _"Generate an immutable `Activity` domain model for mini-games and exercises. It should have an `id`, `title`, `description`, `type` (e.g., 'game', 'meditation', 'grounding'), and the `assetPath` for the activity."_

* **_Prompt:_** _"Generate a `CommunityArticle` domain model using freezed. Include `id`, `title`, `subtitle`, `authorName`, `authorImageUrl`, `headerImageUrl`, `content`, `tags` (List<String>), and `readTimeInMinutes`."_
* **_Prompt:_** _"Generate a `Challenge` domain model using freezed. Include `id`, `title`, `subtitle`, `date`, `iconAssetPath`, and `progress` (double from 0.0 to 1.0)."_
* **_Prompt:_** _"Generate a `ChatMessage` domain model using freezed. Include `id`, `text`, `sender` (enum: `user`, `ai`), and `timestamp`."_

- **Use-Cases (Interactors)**: These classes contain specific business logic and depend on repositories from the Data Layer.
  - **_Prompt:_** _"Create a `GetPersonalizedActivityUseCase`. It should depend on the `UserRepository` and `ActivityRepository`. Its `call` method should take a user's latest `EmotionLog` and return a recommended `Activity`."_
  - **_Prompt:_** _"Create a `LogEmotionUseCase`. It will depend on the `EmotionRepository`. Its `call` method will take an `EmotionLog` object, validate it, and pass it to the repository to be saved."_
  * **_Prompt:_** _"Create a `GetHomeScreenDataUseCase`. It must depend on the `UserRepository`, `ArticleRepository`, and `ActivityRepository`. Its `call` method should return a combined model containing the user's name, their trusted contact's initial, an AI-generated welcome message, and a list of personalized `Activity` recommendations."_

* **_Prompt:_** _"Create a `SubmitOnboardingUseCase`. It will take a `copingPreference` and `trustedContact` string, and use the `UserRepository` to update the current user's profile in Firestore."_
* **_Prompt:_** _"Create a `SendMessageToKanhaUseCase`. It should depend on a `KanhaAIRepository`. Its `call` method will take the current chat history (List<ChatMessage>) and the new user message, send it to the repository, and return the new `ChatMessage` from the AI."_

##### **3.2. Data Layer: Repositories and Services**

The data layer handles all data management, abstracting the data sources from the rest of the app.

- **API Models**: These models represent the raw data structure from external sources, like Firestore documents.
  - **_Prompt:_** _"Generate an `EmotionLogApiModel` class with `fromFirestore` and `toFirestore` methods. It should handle converting Firestore Timestamps to/from Dart's DateTime."_
- **Services**: These are low-level classes that interact directly with external APIs or platform plugins.
  - **_Prompt:_** _"Create an abstract `AuthenticationService` class with methods for `signInWithGoogle`, `signOut`, and a stream of the current `User`. Then, create a `FirebaseAuthenticationService` implementation using `firebase_auth`."_
  - **_Prompt:_** _"Create a `FirestoreService` class that provides generic methods for setting and getting documents and collections from Cloud Firestore."_
  - **_Prompt:_** _"Create a `HealthPlatformService` that abstracts interactions with Apple HealthKit and Google Health API. It should have methods to `requestAuthorization`, `writeEmotionLog`, and `getEmotionalHistory`."_
- **Repositories**: The source of truth for a single data type. They depend on services and transform API models into domain models.
  - **_Prompt:_** _"Create an abstract `EmotionRepository` class. It should define methods to `addEmotionLog(EmotionLog log)` and `getEmotionLogs(String userId)`. Now, generate a `EmotionRepositoryImpl` implementation that depends on the `FirestoreService` and `HealthPlatformService`. When `addEmotionLog` is called, it must save the log to both Firestore and the native health platform."_

##### **3.3. UI Layer: Views and ViewModels (MVVM)**

The UI layer is composed of reactive Views (Widgets) and the ViewModels that manage their state.

- **ViewModels**: Dart classes that contain all UI logic. They are implemented as `ChangeNotifier` objects and use dependency injection to get repositories or use-cases.
  - **_Prompt:_** _"Generate an `EmotionLogViewModel` that extends `ChangeNotifier`. It should depend on the `LogEmotionUseCase`. Expose a method `logNewEmotion(String mood, int intensity, String? note)`. The view model should manage a UI state of `loading`, `success`, and `error`."_
  - **_Prompt:_** _"Create a `HomeViewModel` that extends `ChangeNotifier`. It should depend on the `GetPersonalizedActivityUseCase` and `EmotionRepository`. It must fetch the user's recent emotional history and a personalized activity suggestion, and expose them as properties for the view."_
- **Views**: Flutter widgets that are "dumb" and simply render the state provided by a ViewModel.

  - **_Prompt:_** _"Create an `EmotionLogScreen` widget. It should be a `StatefulWidget` that uses `ChangeNotifierProvider` to create and listen to the `EmotionLogViewModel`. The UI should contain elements to select a mood, an intensity slider, a text field for notes, and a submit button that calls the view model's `logNewEmotion` method."_
  - **ViewModels**: `ChangeNotifier` classes that manage state and UI logic.

  - **_Prompt:_** _"Generate an `OnboardingViewModel` extending `ChangeNotifier`. It should hold the selected `copingPreference` and `trustedContact`. It needs a `submitOnboarding` method that calls the `SubmitOnboardingUseCase` and manages a loading state."_
  - **_Prompt:_** _"Create a `HomeViewModel` extending `ChangeNotifier`. It must use the `GetHomeScreenDataUseCase` to fetch all data for the home screen. It should expose properties for `greeting`, `aiMessageCard`, `trustedContactCard`, and `activityList`. It should also have a `logMood` method."_
  - **_Prompt:_** _"Generate a `KanhaChatViewModel`. It must manage a `List<ChatMessage>` and a `bool` for `isAiTyping`. It will use the `SendMessageToKanhaUseCase` to send a message and update the chat list and typing indicator."_
  - **_Prompt:_** _"Create a `WordSearchGameViewModel`. It needs to manage the game timer (`Stopwatch`), the list of words, and the user's score. It must also contain logic to show a proactive 'Just checking up' dialog if the timer exceeds 90 seconds or if the user makes several incorrect guesses in a row."_

---

#### **4. The Architectural Blueprint for Project Structure**

A standardized folder structure is essential for consistency and scalability. This hybrid approach combines layer-first organization for shared code and feature-first for UI components.

```
lib
├── main.dart
│
├─┬─ ui
│ ├─┬─ core
│ │ ├── themes/
│ │ └── widgets/ (reusable widgets like PrimaryButton)
│ │
│ ├─┬─ home/
│ │ ├── home_view.dart
│ │ └── home_view_model.dart
│ │
│ ├─┬─ emotion_logging/
│ │ ├── emotion_log_view.dart
│ │ └── emotion_log_view_model.dart
│ │
│ ├─┬─ profile/
│ │ ├── profile_view.dart
│ │ └── profile_view_model.dart
│ │
│ ├─┬─ activities/
│ │ ├── dashboard/
│ | ├── word_search/
│ | ├── bug_smash/
│ │ ├── crossword_game/
│ │ └── guided_meditation/
│ │
│ ├─┬─ challenges/
│ │ ├── challenges_view.dart
│ │ └── challenges_view_model.dart
│ │
│ ├─┬─ community/
│ │ ├── feed/ (CommunityFeedView, etc.)
│ │ └── detail/ (ArticleDetailView, etc.)
│ │
│ └─┬─ kanha_chat/
│   ├── kanha_chat_view.dart
│   └── kanha_chat_view_model.dart
│
├─┬─ domain
│ ├─┬─ models
│ │ ├── user_profile.dart
│ │ ├── emotion_log.dart
│ │ └── activity.dart
│ │
│ └─┬─ use_cases
│   ├── get_personalized_activity_use_case.dart
│   └── log_emotion_use_case.dart
│
└─┬─ data
  ├─┬─ repositories
  │ ├── emotion_repository.dart
  │ └── user_repository.dart
  │
  ├─┬─ services
  │ ├── auth_service.dart
  │ ├── firestore_service.dart
  │ └── health_platform_service.dart
  │
  └─┬─ models
    └── emotion_log_api_model.dart

# Unit and widget tests mirroring the lib folder
test/
# Testing utilities and mocks
testing/
```

---

#### **5. Firebase & Platform Service Integration**

Dependency injection (using `package:provider`) is critical for creating a testable app. Services are provided at the root of the widget tree, and repositories and view models use `BuildContext.read` to acquire their dependencies.

| Feature / Need        | Firebase / Platform Service             | Implementation Detail                                                                                                                                               |
| :-------------------- | :-------------------------------------- | :------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| User Authentication   | **Firebase Authentication**             | `AuthenticationService` will handle Google Sign-In and session management.                                                                                          |
| User Data Storage     | **Cloud Firestore**                     | User profiles, support contacts, emotion logs, and activity history will be stored in Firestore, structured by user UID.                                            |
| AI Assistant "Kanha"  | **Cloud Functions + Vertex AI**         | The Flutter app sends user prompts to a Cloud Function, which securely calls the Gemini API in Vertex AI to get personalized, context-aware responses.              |
| Buddy Matching Logic  | **Cloud Functions**                     | A scheduled or triggered Cloud Function will run a matching algorithm on user data in Firestore to suggest potential buddies.                                       |
| Emotional History     | **Apple HealthKit / Google Health API** | The `HealthPlatformService` will write `StateOfMind` data to the native health stores, allowing users to see their emotional wellbeing alongside other health data. |
| Minigame Leaderboards | **Google Play Games / GameKit**         | Platform-specific services will be used to manage scores and achievements for the mini-games.                                                                       |

---

#### **6. Advanced Architectural Recommendations for Chaos Clinic**

- **Optimistic State**: When a user logs an emotion, the UI can immediately show a "Logged!" confirmation. The `EmotionLogViewModel` will update its state optimistically while the `LogEmotionUseCase` handles the background task of saving the data to both Firestore and the health platform. This provides instant feedback.
- **Robust Error Handling with Result Objects**: Interactions with Firebase and the AI model can fail. Use a `Result` type (e.g., from `package:multiple_result`) for all repository and use-case methods. This forces the ViewModel to explicitly handle both the success and error states, preventing unexpected crashes and allowing for clear error messages to be shown to the user (e.g., "Could not connect. Please try again.").
- **The Command Pattern**: For complex actions like onboarding or a multi-step activity, encapsulate the logic within a Command object inside the ViewModel. This manages the `running`, `complete`, and `error` states of the action, keeping the ViewModel clean and the UI state predictable.

#### **5. Feature to Architecture Mapping**

This table provides a clear link between your designs and the proposed architecture.

| Figma Screen/Feature   | View (`ui/feature/`)                  | ViewModel (`ui/feature/`)                | Key Use-Cases (`domain/use_cases/`) | Repositories (`data/repositories/`)              |
| :--------------------- | :------------------------------------ | :--------------------------------------- | :---------------------------------- | :----------------------------------------------- |
| **Onboarding**         | `onboarding_view.dart`                | `OnboardingViewModel`                    | `SubmitOnboardingUseCase`           | `UserRepository`                                 |
| **Home Dashboard**     | `home_view.dart`                      | `HomeViewModel`                          | `GetHomeScreenDataUseCase`          | `UserRepository`, `ActivityRepository`           |
| **Kanha AI Chat**      | `kanha_chat_view.dart`                | `KanhaChatViewModel`                     | `SendMessageToKanhaUseCase`         | `KanhaAIRepository`                              |
| **Community Feed**     | `community/feed/feed_view.dart`       | `CommunityFeedViewModel`                 | `GetCommunityFeedUseCase`           | `CommunityRepository`                            |
| **Word Search Game**   | `activities/word_search_view.dart`    | `WordSearchGameViewModel`                | `SubmitGameScoreUseCase`            | `UserRepository`, `ActivityRepository`           |
| **Profile & Settings** | `profile_view.dart`                   | `ProfileViewModel`                       | `SignOutUseCase`                    | `UserRepository`, `AuthService`, `HealthService` |
| **Proactive Dialog**   | (Handled within `WordSearchGameView`) | (Logic within `WordSearchGameViewModel`) | N/A                                 | N/A                                              |
