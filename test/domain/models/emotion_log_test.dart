import 'package:flutter_test/flutter_test.dart';
import 'package:chaosclinic/domain/models/emotion_log.dart';

void main() {
  group('EmotionLog', () {
    test('should create EmotionLog with required fields', () {
      // Arrange
      final timestamp = DateTime.now();
      
      // Act
      final emotionLog = EmotionLog(
        id: 'test-id',
        timestamp: timestamp,
        mood: 'happy',
        intensity: 4,
      );
      
      // Assert
      expect(emotionLog.id, 'test-id');
      expect(emotionLog.timestamp, timestamp);
      expect(emotionLog.mood, 'happy');
      expect(emotionLog.intensity, 4);
      expect(emotionLog.note, null);
      expect(emotionLog.tags, isEmpty);
    });

    test('should create EmotionLog with all fields', () {
      // Arrange
      final timestamp = DateTime.now();
      
      // Act
      final emotionLog = EmotionLog(
        id: 'test-id',
        timestamp: timestamp,
        mood: 'anxious',
        intensity: 3,
        note: 'Test note',
        userId: 'user-123',
        tags: ['work', 'stress'],
        type: EmotionLogType.manual,
      );
      
      // Assert
      expect(emotionLog.id, 'test-id');
      expect(emotionLog.timestamp, timestamp);
      expect(emotionLog.mood, 'anxious');
      expect(emotionLog.intensity, 3);
      expect(emotionLog.note, 'Test note');
      expect(emotionLog.userId, 'user-123');
      expect(emotionLog.tags, ['work', 'stress']);
      expect(emotionLog.type, EmotionLogType.manual);
    });

    group('Extensions', () {
      test('toHealthPlatformData should return correct format', () {
        // Arrange
        final timestamp = DateTime.now();
        final emotionLog = EmotionLog(
          id: 'test-id',
          timestamp: timestamp,
          mood: 'happy',
          intensity: 4,
          note: 'Feeling good',
          tags: ['morning', 'coffee'],
        );
        
        // Act
        final healthData = emotionLog.toHealthPlatformData();
        
        // Assert
        expect(healthData['mood'], 'happy');
        expect(healthData['intensity'], 4);
        expect(healthData['timestamp'], timestamp.toIso8601String());
        expect(healthData['note'], 'Feeling good');
        expect(healthData['tags'], ['morning', 'coffee']);
      });

      test('isRecent should return true for logs within 24 hours', () {
        // Arrange
        final recentTimestamp = DateTime.now().subtract(const Duration(hours: 12));
        final recentLog = EmotionLog(
          id: 'recent-id',
          timestamp: recentTimestamp,
          mood: 'happy',
          intensity: 4,
        );
        
        // Act & Assert
        expect(recentLog.isRecent, isTrue);
      });

      test('isRecent should return false for logs older than 24 hours', () {
        // Arrange
        final oldTimestamp = DateTime.now().subtract(const Duration(hours: 30));
        final oldLog = EmotionLog(
          id: 'old-id',
          timestamp: oldTimestamp,
          mood: 'sad',
          intensity: 2,
        );
        
        // Act & Assert
        expect(oldLog.isRecent, isFalse);
      });

      test('intensityLabel should return correct labels', () {
        // Test cases for each intensity level
        const testCases = [
          (1, 'Very Low'),
          (2, 'Low'),
          (3, 'Moderate'),
          (4, 'High'),
          (5, 'Very High'),
        ];

        for (final (intensity, expectedLabel) in testCases) {
          // Arrange
          final emotionLog = EmotionLog(
            id: 'test-$intensity',
            timestamp: DateTime.now(),
            mood: 'test',
            intensity: intensity,
          );
          
          // Act & Assert
          expect(emotionLog.intensityLabel, expectedLabel);
        }
      });
    });

    group('Edge Cases', () {
      test('should handle minimum intensity value', () {
        // Arrange & Act
        final emotionLog = EmotionLog(
          id: 'min-test',
          timestamp: DateTime.now(),
          mood: 'calm',
          intensity: 1,
        );
        
        // Assert
        expect(emotionLog.intensity, 1);
        expect(emotionLog.intensityLabel, 'Very Low');
      });

      test('should handle maximum intensity value', () {
        // Arrange & Act
        final emotionLog = EmotionLog(
          id: 'max-test',
          timestamp: DateTime.now(),
          mood: 'overwhelmed',
          intensity: 5,
        );
        
        // Assert
        expect(emotionLog.intensity, 5);
        expect(emotionLog.intensityLabel, 'Very High');
      });

      test('should handle empty tags list', () {
        // Arrange & Act
        final emotionLog = EmotionLog(
          id: 'no-tags',
          timestamp: DateTime.now(),
          mood: 'neutral',
          intensity: 3,
          tags: [],
        );
        
        // Assert
        expect(emotionLog.tags, isEmpty);
      });

      test('should handle null values correctly', () {
        // Arrange & Act
        final emotionLog = EmotionLog(
          id: 'null-test',
          timestamp: DateTime.now(),
          mood: 'test',
          intensity: 3,
          note: null,
          userId: null,
          type: null,
        );
        
        // Assert
        expect(emotionLog.note, isNull);
        expect(emotionLog.userId, isNull);
        expect(emotionLog.type, isNull);
      });
    });
  });
}