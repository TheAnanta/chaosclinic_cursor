import 'package:freezed_annotation/freezed_annotation.dart';

part 'chat_message.freezed.dart';
part 'chat_message.g.dart';

@freezed
class ChatMessage with _$ChatMessage {
  const factory ChatMessage({
    required String id,
    required String text,
    required MessageSender sender,
    required DateTime timestamp,
    @Default(MessageType.text) MessageType type,
    @Default(MessageStatus.sent) MessageStatus status,
    String? imageUrl,
    String? audioUrl,
    Map<String, dynamic>? metadata,
    String? replyToMessageId,
    @Default([]) List<String> reactions,
    @Default(false) bool isEdited,
    DateTime? editedAt,
  }) = _ChatMessage;

  factory ChatMessage.fromJson(Map<String, Object?> json) =>
      _$ChatMessageFromJson(json);
}

enum MessageSender {
  user,
  ai,
  system,
}

enum MessageType {
  text,
  image,
  audio,
  system,
  suggestion,
}

enum MessageStatus {
  sending,
  sent,
  delivered,
  read,
  failed,
}

/// Extension methods for ChatMessage
extension ChatMessageExtensions on ChatMessage {
  /// Check if message is from user
  bool get isFromUser => sender == MessageSender.user;

  /// Check if message is from AI (Kanha)
  bool get isFromAI => sender == MessageSender.ai;

  /// Check if message is a system message
  bool get isSystemMessage => sender == MessageSender.system;

  /// Get sender display name
  String get senderDisplayName {
    switch (sender) {
      case MessageSender.user:
        return 'You';
      case MessageSender.ai:
        return 'Kanha';
      case MessageSender.system:
        return 'System';
    }
  }

  /// Get formatted timestamp
  String get timeDisplay {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inDays == 0) {
      // Same day - show time
      final hour = timestamp.hour;
      final minute = timestamp.minute.toString().padLeft(2, '0');
      final period = hour >= 12 ? 'PM' : 'AM';
      final displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
      return '$displayHour:$minute $period';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${difference.inDays ~/ 7}w ago';
    }
  }

  /// Get status display icon
  String get statusIcon {
    switch (status) {
      case MessageStatus.sending:
        return '⏳';
      case MessageStatus.sent:
        return '✓';
      case MessageStatus.delivered:
        return '✓✓';
      case MessageStatus.read:
        return '✓✓';
      case MessageStatus.failed:
        return '❌';
    }
  }

  /// Check if message has multimedia content
  bool get hasMultimedia {
    return imageUrl != null || audioUrl != null;
  }

  /// Get message preview (truncated text for notifications)
  String get preview {
    if (text.length <= 50) {
      return text;
    }
    return '${text.substring(0, 47)}...';
  }

  /// Check if message is recent (within last hour)
  bool get isRecent {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    return difference.inHours <= 1;
  }

  /// Create a copy of message with updated status
  ChatMessage copyWithStatus(MessageStatus newStatus) {
    return copyWith(status: newStatus);
  }

  /// Create a copy of message marked as edited
  ChatMessage copyWithEdit(String newText) {
    return copyWith(
      text: newText,
      isEdited: true,
      editedAt: DateTime.now(),
    );
  }
}