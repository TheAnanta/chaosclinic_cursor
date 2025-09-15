import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:chaosclinic/domain/use_cases/log_emotion_use_case.dart';
import 'package:chaosclinic/domain/models/emotion_log.dart';
import 'package:chaosclinic/data/repositories/emotion_repository.dart';

// Generate mocks
@GenerateMocks([EmotionRepository])
import 'log_emotion_use_case_test.mocks.dart';

void main() {
  group('LogEmotionUseCase', () {
    late LogEmotionUseCase useCase;
    late MockEmotionRepository mockRepository;

    setUp(() {
      mockRepository = MockEmotionRepository();
      useCase = LogEmotionUseCase(mockRepository);
    });

    group('call', () {
      test('should successfully log valid emotion', () async {
        // Arrange
        final timestamp = DateTime.now();
        final emotionLog = EmotionLog(
          id: 'test-id',
          timestamp: timestamp,
          mood: 'happy',
          intensity: 4,
          note: 'Feeling great today!',
          userId: 'user-123',
        );

        when(mockRepository.addEmotionLog(any))
            .thenAnswer((_) async {});

        // Act
        final result = await useCase.call(emotionLog);

        // Assert
        expect(result, isTrue);
        verify(mockRepository.addEmotionLog(emotionLog)).called(1);
      });

      test('should return false when repository throws exception', () async {
        // Arrange
        final emotionLog = EmotionLog(
          id: 'test-id',
          timestamp: DateTime.now(),
          mood: 'sad',
          intensity: 2,
        );

        when(mockRepository.addEmotionLog(any))
            .thenThrow(Exception('Database error'));

        // Act
        final result = await useCase.call(emotionLog);

        // Assert
        expect(result, isFalse);
      });

      test('should return false for invalid emotion log with empty mood', () async {
        // Arrange
        final emotionLog = EmotionLog(
          id: 'test-id',
          timestamp: DateTime.now(),
          mood: '', // Invalid empty mood
          intensity: 3,
        );

        // Act
        final result = await useCase.call(emotionLog);

        // Assert
        expect(result, isFalse);
        verifyNever(mockRepository.addEmotionLog(any));
      });

      test('should return false for intensity below 1', () async {
        // Arrange
        final emotionLog = EmotionLog(
          id: 'test-id',
          timestamp: DateTime.now(),
          mood: 'neutral',
          intensity: 0, // Invalid intensity
        );

        // Act
        final result = await useCase.call(emotionLog);

        // Assert
        expect(result, isFalse);
        verifyNever(mockRepository.addEmotionLog(any));
      });

      test('should return false for intensity above 5', () async {
        // Arrange
        final emotionLog = EmotionLog(
          id: 'test-id',
          timestamp: DateTime.now(),
          mood: 'excited',
          intensity: 6, // Invalid intensity
        );

        // Act
        final result = await useCase.call(emotionLog);

        // Assert
        expect(result, isFalse);
        verifyNever(mockRepository.addEmotionLog(any));
      });

      test('should return false for future timestamp', () async {
        // Arrange
        final futureTimestamp = DateTime.now().add(const Duration(days: 1));
        final emotionLog = EmotionLog(
          id: 'test-id',
          timestamp: futureTimestamp, // Invalid future timestamp
          mood: 'happy',
          intensity: 4,
        );

        // Act
        final result = await useCase.call(emotionLog);

        // Assert
        expect(result, isFalse);
        verifyNever(mockRepository.addEmotionLog(any));
      });

      test('should return false for note exceeding 500 characters', () async {
        // Arrange
        final longNote = 'a' * 501; // 501 characters
        final emotionLog = EmotionLog(
          id: 'test-id',
          timestamp: DateTime.now(),
          mood: 'frustrated',
          intensity: 3,
          note: longNote, // Invalid long note
        );

        // Act
        final result = await useCase.call(emotionLog);

        // Assert
        expect(result, isFalse);
        verifyNever(mockRepository.addEmotionLog(any));
      });

      test('should return false for more than 10 tags', () async {
        // Arrange
        final tooManyTags = List.generate(11, (index) => 'tag$index');
        final emotionLog = EmotionLog(
          id: 'test-id',
          timestamp: DateTime.now(),
          mood: 'overwhelmed',
          intensity: 4,
          tags: tooManyTags, // Invalid too many tags
        );

        // Act
        final result = await useCase.call(emotionLog);

        // Assert
        expect(result, isFalse);
        verifyNever(mockRepository.addEmotionLog(any));
      });

      test('should accept valid emotion log with maximum allowed note length', () async {
        // Arrange
        final maxNote = 'a' * 500; // 500 characters (allowed)
        final emotionLog = EmotionLog(
          id: 'test-id',
          timestamp: DateTime.now(),
          mood: 'content',
          intensity: 3,
          note: maxNote,
        );

        when(mockRepository.addEmotionLog(any))
            .thenAnswer((_) async {});

        // Act
        final result = await useCase.call(emotionLog);

        // Assert
        expect(result, isTrue);
        verify(mockRepository.addEmotionLog(emotionLog)).called(1);
      });

      test('should accept valid emotion log with maximum allowed tags', () async {
        // Arrange
        final maxTags = List.generate(10, (index) => 'tag$index');
        final emotionLog = EmotionLog(
          id: 'test-id',
          timestamp: DateTime.now(),
          mood: 'focused',
          intensity: 4,
          tags: maxTags, // 10 tags (allowed)
        );

        when(mockRepository.addEmotionLog(any))
            .thenAnswer((_) async {});

        // Act
        final result = await useCase.call(emotionLog);

        // Assert
        expect(result, isTrue);
        verify(mockRepository.addEmotionLog(emotionLog)).called(1);
      });
    });

    group('callSimple', () {
      test('should successfully log emotion with simple parameters', () async {
        // Arrange
        when(mockRepository.addEmotionLog(any))
            .thenAnswer((_) async {});

        // Act
        final result = await useCase.callSimple(
          userId: 'user-123',
          mood: 'calm',
          intensity: 3,
          note: 'Meditation helped',
          tags: ['meditation', 'evening'],
        );

        // Assert
        expect(result, isTrue);
        verify(mockRepository.addEmotionLog(any)).called(1);
      });

      test('should create emotion log with current timestamp', () async {
        // Arrange
        final beforeCall = DateTime.now();
        
        when(mockRepository.addEmotionLog(any))
            .thenAnswer((_) async {});

        // Act
        await useCase.callSimple(
          userId: 'user-123',
          mood: 'happy',
          intensity: 4,
        );

        final afterCall = DateTime.now();

        // Assert
        final capturedLog = verify(mockRepository.addEmotionLog(captureAny))
            .captured.single as EmotionLog;
        
        expect(capturedLog.userId, 'user-123');
        expect(capturedLog.mood, 'happy');
        expect(capturedLog.intensity, 4);
        expect(capturedLog.type, EmotionLogType.manual);
        expect(capturedLog.timestamp.isAfter(beforeCall) || 
               capturedLog.timestamp.isAtSameMomentAs(beforeCall), isTrue);
        expect(capturedLog.timestamp.isBefore(afterCall) || 
               capturedLog.timestamp.isAtSameMomentAs(afterCall), isTrue);
      });

      test('should handle optional parameters correctly', () async {
        // Arrange
        when(mockRepository.addEmotionLog(any))
            .thenAnswer((_) async {});

        // Act
        await useCase.callSimple(
          userId: 'user-123',
          mood: 'excited',
          intensity: 5,
        );

        // Assert
        final capturedLog = verify(mockRepository.addEmotionLog(captureAny))
            .captured.single as EmotionLog;
        
        expect(capturedLog.note, isNull);
        expect(capturedLog.tags, isEmpty);
      });

      test('should return false for invalid simple parameters', () async {
        // Act
        final result = await useCase.callSimple(
          userId: 'user-123',
          mood: '', // Invalid empty mood
          intensity: 3,
        );

        // Assert
        expect(result, isFalse);
        verifyNever(mockRepository.addEmotionLog(any));
      });
    });

    group('Validation Edge Cases', () {
      test('should validate mood with whitespace', () async {
        // Arrange
        final emotionLog = EmotionLog(
          id: 'test-id',
          timestamp: DateTime.now(),
          mood: '   ', // Whitespace only
          intensity: 3,
        );

        // Act
        final result = await useCase.call(emotionLog);

        // Assert
        expect(result, isFalse);
      });

      test('should accept valid edge case values', () async {
        // Arrange
        final emotionLog = EmotionLog(
          id: 'test-id',
          timestamp: DateTime.now().subtract(const Duration(microseconds: 1)),
          mood: 'a', // Single character mood (valid)
          intensity: 1, // Minimum intensity
          note: '', // Empty note (valid)
          tags: [], // Empty tags (valid)
        );

        when(mockRepository.addEmotionLog(any))
            .thenAnswer((_) async {});

        // Act
        final result = await useCase.call(emotionLog);

        // Assert
        expect(result, isTrue);
        verify(mockRepository.addEmotionLog(emotionLog)).called(1);
      });
    });
  });
}