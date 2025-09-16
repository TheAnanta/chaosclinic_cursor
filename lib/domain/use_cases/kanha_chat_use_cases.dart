import '../../data/repositories/ai_chat_repository.dart';
import '../models/chat_message.dart';

/// Use case for sending messages to Kanha AI assistant
class SendMessageToKanhaUseCase {
  final AiChatRepository _aiChatRepository;

  SendMessageToKanhaUseCase(this._aiChatRepository);

  /// Send a message to Kanha and get a response
  /// 
  /// [userId] - The ID of the user sending the message
  /// [message] - The user's message text
  /// [chatHistory] - Current chat history for context
  /// 
  /// Returns the AI's response message
  Future<ChatMessage> call(
    String userId,
    String message,
    List<ChatMessage> chatHistory,
  ) async {
    // Validate input
    if (message.trim().isEmpty) {
      throw ArgumentError('Message cannot be empty');
    }

    // Create user message and save it
    final userMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: message.trim(),
      sender: MessageSender.user,
      timestamp: DateTime.now(),
    );

    await _aiChatRepository.saveChatMessage(userId, userMessage);

    // Get AI response
    final updatedHistory = [...chatHistory, userMessage];
    return await _aiChatRepository.sendMessage(userId, message, updatedHistory);
  }
}

/// Use case for getting chat history
class GetChatHistoryUseCase {
  final AiChatRepository _aiChatRepository;

  GetChatHistoryUseCase(this._aiChatRepository);

  /// Get chat history for a user
  Future<List<ChatMessage>> call(String userId) async {
    return await _aiChatRepository.getChatHistory(userId);
  }
}

/// Use case for getting conversation starters
class GetConversationStartersUseCase {
  final AiChatRepository _aiChatRepository;

  GetConversationStartersUseCase(this._aiChatRepository);

  /// Get suggested conversation starters
  Future<List<String>> call() async {
    return await _aiChatRepository.getConversationStarters();
  }
}