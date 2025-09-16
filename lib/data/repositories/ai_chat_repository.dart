import '../../domain/models/chat_message.dart';

/// Repository interface for AI chat functionality
abstract class AiChatRepository {
  /// Send a message to the AI and get a response
  Future<ChatMessage> sendMessage(
    String userId,
    String message,
    List<ChatMessage> chatHistory,
  );

  /// Get chat history for a user
  Future<List<ChatMessage>> getChatHistory(String userId);

  /// Save a chat message
  Future<void> saveChatMessage(String userId, ChatMessage message);

  /// Clear chat history for a user
  Future<void> clearChatHistory(String userId);

  /// Get suggested conversation starters
  Future<List<String>> getConversationStarters();
}