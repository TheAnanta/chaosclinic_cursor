/// Configuration class for AI services
class AiConfig {
  /// Gemini API key - should be loaded from environment variables or secure storage in production
  static const String geminiApiKey = String.fromEnvironment(
    'GEMINI_API_KEY',
    defaultValue: '', // Empty default - must be provided
  );

  /// Check if Gemini API key is configured
  static bool get isGeminiConfigured => geminiApiKey.isNotEmpty;

  /// Gemini model configuration
  static const String geminiModel = 'gemini-2.5-flash';
  
  /// Generation configuration
  static const double temperature = 0.7;
  static const int topK = 40;
  static const double topP = 0.95;
  static const int maxOutputTokens = 1024;
  
  /// Safety settings
  static const bool enableSafetyFilters = true;
  
  /// Chat history limits
  static const int maxChatHistoryMessages = 100;
  static const int contextHistoryMessages = 20;
  
  /// Fallback behavior
  static const bool useFallbackOnError = true;
  static const bool saveChatToFirestore = true;
  
  /// Conversation starter settings
  static const int maxConversationStarters = 5;
  
  /// Rate limiting (for production use)
  static const int maxRequestsPerMinute = 60;
  static const int maxRequestsPerHour = 1000;
}