import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:logger/logger.dart';
import 'package:collection/collection.dart';
import '../../domain/models/chat_message.dart';

/// Service for interacting with Google's Gemini AI API
class GeminiAiService {
  final GenerativeModel _model;
  final Logger _logger = Logger();

  GeminiAiService({required String apiKey})
      : _model = GenerativeModel(
          model: 'gemini-2.5-flash',
          apiKey: apiKey,
          generationConfig: GenerationConfig(
            temperature: 0.7,
            topK: 40,
            topP: 0.95,
            maxOutputTokens: 1024,
          ),
          systemInstruction: Content.system(_getSystemPrompt()),
          safetySettings: [
            SafetySetting(HarmCategory.harassment, HarmBlockThreshold.medium),
            SafetySetting(HarmCategory.hateSpeech, HarmBlockThreshold.medium),
            SafetySetting(HarmCategory.sexuallyExplicit, HarmBlockThreshold.high),
            SafetySetting(HarmCategory.dangerousContent, HarmBlockThreshold.medium),
          ],
        );

  /// Send a message to Gemini with chat history context
  Future<String> sendMessage(
    String message,
    List<ChatMessage> chatHistory,
    String userId,
  ) async {
    try {
      _logger.i('Sending message to Gemini for user: $userId');
      
      // Build conversation history for context
      final chatSession = _model.startChat(
        history: _buildChatHistory(chatHistory),
      );

      // Send the user's message with context
      final content = Content.text(_enhanceMessageWithContext(message));
      final response = await chatSession.sendMessage(content);

      if (response.text == null || response.text!.isEmpty) {
        throw Exception('Empty response from Gemini API');
      }

      _logger.i('Received response from Gemini: ${response.text!.length} characters');
      return response.text!;
    } catch (e) {
      _logger.e('Error calling Gemini API: $e');
      
      // Return a fallback response that's still helpful
      return _getFallbackResponse(message);
    }
  }

  /// Get conversation starters
  Future<List<String>> getConversationStarters() async {
    try {
      const prompt = """
      Generate 5 conversation starters for a mental health companion AI. 
      These should be warm, inviting, and encourage users to share their feelings.
      Return only the conversation starters, one per line, without numbering or bullet points.
      """;

      final content = Content.text(prompt);
      final response = await _model.generateContent([content]);

      if (response.text != null && response.text!.isNotEmpty) {
        return response.text!
            .split('\n')
            .where((line) => line.trim().isNotEmpty)
            .take(5)
            .toList();
      }
    } catch (e) {
      _logger.e('Error getting conversation starters: $e');
    }

    // Fallback conversation starters
    return [
      "How are you feeling today?",
      "What's been on your mind lately?",
      "Tell me about your mood right now",
      "How can I support you today?",
      "What would make today a little better for you?",
    ];
  }

  /// Build chat history for Gemini API
  List<Content> _buildChatHistory(List<ChatMessage> chatHistory) {
    final history = <Content>[];
    
    // Only include recent messages to stay within context limits
    final recentMessages = chatHistory
        .where((msg) => msg.sender != MessageSender.system)
        .take(20)
        .toList();

    for (final message in recentMessages) {
      if (message.isFromUser) {
        history.add(Content.text(message.text));
      } else if (message.isFromAI) {
        history.add(Content.model([TextPart(message.text)]));
      }
    }

    return history;
  }

  /// Enhance user message with context for better responses
  String _enhanceMessageWithContext(String message) {
    // Add context cues to help Gemini understand this is a mental health conversation
    return """
    User message: "$message"
    
    Please respond as Kanha, a compassionate AI companion focused on emotional wellbeing.
    Consider the user's emotional state and provide supportive, empathetic responses.
    """;
  }

  /// Get system prompt that defines Kanha's personality and behavior
  static String _getSystemPrompt() {
    return """
    You are Kanha, a compassionate AI companion designed to support emotional wellbeing and mental health. Your role is to:

    PERSONALITY:
    - Be warm, empathetic, and non-judgmental
    - Show genuine care and understanding
    - Use a gentle, supportive tone
    - Be encouraging and optimistic while acknowledging difficulties

    KNOWLEDGE BASE:
    - You have knowledge about mental health, emotional regulation, and coping strategies
    - You understand common mental health challenges like anxiety, depression, stress
    - You know evidence-based techniques like mindfulness, breathing exercises, grounding techniques
    - You're familiar with cognitive behavioral therapy (CBT) principles

    CAPABILITIES:
    - Listen actively and validate emotions
    - Offer practical coping strategies and techniques
    - Suggest appropriate activities from the app (breathing exercises, journaling, games)
    - Provide psychoeducation about mental health
    - Help users identify thought patterns and emotions

    SAFETY & LIMITATIONS:
    - Always encourage professional help for serious mental health concerns
    - Never provide medical diagnoses or replace professional therapy
    - If someone mentions self-harm or suicide, express concern and encourage immediate professional help
    - Be clear about your limitations as an AI companion

    RESPONSE STYLE:
    - Keep responses concise but meaningful (2-4 sentences typically)
    - Ask follow-up questions to encourage reflection
    - Use "I" statements to show empathy ("I understand that must be difficult")
    - Offer specific, actionable suggestions when appropriate
    - Match the user's emotional tone while remaining supportive

    CONTEXT AWARENESS:
    - This is part of the Chaos Clinic app for emotional wellbeing
    - Users may be dealing with stress, anxiety, mood issues, or general life challenges
    - The app includes features like mood tracking, mini-games, journaling, and community articles
    - You can reference these app features when making suggestions

    Remember: Your goal is to provide emotional support, practical guidance, and encouragement while maintaining appropriate boundaries as an AI companion.
    """;
  }

  /// Get a helpful fallback response when the API fails
  String _getFallbackResponse(String message) {
    final lowerMessage = message.toLowerCase();
    
    if (lowerMessage.contains('anxious') || lowerMessage.contains('anxiety')) {
      return "I understand anxiety can feel overwhelming. Try taking a slow, deep breath with me - in for 4 counts, hold for 4, and out for 4. You're doing great by reaching out. Would you like to try a breathing exercise in the app?";
    }
    
    if (lowerMessage.contains('sad') || lowerMessage.contains('down')) {
      return "I hear that you're feeling down, and I want you to know that your feelings are completely valid. Sometimes it helps to acknowledge these feelings rather than fight them. Would you like to talk more about what's making you feel this way?";
    }
    
    if (lowerMessage.contains('stressed') || lowerMessage.contains('stress')) {
      return "Stress can feel like carrying a heavy load. Let's see if we can help lighten that burden a bit. What's weighing most heavily on your mind right now? Sometimes just naming it can help.";
    }
    
    // General supportive response
    return "I'm here to listen and support you. Thank you for sharing with me. Your feelings matter, and you deserve care and understanding. How can I best support you right now?";
  }
}