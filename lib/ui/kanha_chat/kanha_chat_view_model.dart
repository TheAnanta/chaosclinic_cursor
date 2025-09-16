import 'package:flutter/material.dart';
import '../../domain/models/chat_message.dart';
import '../../domain/use_cases/kanha_chat_use_cases.dart';

enum KanhaChatState {
  initial,
  loading,
  success,
  error,
}

/// ViewModel for Kanha AI chat functionality
class KanhaChatViewModel extends ChangeNotifier {
  final SendMessageToKanhaUseCase _sendMessageUseCase;
  final GetChatHistoryUseCase _getChatHistoryUseCase;
  final GetConversationStartersUseCase _getConversationStartersUseCase;
  final String _userId;

  KanhaChatViewModel(
    this._sendMessageUseCase,
    this._getChatHistoryUseCase,
    this._getConversationStartersUseCase,
    this._userId,
  ) {
    _loadChatHistory();
    _loadConversationStarters();
  }

  // State
  KanhaChatState _state = KanhaChatState.initial;
  List<ChatMessage> _messages = [];
  List<String> _conversationStarters = [];
  bool _isAiTyping = false;
  String? _errorMessage;

  // Getters
  KanhaChatState get state => _state;
  List<ChatMessage> get messages => _messages;
  List<String> get conversationStarters => _conversationStarters;
  bool get isAiTyping => _isAiTyping;
  String? get errorMessage => _errorMessage;
  bool get hasMessages => _messages.isNotEmpty;

  /// Send a message to Kanha
  Future<void> sendMessage(String message) async {
    if (message.trim().isEmpty) return;

    try {
      // Add user message immediately to the UI
      final userMessage = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        text: message.trim(),
        sender: MessageSender.user,
        timestamp: DateTime.now(),
      );

      _messages.add(userMessage);
      _isAiTyping = true;
      _errorMessage = null;
      notifyListeners();

      // Send to AI and get response
      final aiResponse = await _sendMessageUseCase.call(
        _userId,
        message,
        _messages,
      );

      _messages.add(aiResponse);
      _isAiTyping = false;
      _state = KanhaChatState.success;
      notifyListeners();
    } catch (e) {
      _isAiTyping = false;
      _errorMessage = 'Failed to send message. Please try again.';
      _state = KanhaChatState.error;
      notifyListeners();
    }
  }

  /// Send a quick starter message
  Future<void> sendStarterMessage(String message) async {
    await sendMessage(message);
  }

  /// Load chat history
  Future<void> _loadChatHistory() async {
    try {
      _state = KanhaChatState.loading;
      notifyListeners();

      _messages = await _getChatHistoryUseCase.call(_userId);
      _state = KanhaChatState.success;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to load chat history';
      _state = KanhaChatState.error;
      notifyListeners();
    }
  }

  /// Load conversation starters
  Future<void> _loadConversationStarters() async {
    try {
      _conversationStarters = await _getConversationStartersUseCase.call();
      notifyListeners();
    } catch (e) {
      // Conversation starters are optional, don't show error for this
    }
  }

  /// Refresh chat (reload history)
  Future<void> refresh() async {
    await _loadChatHistory();
  }

  /// Retry sending the last failed message
  Future<void> retryLastMessage() async {
    if (_messages.isNotEmpty) {
      final lastMessage = _messages.last;
      if (lastMessage.isFromUser) {
        await sendMessage(lastMessage.text);
      }
    }
  }

  /// Get welcome message for new users
  String getWelcomeMessage() {
    return "Hi there! I'm Kanha, your AI companion for emotional wellbeing. "
        "I'm here to listen, support, and help you navigate your feelings. "
        "How are you doing today?";
  }

  /// Check if we should show conversation starters
  bool get shouldShowStarters => !hasMessages && _conversationStarters.isNotEmpty;
}