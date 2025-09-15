import '../models/activity.dart';
import '../models/emotion_log.dart';
import '../../data/repositories/activity_repository.dart';
import '../../data/repositories/user_repository.dart';

/// Use case for getting personalized activity recommendations based on user's emotional state
class GetPersonalizedActivityUseCase {
  final UserRepository _userRepository;
  final ActivityRepository _activityRepository;

  GetPersonalizedActivityUseCase(
    this._userRepository,
    this._activityRepository,
  );

  /// Get a recommended activity based on the user's latest emotion log
  Future<Activity?> call(String userId) async {
    try {
      // Get user's latest emotion log
      final emotionLogs = await _userRepository.getRecentEmotionLogs(userId, limit: 1);
      
      if (emotionLogs.isEmpty) {
        // No emotion logs - return a general beginner-friendly activity
        return await _activityRepository.getRecommendedActivity(
          targetMood: null,
          difficultyLevel: 0.3, // Easy difficulty
        );
      }

      final latestLog = emotionLogs.first;
      
      // Get activities that match the user's current mood and intensity
      final recommendedActivity = await _activityRepository.getRecommendedActivity(
        targetMood: latestLog.mood,
        difficultyLevel: _getDifficultyForIntensity(latestLog.intensity),
      );

      return recommendedActivity;
    } catch (e) {
      // Log error and return null
      return null;
    }
  }

  /// Get multiple personalized activities
  Future<List<Activity>> callMultiple(String userId, {int limit = 5}) async {
    try {
      // Get user's recent emotion logs for pattern analysis
      final emotionLogs = await _userRepository.getRecentEmotionLogs(userId, limit: 10);
      
      if (emotionLogs.isEmpty) {
        // No emotion logs - return general beginner-friendly activities
        return await _activityRepository.getActivitiesByDifficulty(0.3, limit: limit);
      }

      // Analyze mood patterns
      final moodPattern = _analyzeMoodPattern(emotionLogs);
      final avgIntensity = _calculateAverageIntensity(emotionLogs);
      
      // Get diverse set of activities
      final activities = await _activityRepository.getRecommendedActivities(
        targetMoods: moodPattern.keys.toList(),
        difficultyLevel: _getDifficultyForIntensity(avgIntensity),
        limit: limit,
      );

      return activities;
    } catch (e) {
      // Return empty list on error
      return [];
    }
  }

  /// Analyze mood patterns from recent emotion logs
  Map<String, double> _analyzeMoodPattern(List<EmotionLog> logs) {
    final moodCounts = <String, int>{};
    
    for (final log in logs) {
      moodCounts[log.mood] = (moodCounts[log.mood] ?? 0) + 1;
    }
    
    // Convert to frequencies
    final totalLogs = logs.length;
    return moodCounts.map((mood, count) => MapEntry(mood, count / totalLogs));
  }

  /// Calculate average intensity from emotion logs
  double _calculateAverageIntensity(List<EmotionLog> logs) {
    if (logs.isEmpty) return 3.0; // Default medium intensity
    
    final totalIntensity = logs.fold<int>(0, (sum, log) => sum + log.intensity);
    return totalIntensity / logs.length;
  }

  /// Map emotion intensity to activity difficulty level
  double _getDifficultyForIntensity(double intensity) {
    // Lower intensity emotions might benefit from more engaging (higher difficulty) activities
    // Higher intensity emotions might need calming (lower difficulty) activities
    if (intensity <= 2.0) {
      return 0.6; // Medium-high difficulty for low intensity
    } else if (intensity >= 4.0) {
      return 0.2; // Low difficulty for high intensity
    } else {
      return 0.4; // Medium difficulty for moderate intensity
    }
  }
}