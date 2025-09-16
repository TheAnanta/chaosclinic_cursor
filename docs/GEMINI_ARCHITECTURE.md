# Gemini AI Integration Architecture

This document outlines the technical architecture of the Gemini 2.5 Flash integration in Chaos Clinic.

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────┐
│                        UI Layer                             │
├─────────────────────────────────────────────────────────────┤
│  KanhaChatScreen          KanhaChatViewModel               │
│  ├─ Message bubbles       ├─ Chat state management          │
│  ├─ Input field           ├─ Typing indicators             │
│  ├─ Typing indicator      └─ Error handling                │
│  └─ Conversation starters                                  │
└─────────────────────────┬───────────────────────────────────┘
                         │
┌─────────────────────────▼───────────────────────────────────┐
│                     Domain Layer                           │
├─────────────────────────────────────────────────────────────┤
│  Use Cases:                                                │
│  ├─ SendMessageToKanhaUseCase                              │
│  ├─ GetChatHistoryUseCase                                  │
│  └─ GetConversationStartersUseCase                         │
│                                                            │
│  Models:                                                   │
│  └─ ChatMessage (with freezed/json_serializable)           │
└─────────────────────────┬───────────────────────────────────┘
                         │
┌─────────────────────────▼───────────────────────────────────┐
│                     Data Layer                             │
├─────────────────────────────────────────────────────────────┤
│  AiChatRepository (Interface)                              │
│  ├─ MockAiChatRepository (Development/Fallback)            │
│  └─ GeminiAiChatRepository (Production)                    │
│      ├─ GeminiAiService                                    │
│      └─ FirestoreService                                   │
└─────────────────────────┬───────────────────────────────────┘
                         │
┌─────────────────────────▼───────────────────────────────────┐
│                  External Services                         │
├─────────────────────────────────────────────────────────────┤
│  Google Gemini 2.5 Flash API                              │
│  ├─ System prompt with mental health context               │
│  ├─ Safety filters and content moderation                  │
│  ├─ Conversation history context                           │
│  └─ Fallback response generation                           │
│                                                            │
│  Cloud Firestore                                          │
│  ├─ user_chats/{userId}/messages/{messageId}              │
│  ├─ Chat history persistence                               │
│  └─ Cross-device synchronization                           │
└─────────────────────────────────────────────────────────────┘
```

## Key Components

### 1. GeminiAiService
**Purpose**: Direct integration with Google's Gemini 2.5 Flash API

**Key Features**:
- System prompt specifically designed for mental health support
- Context-aware conversations using chat history
- Safety filters for harmful content
- Fallback responses for API failures
- Conversation starter generation

**Configuration**:
```dart
GenerativeModel(
  model: 'gemini-2.5-flash',
  apiKey: apiKey,
  generationConfig: GenerationConfig(
    temperature: 0.7,    // Balanced creativity
    topK: 40,            // Token diversity
    topP: 0.95,          // Nucleus sampling
    maxOutputTokens: 1024, // Response length limit
  ),
  systemInstruction: Content.system(_getSystemPrompt()),
  safetySettings: [...] // Content filtering
)
```

### 2. GeminiAiChatRepository
**Purpose**: Manages chat data flow and persistence

**Responsibilities**:
- Orchestrates communication between UI and AI service
- Persists chat messages to Firestore
- Handles error scenarios gracefully
- Provides fallback responses when API fails

### 3. Mental Health Grounding

The system prompt includes comprehensive grounding for mental health context:

```
PERSONALITY:
- Warm, empathetic, and non-judgmental
- Genuine care and understanding
- Gentle, supportive tone
- Encouraging while acknowledging difficulties

KNOWLEDGE BASE:
- Mental health and emotional regulation
- Evidence-based coping strategies
- CBT principles and mindfulness techniques
- Crisis intervention awareness

SAFETY & LIMITATIONS:
- Encourage professional help for serious concerns
- Never provide medical diagnoses
- Clear about AI limitations
- Crisis intervention protocols
```

## Data Flow

### Message Sending Flow
```
1. User types message in KanhaChatScreen
2. KanhaChatViewModel.sendMessage() called
3. SendMessageToKanhaUseCase.call() invoked
4. GeminiAiChatRepository.sendMessage() processes:
   a. Saves user message to Firestore
   b. Calls GeminiAiService.sendMessage()
   c. GeminiAiService builds context from chat history
   d. API call to Gemini 2.5 Flash with system prompt
   e. Response processed and saved to Firestore
   f. ChatMessage returned to UI
5. UI updates with AI response
```

### Error Handling Flow
```
1. API call fails (network, quota, etc.)
2. GeminiAiService._getFallbackResponse() generates contextual response
3. Fallback message marked with MessageStatus.failed
4. User sees helpful response even when API unavailable
5. Background retry logic can be implemented
```

## Configuration & Security

### API Key Management
- Environment variable: `GEMINI_API_KEY`
- Build-time definition: `--dart-define=GEMINI_API_KEY=...`
- Never committed to version control
- Graceful fallback when not configured

### Content Safety
- Built-in Gemini safety filters
- Mental health-specific response validation
- Crisis intervention keyword detection
- Appropriate boundary setting in responses

### Rate Limiting (Production Ready)
- Request rate monitoring
- Exponential backoff for failures
- Quota management and alerting
- Caching for common responses

## Testing Strategy

### Unit Tests
- `GeminiAiService` fallback response logic
- `GeminiAiChatRepository` error handling
- Message serialization/deserialization
- Chat history management

### Integration Tests
- End-to-end chat flow with mock API
- Firestore persistence validation
- Error scenario handling
- Fallback system verification

### Manual Testing
- Real API integration with test key
- Response quality evaluation
- Safety filter validation
- User experience testing

## Performance Considerations

### Response Time
- Target: < 3 seconds for typical responses
- Streaming responses for longer content
- Loading indicators during processing
- Timeout handling with fallbacks

### Memory Management
- Chat history limited to recent messages
- Efficient message serialization
- Proper disposal of resources
- Memory leak prevention

### Offline Support
- Cached fallback responses
- Local message storage
- Sync when connection restored
- Clear offline indicators

## Deployment & Monitoring

### Production Checklist
- [ ] API key securely configured
- [ ] Rate limiting implemented
- [ ] Error monitoring setup
- [ ] Usage analytics tracking
- [ ] Cost monitoring alerts
- [ ] Response quality metrics
- [ ] User feedback collection

### Monitoring Metrics
- API response times
- Error rates and types
- User engagement metrics
- Response quality scores
- Cost per interaction
- Safety filter activations

This architecture ensures a robust, safe, and user-friendly AI chat experience while maintaining the flexibility to evolve and improve over time.