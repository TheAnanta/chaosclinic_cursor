# Gemini AI Integration Setup Guide

This guide explains how to set up the Gemini 2.5 Flash AI model integration for the Kanha AI companion in Chaos Clinic.

## Prerequisites

1. **Google AI Studio Account**: You need access to Google AI Studio to get a Gemini API key.
2. **Flutter Development Environment**: Flutter SDK 3.24.5 or later.

## Setup Instructions

### 1. Get Your Gemini API Key

1. Visit [Google AI Studio](https://aistudio.google.com/app/apikey)
2. Sign in with your Google account
3. Click "Create API Key"
4. Copy the generated API key (keep it secure!)

### 2. Configure the API Key

The app supports multiple ways to provide the API key:

#### Option A: Environment Variable (Recommended for Development)
```bash
export GEMINI_API_KEY="your_api_key_here"
flutter run --dart-define=GEMINI_API_KEY=$GEMINI_API_KEY
```

#### Option B: Build-time Definition
```bash
flutter run --dart-define=GEMINI_API_KEY=your_api_key_here
```

#### Option C: Environment File
1. Copy `.env.example` to `.env`
2. Fill in your API key in the `.env` file
3. Use a package like `flutter_dotenv` to load it (not included by default)

### 3. Verify Integration

1. Run the app with your API key configured
2. Navigate to the Kanha Chat screen
3. Send a message like "Hello, how are you?"
4. You should receive a response from the actual Gemini model

## Features

### Grounded AI Responses

The Gemini integration includes sophisticated grounding to ensure responses are:

- **Contextually Appropriate**: Responses are tailored to mental health and emotional wellbeing
- **Safe and Supportive**: Built-in safety filters and empathetic response patterns
- **Conversation Aware**: The AI maintains context from previous messages in the conversation
- **Fallback Resilient**: If the API fails, the app provides meaningful fallback responses

### Key Capabilities

1. **Emotional Support**: Recognizes emotional states and provides appropriate support
2. **Mental Health Knowledge**: Grounded with evidence-based mental health information
3. **Activity Suggestions**: Can recommend app features like breathing exercises or journaling
4. **Crisis Awareness**: Encourages professional help when needed
5. **Conversation Starters**: Generates personalized conversation starters

## Technical Details

### Architecture

- **Service Layer**: `GeminiAiService` handles direct API communication
- **Repository Layer**: `GeminiAiChatRepository` manages chat history and message persistence
- **Fallback System**: Automatic fallback to helpful responses if API fails
- **Data Persistence**: Chat history is saved to Firestore for continuity

### Model Configuration

- **Model**: `gemini-2.5-flash` (optimized for fast, conversational responses)
- **Temperature**: 0.7 (balanced creativity and consistency)
- **Safety Filters**: Enabled for harassment, hate speech, and dangerous content
- **Context Window**: Up to 20 recent messages for conversation context

### System Prompt

The AI is guided by a comprehensive system prompt that:

- Defines Kanha's personality as warm, empathetic, and supportive
- Provides knowledge about mental health and coping strategies
- Sets clear boundaries and safety guidelines
- Establishes response style and tone guidelines

## Troubleshooting

### Common Issues

1. **Empty Responses**: Check that your API key is valid and has quota remaining
2. **Fallback Responses Only**: Verify the API key is properly configured
3. **Network Errors**: Ensure you have internet connectivity

### Error Handling

The integration includes robust error handling:

- Network failures → Helpful fallback responses
- API quota exceeded → Graceful degradation with local responses
- Invalid responses → Sanitization and fallback logic

### Testing Without API Key

If no API key is configured, the app automatically falls back to the mock implementation, allowing development and testing without API costs.

## Security Considerations

1. **Never commit API keys** to version control
2. **Use environment variables** for development
3. **Implement rate limiting** in production
4. **Monitor API usage** to prevent unexpected costs
5. **Validate all responses** before displaying to users

## Production Deployment

For production deployment:

1. Set up secure environment variable management
2. Implement proper rate limiting and caching
3. Monitor API usage and costs
4. Set up logging and error monitoring
5. Consider implementing response caching for common queries

## Support

If you encounter issues with the Gemini integration:

1. Check the Flutter logs for error messages
2. Verify your API key is valid
3. Ensure you have sufficient API quota
4. Review the Google AI Studio documentation

For app-specific issues, please refer to the main README or create an issue in the repository.