import '../../domain/models/emotion_log.dart';

/// Abstract repository for emotion log operations
abstract class EmotionRepository {
  /// Add a new emotion log
  Future<void> addEmotionLog(EmotionLog log);

  /// Get emotion logs for a specific user
  Future<List<EmotionLog>> getEmotionLogs(String userId, {int? limit});

  /// Get recent emotion logs for a user (within specified days)
  Future<List<EmotionLog>> getRecentEmotionLogs(
    String userId, {
    int days = 7,
    int? limit,
  });

  /// Update an existing emotion log
  Future<void> updateEmotionLog(EmotionLog log);

  /// Delete an emotion log
  Future<void> deleteEmotionLog(String logId);

  /// Get emotion logs by mood type
  Future<List<EmotionLog>> getEmotionLogsByMood(
    String userId,
    String mood, {
    int? limit,
  });

  /// Get emotion logs within date range
  Future<List<EmotionLog>> getEmotionLogsByDateRange(
    String userId,
    DateTime startDate,
    DateTime endDate,
  );

  /// Get emotion statistics for a user
  Future<Map<String, dynamic>> getEmotionStatistics(String userId);
}
