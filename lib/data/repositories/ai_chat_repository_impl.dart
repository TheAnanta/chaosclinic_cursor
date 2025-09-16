import 'dart:math';
import '../../domain/models/chat_message.dart';
import 'ai_chat_repository.dart';

/// Mock implementation of AI chat repository for development
class MockAiChatRepository implements AiChatRepository {
  final Map<String, List<ChatMessage>> _chatHistories = {};
  final Random _random = Random();

  @override
  Future<ChatMessage> sendMessage(
    String userId,
    String message,
    List<ChatMessage> chatHistory,
  ) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 1500));

    // Generate AI response based on message content
    final response = _generateAiResponse(message, chatHistory);
    
    final aiMessage = ChatMessage(
      id: _generateId(),
      text: response,
      sender: MessageSender.ai,
      timestamp: DateTime.now(),
    );

    // Save the AI message to history
    await saveChatMessage(userId, aiMessage);
    
    return aiMessage;
  }

  @override
  Future<List<ChatMessage>> getChatHistory(String userId) async {
    return _chatHistories[userId] ?? [];
  }

  @override
  Future<void> saveChatMessage(String userId, ChatMessage message) async {
    _chatHistories[userId] ??= [];
    _chatHistories[userId]!.add(message);
  }

  @override
  Future<void> clearChatHistory(String userId) async {
    _chatHistories[userId]?.clear();
  }

  @override
  Future<List<String>> getConversationStarters() async {
    return [
      "How are you feeling today?",
      "Tell me about your mood",
      "What's been on your mind lately?",
      "How can I help you feel better?",
      "What activities make you happy?",
    ];
  }

  String _generateAiResponse(String userMessage, List<ChatMessage> history) {
    final lowerMessage = userMessage.toLowerCase();
    
    // Responses based on keywords
    if (lowerMessage.contains('anxious') || lowerMessage.contains('anxiety')) {
      return _getRandomResponse([
        "I understand that anxiety can feel overwhelming. Take a deep breath with me - in for 4 counts, hold for 4, out for 4. You're doing great by reaching out.",
        "Anxiety is tough, but you're tougher. Try grounding yourself - name 5 things you can see, 4 you can touch, 3 you can hear, 2 you can smell, and 1 you can taste.",
        "Thank you for sharing how you're feeling. Anxiety is real, but it's temporary. Would you like to try a quick breathing exercise together?",
      ]);
    }
    
    if (lowerMessage.contains('sad') || lowerMessage.contains('down') || lowerMessage.contains('depressed')) {
      return _getRandomResponse([
        "I hear you, and I want you to know that what you're feeling is valid. Even in difficult moments, you have strength within you.",
        "It's okay to feel sad sometimes. Would you like to talk about what's making you feel this way, or would you prefer to try an activity that might lift your spirits?",
        "Thank you for trusting me with your feelings. Remember, sadness is temporary, but your resilience is permanent. How can I support you right now?",
      ]);
    }
    
    if (lowerMessage.contains('happy') || lowerMessage.contains('good') || lowerMessage.contains('great')) {
      return _getRandomResponse([
        "That's wonderful to hear! I'm so glad you're feeling good. What's been bringing you joy today?",
        "Your positive energy is contagious! It's beautiful when you share your happiness. Keep nurturing that feeling.",
        "I love seeing you in such a good mood! Would you like to capture this feeling in your journal or try an activity that builds on this positive energy?",
      ]);
    }
    
    if (lowerMessage.contains('stressed') || lowerMessage.contains('stress') || lowerMessage.contains('overwhelmed')) {
      return _getRandomResponse([
        "Stress can feel like carrying a heavy backpack. Let's help you set it down for a moment. What's the biggest thing weighing on your mind?",
        "I can sense you're feeling overwhelmed. That takes courage to acknowledge. Would a short meditation or some gentle breathing help right now?",
        "Stress is your mind's way of saying 'I care about this.' Let's channel that caring into something manageable. What's one small step you could take?",
      ]);
    }
    
    if (lowerMessage.contains('tired') || lowerMessage.contains('exhausted') || lowerMessage.contains('sleep')) {
      return _getRandomResponse([
        "Rest is not a luxury, it's a necessity. Your body and mind are asking for what they need. How has your sleep been lately?",
        "Being tired can make everything feel harder. You deserve good rest. Would you like some tips for better sleep, or should we talk about what's keeping you up?",
        "Thank you for listening to your body's signals. Fatigue is real. Let's think about some gentle activities that might help restore your energy.",
      ]);
    }
    
    if (lowerMessage.contains('angry') || lowerMessage.contains('mad') || lowerMessage.contains('frustrated')) {
      return _getRandomResponse([
        "Anger is information - it tells us something important. It's okay to feel angry. What do you think your anger is trying to tell you?",
        "I can hear the frustration in your words. Anger can be powerful when we channel it constructively. Would you like to talk through what's making you feel this way?",
        "Your anger is valid, and I'm here to listen without judgment. Sometimes anger protects other feelings underneath. What's really going on?",
      ]);
    }
    
    // General supportive responses
    return _getRandomResponse([
      "Thank you for sharing with me. I'm here to listen and support you. How are you feeling right now?",
      "I appreciate you opening up. Your feelings matter, and you deserve support. What would be most helpful for you today?",
      "You've taken a brave step by reaching out. I'm here for you. What's on your heart and mind?",
      "Every feeling you have is valid and important. I'm glad you're here. How can I best support you today?",
      "You're not alone in this journey. I'm here to listen, understand, and help however I can. Tell me more about what you're experiencing.",
    ]);
  }

  String _getRandomResponse(List<String> responses) {
    return responses[_random.nextInt(responses.length)];
  }

  String _generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }
}