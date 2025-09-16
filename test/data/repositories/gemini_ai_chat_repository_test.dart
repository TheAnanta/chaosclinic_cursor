import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:chaosclinic/data/services/gemini_ai_service.dart';
import 'package:chaosclinic/data/repositories/gemini_ai_chat_repository.dart';
import 'package:chaosclinic/data/services/firestore_service.dart';
import 'package:chaosclinic/domain/models/chat_message.dart';

import 'gemini_ai_chat_repository_test.mocks.dart';

@GenerateMocks([
  GeminiAiService,
  FirestoreService,
])
void main() {
  group('GeminiAiChatRepository', () {
    late GeminiAiChatRepository repository;
    late MockGeminiAiService mockGeminiService;
    late MockFirestoreService mockFirestoreService;

    setUp(() {
      mockGeminiService = MockGeminiAiService();
      mockFirestoreService = MockFirestoreService();
      repository = GeminiAiChatRepository(
        mockGeminiService,
        mockFirestoreService,
      );
    });

    group('sendMessage', () {
      test('should return AI response when Gemini service succeeds', () async {
        // Arrange
        const userId = 'test-user';
        const message = 'Hello, I am feeling anxious';
        final chatHistory = <ChatMessage>[];
        const expectedResponse = 
            "I understand that anxiety can feel overwhelming. Take a deep breath with me - "
            "in for 4 counts, hold for 4, out for 4. You're doing great by reaching out.";

        when(mockGeminiService.sendMessage(message, chatHistory, userId))
            .thenAnswer((_) async => expectedResponse);

        when(mockFirestoreService.setSubcollectionDocument(
          any, any, any, any, any,
        )).thenAnswer((_) async {});

        // Act
        final result = await repository.sendMessage(userId, message, chatHistory);

        // Assert
        expect(result.text, expectedResponse);
        expect(result.sender, MessageSender.ai);
        expect(result.status, MessageStatus.sent);
        
        verify(mockGeminiService.sendMessage(message, chatHistory, userId)).called(1);
        verify(mockFirestoreService.setSubcollectionDocument(
          'user_chats', userId, 'messages', any, any,
        )).called(1);
      });

      test('should return fallback response when Gemini service fails', () async {
        // Arrange
        const userId = 'test-user';
        const message = 'Hello';
        final chatHistory = <ChatMessage>[];

        when(mockGeminiService.sendMessage(message, chatHistory, userId))
            .thenThrow(Exception('API Error'));

        when(mockFirestoreService.setSubcollectionDocument(
          any, any, any, any, any,
        )).thenAnswer((_) async {});

        // Act
        final result = await repository.sendMessage(userId, message, chatHistory);

        // Assert
        expect(result.sender, MessageSender.ai);
        expect(result.status, MessageStatus.failed);
        expect(result.text, contains('having trouble connecting'));
        
        verify(mockGeminiService.sendMessage(message, chatHistory, userId)).called(1);
      });
    });

    group('getConversationStarters', () {
      test('should return starters from Gemini service', () async {
        // Arrange
        final expectedStarters = [
          'How are you feeling today?',
          'What\'s been on your mind lately?',
          'Tell me about your mood right now',
        ];

        when(mockGeminiService.getConversationStarters())
            .thenAnswer((_) async => expectedStarters);

        // Act
        final result = await repository.getConversationStarters();

        // Assert
        expect(result, expectedStarters);
        verify(mockGeminiService.getConversationStarters()).called(1);
      });

      test('should return default starters when service fails', () async {
        // Arrange
        when(mockGeminiService.getConversationStarters())
            .thenThrow(Exception('API Error'));

        // Act
        final result = await repository.getConversationStarters();

        // Assert
        expect(result, isNotEmpty);
        expect(result.first, contains('How are you feeling'));
      });
    });

    group('saveChatMessage', () {
      test('should save message to Firestore', () async {
        // Arrange
        const userId = 'test-user';
        final message = ChatMessage(
          id: '123',
          text: 'Test message',
          sender: MessageSender.user,
          timestamp: DateTime.now(),
        );

        when(mockFirestoreService.setSubcollectionDocument(
          any, any, any, any, any,
        )).thenAnswer((_) async {});

        // Act
        await repository.saveChatMessage(userId, message);

        // Assert
        verify(mockFirestoreService.setSubcollectionDocument(
          'user_chats', userId, 'messages', message.id, any,
        )).called(1);
      });
    });
  });
}