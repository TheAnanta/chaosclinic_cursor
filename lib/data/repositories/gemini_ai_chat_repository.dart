import 'package:logger/logger.dart';
import '../../domain/models/chat_message.dart';
import '../services/gemini_ai_service.dart';
import '../services/firestore_service.dart';
import 'ai_chat_repository.dart';

/// Production implementation of AI chat repository using Gemini AI
class GeminiAiChatRepository implements AiChatRepository {
  final GeminiAiService _geminiService;
  final FirestoreService _firestoreService;
  final Logger _logger = Logger();

  static const String _chatCollection = 'user_chats';
  static const String _messagesSubcollection = 'messages';

  GeminiAiChatRepository(
    this._geminiService,
    this._firestoreService,
  );

  @override
  Future<ChatMessage> sendMessage(
    String userId,
    String message,
    List<ChatMessage> chatHistory,
  ) async {
    try {
      _logger.i('Sending message to Gemini for user: $userId');

      // Get AI response from Gemini with context
      final aiResponseText = await _geminiService.sendMessage(
        message,
        chatHistory,
        userId,
      );

      // Create AI message
      final aiMessage = ChatMessage(
        id: _generateId(),
        text: aiResponseText,
        sender: MessageSender.ai,
        timestamp: DateTime.now(),
        status: MessageStatus.sent,
      );

      // Save to Firestore
      await saveChatMessage(userId, aiMessage);

      _logger.i('AI response saved successfully');
      return aiMessage;
    } catch (e) {
      _logger.e('Error sending message to AI: $e');
      
      // Create a fallback response with error status
      final fallbackMessage = ChatMessage(
        id: _generateId(),
        text: "I'm having trouble connecting right now, but I'm here for you. "
            "Please try again in a moment, or if you need immediate support, "
            "consider reaching out to a trusted friend or mental health professional.",
        sender: MessageSender.ai,
        timestamp: DateTime.now(),
        status: MessageStatus.failed,
      );

      // Still save the fallback message
      await saveChatMessage(userId, fallbackMessage);
      return fallbackMessage;
    }
  }

  @override
  Future<List<ChatMessage>> getChatHistory(String userId) async {
    try {
      _logger.i('Fetching chat history for user: $userId');

      final messagesSnapshot = await _firestoreService.getSubcollection(
        _chatCollection,
        userId,
        _messagesSubcollection,
        orderBy: 'timestamp',
        limit: 100, // Limit to last 100 messages
      );

      final messages = messagesSnapshot.docs
          .map((doc) => _chatMessageFromFirestore(doc.data()))
          .where((message) => message != null)
          .cast<ChatMessage>()
          .toList();

      _logger.i('Retrieved ${messages.length} messages from chat history');
      return messages;
    } catch (e) {
      _logger.e('Error fetching chat history: $e');
      return [];
    }
  }

  @override
  Future<void> saveChatMessage(String userId, ChatMessage message) async {
    try {
      final messageData = _chatMessageToFirestore(message);
      
      await _firestoreService.setSubcollectionDocument(
        _chatCollection,
        userId,
        _messagesSubcollection,
        message.id,
        messageData,
      );

      _logger.d('Chat message saved to Firestore: ${message.id}');
    } catch (e) {
      _logger.e('Error saving chat message: $e');
      // Don't rethrow - we don't want chat failures to break the UI
    }
  }

  @override
  Future<void> clearChatHistory(String userId) async {
    try {
      _logger.i('Clearing chat history for user: $userId');
      
      // Get all messages
      final messagesSnapshot = await _firestoreService.getSubcollection(
        _chatCollection,
        userId,
        _messagesSubcollection,
      );

      // Delete all messages
      for (final doc in messagesSnapshot.docs) {
        await _firestoreService.deleteSubcollectionDocument(
          _chatCollection,
          userId,
          _messagesSubcollection,
          doc.id,
        );
      }

      _logger.i('Chat history cleared successfully');
    } catch (e) {
      _logger.e('Error clearing chat history: $e');
      rethrow;
    }
  }

  @override
  Future<List<String>> getConversationStarters() async {
    try {
      _logger.i('Fetching conversation starters from Gemini');
      return await _geminiService.getConversationStarters();
    } catch (e) {
      _logger.e('Error fetching conversation starters: $e');
      
      // Return default starters if Gemini fails
      return [
        "How are you feeling today?",
        "What's been on your mind lately?",
        "Tell me about your mood right now",
        "How can I support you today?",
        "What would make today a little better for you?",
      ];
    }
  }

  /// Convert ChatMessage to Firestore-compatible format
  Map<String, dynamic> _chatMessageToFirestore(ChatMessage message) {
    return {
      'id': message.id,
      'text': message.text,
      'sender': message.sender.name,
      'timestamp': message.timestamp.toIso8601String(),
      'type': message.type.name,
      'status': message.status.name,
      'imageUrl': message.imageUrl,
      'audioUrl': message.audioUrl,
      'metadata': message.metadata,
      'replyToMessageId': message.replyToMessageId,
      'reactions': message.reactions,
      'isEdited': message.isEdited,
      'editedAt': message.editedAt?.toIso8601String(),
    };
  }

  /// Convert Firestore data to ChatMessage
  ChatMessage? _chatMessageFromFirestore(Map<String, dynamic> data) {
    try {
      return ChatMessage(
        id: data['id'] as String,
        text: data['text'] as String,
        sender: MessageSender.values.firstWhere(
          (s) => s.name == data['sender'],
          orElse: () => MessageSender.user,
        ),
        timestamp: DateTime.parse(data['timestamp'] as String),
        type: MessageType.values.firstWhere(
          (t) => t.name == (data['type'] ?? 'text'),
          orElse: () => MessageType.text,
        ),
        status: MessageStatus.values.firstWhere(
          (s) => s.name == (data['status'] ?? 'sent'),
          orElse: () => MessageStatus.sent,
        ),
        imageUrl: data['imageUrl'] as String?,
        audioUrl: data['audioUrl'] as String?,
        metadata: data['metadata'] as Map<String, dynamic>?,
        replyToMessageId: data['replyToMessageId'] as String?,
        reactions: (data['reactions'] as List<dynamic>?)
            ?.map((e) => e as String)
            .toList() ??
            [],
        isEdited: data['isEdited'] as bool? ?? false,
        editedAt: data['editedAt'] != null
            ? DateTime.parse(data['editedAt'] as String)
            : null,
      );
    } catch (e) {
      _logger.e('Error parsing chat message from Firestore: $e');
      return null;
    }
  }

  /// Generate unique ID for messages
  String _generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }
}